# Ocarina of Time on nxnative (Mac) - notes

Fork of https://github.com/seedds/nxnative with notes for The Legend of Zelda: Ocarina of Time (Switch 2 version), title ID 0400486024DEC000, v131072, run from a .nup.
Tested on: MacBook Air M2 (Mac14,2), 16 GB, macOS 27.2, Xcode 27.2.

This folder has notes only. It contains no game files, no keys, no saves and no caches. You must supply your own legally dumped game.

## What works
1080p (DM_RENDER_SCALE=0.75 on the fork's 2560x1440 docked base) with steady 16.7 ms frames and MetalFX upscaling, until the cutscene below.

Settings used:

    DM_RENDER_SCALE=0.75 DM_PSO_MTL4=0 DM_FPS_TARGET=30 DM_PRESENT_UPSCALE=metalfx DM_NVN_TEX_SOFT=0

## Known problem: GPU hang at the Saria / ocarina cutscene
When Saria gives Link the ocarina on leaving Kokiri Forest, the GPU hangs (kIOGPUCommandBufferCallbackErrorHang, then SubmissionsIgnored, then "GPU access revoked") and the game quits.
From an autosave just before it, 6 of 6 runs died within 158-241 s. The result was the same on every setting tried: render scale 0.5-0.75, handheld mode, DM_NVN_CUT=4/1 with DM_NVN_BARRIER=full, DM_PSO_MTL4=0, soft and full textures, and MetalFX.
DM_RES_CHECK=1 found 0 resources released too early and 0 missing residency.

Upstream issue: https://github.com/seedds/nxnative/issues/1690 (related: https://github.com/seedds/nxnative/issues/1326)

Also tested on current upstream main (commit 1794a35a, 8 Nov 2026, shader chain 579d06bf3932, clean build): still dies at the same cutscene. 4 GPU hangs, then 28 ignored submissions and access revoked, at frame 4204, after steady 33.3 ms frames at a 30 fps cap. Do not play past the autosave before that cutscene.
## Tips
- Back up your save folder before testing anything.
- Check logs for your username before sharing them.
## Files
- launchers/ - play scripts. play_oot_kws.sh is the one used for the 1080p setup above.
- scripts/build_fork.sh, after_build.sh - build helpers used for the kid-with-sword-remake fork build.
- scripts/ladder_kws.sh, ladder2.sh ... ladder5.sh - settings test "ladders": each one launches the game from the same save with different DM_* switches and reports whether the GPU died.
- scripts/diag_kws.sh, diagnose.sh - read a run log: shader library, pipeline archive, GPU hangs, frame times.
- scripts/run_all.sh - runs the diagnostics together.

Paths in the scripts assume the build folders and backups in your home folder (for example ~/oot-kws-build and ~/oot_saves_pre_cutscene). Edit them for your setup.
