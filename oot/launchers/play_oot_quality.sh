#!/bin/zsh
pkill dmhost 2>/dev/null; sleep 2
~/play_oot_kws.sh DM_RENDER_SCALE=0.75 DM_PRESENT_UPSCALE=metalfx DM_PSO_MTL4=0 DM_FPS_TARGET=30 "$@"
f=$(ls -t ~/oot_logs/oot-kws-*.log | head -1)
echo "--- check ---"
grep -m1 "3D views rendered" "$f"
grep -m1 "present upscaling" "$f" | cut -c1-120
grep -o "attachment 0 ser=[0-9]* [0-9]*x[0-9]*" "$f" | awk '{print $4}' | sort | uniq -c | sort -rn | head -2
grep "timing up to frame" "$f" | tail -1 | cut -c1-110
echo "hangs: $(grep -c ErrorHang "$f")   peak GPU MB: $(grep -o 'GPU allocated [0-9]* MB' "$f" | awk '{if($3>m)m=$3}END{print m+0}')"
