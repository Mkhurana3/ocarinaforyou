#!/bin/zsh
f=$(ls -t ~/oot_logs/oot-kws-*.log 2>/dev/null | head -1)
[[ -z "$f" ]] && { echo "no oot-kws log found"; exit 1; }
echo "Log: $f  ($(du -h "$f" | cut -f1))  last written: $(stat -f '%Sm' "$f")"
pgrep -f tools/dmhost >/dev/null && echo "game process: RUNNING" || echo "game process: not running"
echo "--- build / shader library ---"
grep -m1 "build: commit" "$f" | cut -c1-160
grep -m2 "shader libraries: one file\|metallib directory\|host shader libraries" "$f" | cut -c1-200
ls ~/oot-kws-build/shader/cache 2>/dev/null | head -5
echo "--- pipelines ---"
grep -m3 "pipeline archive\|pipeline prepare\|pipeline prewarm done" "$f" | cut -c1-220
echo "--- saves ---"
grep -m2 "fs mount save\|save commit" "$f" | cut -c1-200
ls ~/oot-kws-build/run/save 2>/dev/null | head
echo "--- errors ---"
echo "RED lines: $(grep -c 'RED' "$f")   GPU hangs: $(grep -c ErrorHang "$f")   revoked: $(grep -c 'GPU access revoked' "$f")"
grep -m6 "RED\|FATAL\|abort\|not found\|missing\|failed to" "$f" | grep -v kIOGPU | cut -c1-240
echo "--- frames ---"
grep "timing up to frame" "$f" | tail -2 | cut -c1-230
grep -m1 "3D views rendered" "$f"
grep -o "attachment 0 ser=[0-9]* [0-9]*x[0-9]*" "$f" | awk '{print $4}' | sort | uniq -c | sort -rn | head -3
echo "--- last 12 lines ---"
grep -v "longframe\|audren\|audio #0" "$f" | tail -12 | cut -c1-220
