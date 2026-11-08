#!/bin/zsh
# usage: ~/play_oot_final.sh [VAR=value ...]   e.g. DM_RENDER_SCALE=0.85
oot_build="$HOME/Documents/Ocarina/0400486024DEC000_build"
mkdir -p "$HOME/oot_logs"
cd "$oot_build/run" &&
env \
DM_ROOT="$oot_build" \
DM_ROMFS="$oot_build/extract/v131072/RomFS.img" \
DM_SAVE="$oot_build/run/save" \
DM_TEMP="$oot_build/run/temp" \
DM_MSL_DIR="$oot_build/shader/cache" \
DM_FONT_DIR="$oot_build/font" \
DM_NVN_SHMAP="$HOME/nxnative/dm/games/0400486024DEC000/shader_map.tsv" \
DM_LANG=en-US DM_WINDOW=1 DM_FOCUS_KEEP=1 DM_FULLSCREEN=1 \
DM_AUDIO=1 DM_FPS_TARGET=30 DM_FRAME_DELTA=1 DM_CV_LATE=1 \
DM_OPMODE=1 DM_RENDER_SCALE=0.75 DM_PSO_MTL4=0 \
"$@" \
"$oot_build/tools/dmhost" "$oot_build/patched_v131072" \
2>&1 | tee "$HOME/oot_logs/oot-play-1080-$(date +%m%d-%H%M).log"
