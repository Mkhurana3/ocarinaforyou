#!/bin/zsh
d="$HOME/oot_logs"
f=$(ls -t "$d"/oot-play-*.log "$d"/oot-test-*.log 2>/dev/null | head -1)
[[ -z "$f" ]] && { echo "no log found in $d"; exit 1; }
echo "Log: $f ($(du -h "$f" | cut -f1)), last written $(stat -f '%Sm' "$f")"
echo
echo "--- settings seen in this run ---"
grep -m1 "DM_RENDER_SCALE" "$f" | cut -c1-160
grep -m1 "present upscaling" "$f" | cut -c1-160
echo "pipeline-archive lines: $(grep -c 'pipeline archive' "$f")  (above 0 means the archive was in use, so the DM_PSO_MTL4=0 workaround may not have been applied)"
echo
echo "--- how it ended ---"
echo "GPU hang lines: $(grep -c 'ErrorHang' "$f")"
echo "GPU access revoked: $(grep -c 'GPU access revoked' "$f")"
grep -n -i "FATAL\|abort\|SIGSEGV\|SIGBUS\|SIGABRT\|Segmentation\|game called nn::diag\|crash" "$f" | grep -v "kIOGPU" | head -15 | cut -c1-260
echo
echo "--- last 25 meaningful lines ---"
grep -v "longframe\|audren\|audio #0\|pool for handles\|task / mesh" "$f" | tail -25 | cut -c1-260
echo
echo "--- GPU memory over the run (MB, sampled) ---"
grep -o "GPU allocated [0-9]* MB" "$f" | awk '{print $3}' | awk 'NR%40==1' | tr '\n' ' '; echo
grep -o "GPU allocated [0-9]* MB" "$f" | awk '{if($3>m)m=$3}END{print "peak GPU allocated MB:", m+0}'
grep "memory up to frame" "$f" | tail -1 | cut -c1-260
echo
echo "--- movie / cutscene lines near the end ---"
grep -n -i "movie\|AV1\|codec" "$f" | tail -8 | cut -c1-220
echo
echo "--- last frame timing report ---"
grep "timing up to frame" "$f" | tail -1 | cut -c1-260
echo
echo "--- macOS crash reports for dmhost (last 2 days) ---"
find ~/Library/Logs/DiagnosticReports -name "dmhost*" -mtime -2 2>/dev/null | head -3
echo
echo "--- saves vs backup ---"
diff -rq "$HOME/Documents/Ocarina/0400486024DEC000_build/run/save" "$HOME/oot_saves/save" >/dev/null && echo SAME || echo "CHANGED (expected if you played)"
