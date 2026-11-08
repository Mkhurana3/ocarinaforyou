#!/bin/zsh
KWS="$HOME/nxnative-kws"; B="$HOME/oot-kws-build"
NUP=$(ls "$HOME"/Documents/Ocarina/*.nup 2>/dev/null | head -1)
[[ -z "$NUP" ]] && { echo "no .nup found in ~/Documents/Ocarina"; exit 1; }
free_gb=$(df -g "$HOME" | awk 'NR==2{print $4}')
echo "Free space: ${free_gb} GB   game file: $NUP"
if (( free_gb < 60 )) && [[ "${FORCE:-0}" != 1 ]]; then echo "Under 60 GB free. Free more space first."; exit 1; fi
for t in xcodegen zstd glslang dotnet; do command -v $t >/dev/null || { echo "MISSING $t"; exit 1; }; done
PY=$(ls /opt/homebrew/bin/python3.1[2-9] 2>/dev/null | tail -1); [[ -z "$PY" ]] && PY=python3
[[ -d "$KWS/.git" ]] || git clone https://github.com/cheemu21/kid-with-sword-remake.git "$KWS" || exit 1
cd "$KWS" || exit 1
git log -1 --format='fork commit: %h %cd'; $PY --version
$PY -m pip install --user --break-system-packages lz4 "capstone>=5,<6" fonttools nsz zbic==1.0.1.post1 "backports.zstd; python_version < '3.14'" 2>&1 | tail -3
mkdir -p "$B/shader/cache"
[[ -f "$HOME/cas_backup/cas.db" && ! -f "$B/shader/cache/cas.db" ]] && cp -c "$HOME/cas_backup/cas.db" "$B/shader/cache/cas.db"
caffeinate -i $PY scripts/build_ipa_from_nsp.py "$NUP" --platform mac --work-dir "$B" --keep-extracted 2>&1 | tee "$HOME/oot-kws-build.log"
echo "Build finished (exit ${pipestatus[1]}). Log: ~/oot-kws-build.log"
