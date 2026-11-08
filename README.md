# ocarinaforyou

### The Legend of Zelda: Ocarina of Time, running natively on a MacBook Air M2

This repo is my fork of [seedds/nxnative](https://github.com/seedds/nxnative), the project that runs Switch games natively on Apple hardware. Here I document how far Ocarina of Time (Switch 2 version) gets on a 16 GB M2 Air, what settings give the best picture, and the one problem that still stops it.

---

## At a glance

| | |
|---|---|
| Game | The Legend of Zelda: Ocarina of Time, title ID 0400486024DEC000, v131072 |
| Source | the game's own .nup file, supplied by you (nothing is included here) |
| Machine | MacBook Air M2 (Mac14,2), 16 GB, macOS 27.2, Xcode 27.2 |
| Picture | 1080p with MetalFX upscaling, steady 16.7 ms frames |
| Status | plays well until the Saria / ocarina cutscene, then the GPU hangs |
| Upstream issue | [#1690](https://github.com/seedds/nxnative/issues/1690), related [#1326](https://github.com/seedds/nxnative/issues/1326) |

---

## What works

Kokiri Forest and everything before the ocarina cutscene runs at a steady 16.7 ms a frame at 1080p. The best settings I found:

    DM_RENDER_SCALE=0.75 DM_PSO_MTL4=0 DM_FPS_TARGET=30 DM_PRESENT_UPSCALE=metalfx DM_NVN_TEX_SOFT=0

Render scale 0.75 of the 2560x1440 docked base is exactly 1920x1080, and MetalFX scales it to the screen.

## What does not work yet

When Saria gives Link the ocarina on leaving Kokiri Forest, the GPU hangs. The log shows a run of GPU errors, then Metal ignores all further submissions, access is revoked and the game quits to a black screen.

From an autosave just before the cutscene, 6 of 6 runs died within 158 to 241 seconds. The result did not change with any of these:

| Tried | Result |
|---|---|
| Render scale 0.5 and 0.75 | hangs |
| Handheld mode | hangs |
| Smaller command-buffer cuts, with full barriers | hangs |
| Pipeline archive off (DM_PSO_MTL4=0) | hangs |
| Soft and full textures | hangs |
| MetalFX on and off | hangs |

Resource checking (DM_RES_CHECK=1) reported 0 resources released too early and 0 missing residency, so it does not look like a simple lifetime bug. GPU memory at the time of death was 6.7 to 11.9 GB.

I also tested current upstream main (commit 1794a35a, 8 Nov 2026) from a clean build, and it still hangs at the same cutscene: 4 GPU hangs, then access revoked, at frame 4204. Until it is fixed upstream: do not play past the autosave before that cutscene.

---

## What is in this repo

| Path | What it is |
|---|---|
| [oot/README.md](oot/README.md) | the full notes, settings and known problem |
| [oot/launchers/](oot/launchers) | play scripts, play_oot_kws.sh being the best one |
| [oot/scripts/](oot/scripts) | build helpers, the settings test ladders, and the log diagnostics |
| everything else | unchanged upstream nxnative code |

## How the testing worked

Each test ladder script starts the game from the same save, applies one set of settings, and reports how long the run lasted, whether the GPU died, the peak GPU memory and the render sizes. Using one save for every run is what shows the hang is repeatable and tied to that cutscene, not to the settings.

---

## Not included

No game files, no keys, no saves, no shader caches and no logs. You need your own legally dumped copy of the game. The upstream project explains how to build from it.

## Credits

All the emulation work is [seedds/nxnative](https://github.com/seedds/nxnative) and its contributors. This repo only adds notes and test scripts for one game.
