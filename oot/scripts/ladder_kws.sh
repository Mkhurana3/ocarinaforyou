#!/bin/zsh
TIMEOUT=${TIMEOUT:-600}
B="$HOME/oot-kws-build"; KWS="$HOME/nxnative-kws"; out="$HOME/oot_logs"; res="$out/LADDER.txt"
base="DM_PSO_MTL4=0 DM_FPS_TARGET=30 DM_PRESENT_UPSCALE=metalfx"
tests=(
 "1080-fulltex|DM_RENDER_SCALE=0.75 DM_NVN_TEX_SOFT=0"
 "1080-softtex|DM_RENDER_SCALE=0.75"
 "900-softtex|DM_RENDER_SCALE=0.625"
 "864-softtex|DM_RENDER_SCALE=0.6"
)
echo "profile texture settings:"; grep -i "tex_" $KWS/dm/games/0400486024DEC000/game.tsv
echo "ladder $(date '+%m-%d %H:%M')  timeout ${TIMEOUT}s" > "$res"
echo "name | ran | verdict | peak GPU MB | render sizes" >> "$res"
run_test() {
  local name="$1" ov="$2" log="$out/oot-ladder-$1-$(date +%m%d-%H%M).log"
  pgrep -f "tools/dmhost" >/dev/null && { echo "quit the game first"; VERDICT=ERR; return; }
  echo; echo "=== $name: $base $ov ==="
  read "?Press Enter to launch, then load your save and play: "
  [[ -f "$B/shader/pso_pairs.tsv" ]] && export DM_PSO_PAIRS="$B/shader/pso_pairs.tsv"
  pushd "$B/run" >/dev/null
  env DM_ROOT="$B" DM_ROMFS="$B/extract/v131072/RomFS.img" DM_SAVE="$B/run/save" DM_TEMP="$B/run/temp" \
   DM_MSL_DIR="$B/shader/cache" DM_FONT_DIR="$B/font" DM_NVN_SHMAP="$KWS/dm/games/0400486024DEC000/shader_map.tsv" \
   DM_LANG=en-US DM_WINDOW=1 DM_FOCUS_KEEP=1 DM_FULLSCREEN=0 DM_AUDIO=1 DM_OPMODE=1 \
   ${=base} ${=ov} "$B/tools/dmhost" "$B/patched_v131072" > "$log" 2>&1 &
  local pid=$!; popd >/dev/null; local start=$SECONDS
  while kill -0 $pid 2>/dev/null; do
    tail -c 400000 "$log" | grep -q "ErrorHang\|GPU access revoked" && { sleep 3; kill $pid 2>/dev/null; break; }
    (( SECONDS - start >= TIMEOUT )) && { kill $pid 2>/dev/null; break; }
    sleep 2
  done
  sleep 2; kill -9 $pid 2>/dev/null; wait $pid 2>/dev/null
  local ran=$(( SECONDS - start )); sed -i '' "s#$HOME#/Users/USER#g" "$log"
  local hangs=$(grep -c ErrorHang "$log")
  local peak=$(grep -o "GPU allocated [0-9]* MB" "$log" | awk '{if($3>m)m=$3}END{print m+0}')
  local sizes=$(grep -o "attachment 0 ser=[0-9]* [0-9]*x[0-9]*" "$log" | awk '{print $4}' | sort | uniq -c | sort -rn | head -2 | awk '{printf "%s ",$2}')
  if (( hangs > 0 )); then VERDICT=HANG; elif (( ran < 200 )); then VERDICT="TOO-SHORT"; else VERDICT=PASS; fi
  echo "$name | ${ran}s | $VERDICT | $peak | $sizes" | tee -a "$res"
}
for t in "${tests[@]}"; do
  run_test "${t%%|*}" "${t#*|}"
  [[ "$VERDICT" == "PASS" ]] && { echo; echo "BEST PASSING SETTING. Play with: ~/play_oot_kws.sh $base ${t#*|}" | tee -a "$res"; break; }
done
echo; echo "===== paste this into the chat ====="; cat "$res"
