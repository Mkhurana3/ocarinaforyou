#!/bin/zsh
KWS="$HOME/nxnative-kws"; B="$HOME/oot-kws-build"; src="$HOME/oot_saves_final/save"; dst="$B/run/save"
pgrep -f "tools/dmhost" >/dev/null && { echo "STOP: the game is running. Quit it first."; exit 1; }
echo "== is it the fork? =="
echo "remote: $(git -C $KWS remote get-url origin)"
echo "branch: $(git -C $KWS branch --show-current)   commit: $(git -C $KWS log -1 --format='%h %cd')"
echo "tex_release lines (fork-only, want 1+): $(grep -c tex_release $KWS/dm/games/0400486024DEC000/game.tsv)"
echo "== did the build finish? =="
grep "Build finished" ~/oot-kws-build.log | tail -1
for f in tools/dmhost extract/v131072/RomFS.img; do [[ -e $B/$f ]] && echo "present: $f" || echo "MISSING: $f"; done
grep -o 'DM_SAVE="[^"]*"' ~/oot-kws-build.log | tail -1
n=$(ls $src/slot_*/progress.sav 2>/dev/null | wc -l); (( n >= 1 )) || { echo "STOP: no saves in $src"; exit 1; }
mkdir -p "$dst"
[[ -n "$(ls -A $dst)" ]] && { rm -rf ~/oot_saves_kws_before; cp -R "$dst" ~/oot_saves_kws_before; echo "run/save had files; copy kept in ~/oot_saves_kws_before"; }
cp -R "$src/." "$dst/"
diff -r "$src" "$dst" >/dev/null && echo "OK: $n save slots installed and matching" || echo "WARNING: copy differs"
