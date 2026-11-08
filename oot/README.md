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

Do not play past the autosave before that cutscene. Not yet tested on current upstream main.

## Tips
- Back up your save folder before testing anything.
- Check logs for your username before sharing them.
