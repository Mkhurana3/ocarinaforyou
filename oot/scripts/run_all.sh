#!/bin/zsh
TIMEOUT=${TIMEOUT:-420}
oot_build="$HOME/Documents/Ocarina/0400486024DEC000_build"
out="$HOME/oot_logs"; res="$out/RESULTS.txt"
mkdir -p "$out" "$HOME/oot_saves_runs"
tests=(
  "baseline-apps-closed|"
  "cut16|DM_NVN_CUT=16"
  "barrierfull|DM_NVN_BARRIER=full"
  "mtl0|DM_PSO_MTL4=0"
  "resCheck|DM_RES_CHECK=1"
  "scale70|DM_RENDER_SCALE=0.7"
)
echo "OoT GPU hang tests $(date '+%Y-%m-%d %H:%M')  macOS $(sw_vers -productVersion)  RAM $(( $(sysctl -n hw.memsize) / 1073741824 )) GB  timeout ${TIMEOUT}s" > "$res"
echo "name | override | ran | verdict | first failed frame | hang lines | access revoked | max GPU alloc MB | saves" >> "$res"

run_test() {
  local name="$1" ov="$2"
  local log="$out/oot-test-$name-$(date +%m%d-%H%M).log"
  if pgrep -f "tools/dmhost" >/dev/null; then echo "dmhost is still running; quit it first"; return 2; fi
  cp -R "$oot_build/run/save" "$HOME/oot_saves_runs/before-$name-$(date +%H%M%S)"
  echo; echo "=== Test: $name   ${ov:-(no override)} ==="
  memory_pressure 2>/dev/null | grep -i "free percentage"
  echo "Biggest memory users:"
  ps -axo rss=,comm= | sort -rn | head -5 | awk '{kb=$1; $1=""; printf "  %d MB %s\n", kb/1024, $0}'
  read "?Press Enter to launch, then load your save right away: "
  pushd "$oot_build/run" >/dev/null
  env \
    DM_ROOT="$oot_build" DM_ROMFS="$oot_build/extract/v131072/RomFS.img" \
    DM_SAVE="$oot_build/run/save" DM_TEMP="$oot_build/run/temp" \
    DM_MSL_DIR="$oot_build/shader/cache" DM_FONT_DIR="$oot_build/font" \
    DM_NVN_SHMAP="$HOME/nxnative/dm/games/0400486024DEC000/shader_map.tsv" \
    DM_LANG=en-US DM_WINDOW=1 DM_FOCUS_KEEP=1 DM_FULLSCREEN=0 DM_AUDIO=1 \
    DM_FPS_TARGET=30 DM_FRAME_DELTA=1 DM_CV_LATE=1 DM_OPMODE=1 DM_RENDER_SCALE=1.0 \
    ${=ov} \
    "$oot_build/tools/dmhost" "$oot_build/patched_v131072" > "$log" 2>&1 &
  local pid=$!
  popd >/dev/null
  local start=$SECONDS
  while kill -0 $pid 2>/dev/null; do
    if grep -q "GPU access revoked" "$log" 2>/dev/null; then sleep 3; kill $pid 2>/dev/null; break; fi
    if (( SECONDS - start >= TIMEOUT )); then kill $pid 2>/dev/null; break; fi
    sleep 2
  done
  sleep 2; kill -9 $pid 2>/dev/null; wait $pid 2>/dev/null
  local ran=$(( SECONDS - start ))
  sed -i '' "s#$HOME#/Users/USER#g" "$log"
  local hangs=$(grep -c "ErrorHang" "$log")
  local rev=$(grep -c "GPU access revoked" "$log")
  local ff=$(grep -m1 -o "failed submission fence=[0-9]*: frame [0-9]*" "$log" | grep -o "[0-9]*$")
  local maxgpu=$(grep -o "GPU allocated [0-9]* MB" "$log" | awk '{if($3>m)m=$3}END{print m+0}')
  local sv="SAME"; diff -rq "$oot_build/run/save" "$HOME/oot_saves/save" >/dev/null || sv="CHANGED"
  if (( rev > 0 )); then VERDICT="CRASH"
  elif (( hangs > 0 )); then VERDICT="HANG(recovered)"
  elif (( ran < 150 )); then VERDICT="INCONCLUSIVE(ended early)"
  else VERDICT="PASS"; fi
  echo "$name | ${ov:-none} | ${ran}s | $VERDICT | ${ff:--} | $hangs | $rev | $maxgpu | $sv" | tee -a "$res"
}

for t in "${tests[@]}"; do
  run_test "${t%%|*}" "${t#*|}"
  [[ "$VERDICT" == "PASS" ]] && { echo "That setting survived. Stopping here."; break; }
done
cd "$out" && zip -q ~/nxnative/oot-test-logs.zip oot-test-*.log RESULTS.txt
echo; echo "===== DONE. Paste this into the chat: ====="; cat "$res"
