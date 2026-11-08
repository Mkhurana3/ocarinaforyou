#!/bin/zsh
B="$HOME/oot-kws-build"; KWS="$HOME/nxnative-kws"; WARN_MB=${WARN_MB:-9000}
log="$HOME/oot_logs/oot-kws-$(date +%m%d-%H%M).log"; mkdir -p "$HOME/oot_logs"
[[ -f "$B/shader/pso_pairs.tsv" ]] && export DM_PSO_PAIRS="$B/shader/pso_pairs.tsv"
cd "$B/run" || exit 1
env DM_ROOT="$B" DM_ROMFS="$B/extract/v131072/RomFS.img" DM_SAVE="$B/run/save" DM_TEMP="$B/run/temp" \
 DM_MSL_DIR="$B/shader/cache" DM_FONT_DIR="$B/font" DM_NVN_SHMAP="$KWS/dm/games/0400486024DEC000/shader_map.tsv" \
 DM_LANG=en-US DM_WINDOW=1 DM_FOCUS_KEEP=1 DM_FULLSCREEN=0 DM_AUDIO=1 DM_OPMODE=1 DM_RENDER_SCALE=0.75 \
 "$@" "$B/tools/dmhost" "$B/patched_v131072" > "$log" 2>&1 &
pid=$!; warned=0; start=$SECONDS; echo "Playing. Log: $log"
while kill -0 $pid 2>/dev/null; do sleep 10
  mb=$(tail -c 300000 "$log" | grep -o "GPU allocated [0-9]* MB" | tail -1 | awk '{print $3}')
  if [[ -n "$mb" && "$mb" -ge "$WARN_MB" && $warned -eq 0 ]]; then
    osascript -e 'display notification "Save in-game, then quit and relaunch" with title "OoT: GPU memory high"'
    afplay /System/Library/Sounds/Sosumi.aiff 2>/dev/null; warned=1; fi
done
sed -i '' "s#$HOME#/Users/USER#g" "$log"
echo "Ended after $(( (SECONDS-start)/60 )) min. Hangs: $(grep -c ErrorHang "$log")  Revoked: $(grep -c 'GPU access revoked' "$log")"
