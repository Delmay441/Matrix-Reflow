# Matrix Reflow

A native Windows 10/11 screensaver recreation of the *Matrix* digital rain — built with Direct3D 11 and DirectWrite, with bloom, HDR, and a toggleable CRT emulation pass on top.

Matrix Reflow is based on DigitalChewie's Windows port of [**Modern Matrix**](https://github.com/DigitalChewie), a macOS/Metal recreation of XScreenSaver's legendary **GLMatrix**. It's inspired by [Rezmason's](https://github.com/Rezmason/matrix) beloved WebGL Matrix rain — one of the definitive modern takes on the effect.

It's still built on the shared Modern Matrix "engine" (`mmcore`), the portable C simulation core that also drives the macOS version — but Matrix Reflow has diverged substantially enough from both the original Mac version and DigitalChewie's Windows port (in rendering, effects, and settings) that it's grown into its own thing under its own name, rather than staying a straight port.

Glyphs are rasterized at build time from an embedded font into a fixed-cell atlas via DirectWrite/Direct2D — mirroring the macOS Core Text atlas — so nothing needs to be installed system-wide and there's no runtime font dependency.

The renderer paces itself to the display's refresh rate (with tearing/VRR support for G-Sync/FreeSync), uses MMCSS + a raised timer resolution for smooth frame pacing, and multi-monitor `/s` runs spin up one window and renderer per physical display.

## Requirements

- Windows 10 or 11, x64
- A Direct3D 11–capable GPU
- To build: Visual Studio Build Tools 2022 with the "Desktop development with C++" workload (for `cl.exe`, `rc.exe`, and `fxc.exe`)

## Building

Everything is driven by `windows/build.ps1`, which locates your MSVC install via `vswhere`, precompiles the HLSL shaders offline with `fxc.exe` into C arrays (so nothing is compiled at runtime), and links a single self-contained `MatrixReflow.scr` — an ordinary Win32 PE just renamed with a `.scr` extension.

```powershell
windows\build.ps1              # build windows\MatrixReflow.scr
windows\build.ps1 -Test        # build + run the mmcore link-test (sanity check, no .scr)
windows\build.ps1 -Run         # build, then launch full-screen (/s)
windows\build.ps1 -Configure   # build, then open the settings dialog (/c)
windows\build.ps1 -Shot        # build, then render a headless PNG (windows\build\shot.png)
windows\build.ps1 -Clean       # remove build artifacts
```

There's nothing to ship at runtime beyond the `.scr` itself — the font is embedded and the shaders are precompiled.

## Installing

**As your own screensaver (no admin required):**

```powershell
windows\install.ps1
```

Copies `MatrixReflow.scr` to `%LOCALAPPDATA%\MatrixReflow`, points your screensaver settings at it, and applies the change immediately. Your previous screensaver choice is remembered.

```powershell
windows\uninstall.ps1
```

Removes it and restores whatever screensaver you had before.

**To also list it in the classic "Screen Saver Settings" dropdown for all users** (elevated prompt required):

```powershell
windows\install-systemwide.ps1
```

Then open `control desk.cpl,,@screensaver` and pick **Matrix Reflow**.

## Usage

Like any `.scr`, it responds to the standard screensaver command-line switches:

| Switch | Behavior |
| --- | --- |
| `/s` | Run full-screen (the real screensaver) — one window per monitor, exits on any input |
| `/p <HWND>` | Preview inside a given parent window (the small preview box) |
| `/c[:<HWND>]` | Open the settings dialog |
| *(none)* | Same as `/c` |
| `/w` | Run in a normal resizable window (development / screenshots) |
| `/shot <path.png> [frames] [w] [h]` | Headless render to a PNG, no window shown |

Settings and profiles are stored per-user under `HKCU\Software\Chewie\MatrixReflow`. Logs are written to `%LOCALAPPDATA%\MatrixReflow\MatrixReflow.log` (append-across-runs, rotated past ~1 MB) — useful since a screensaver has no console of its own.

## How it's built

- **Renderer** — Direct3D 11, with a glyph pass, a bloom chain (threshold → downsample/upsample mip chain → composite), and an optional CRT emulation filter, all as precompiled shader blobs baked into the binary.
- **Glyph atlas** — an embedded font rasterized once at startup into an R8 mip-mapped texture via a private, in-memory DirectWrite font collection (no OS-wide font install or registration), falling back to Arial if that path is unavailable.
- **Simulation core (`mmcore`)** — portable C99 owning the rain simulation, settings model, and glyph-instance layout; rooted in the same engine as the macOS build, though Matrix Reflow's settings and behavior have since diverged from it.
- **Settings dialog** — a native Win32 tabbed dialog (sliders, color pickers, presets, profile management) with a live preview pane.
- **Host shell** — a small Win32 shell that parses the standard screensaver switches, manages one window/renderer per monitor in full-screen mode, and paces frames to the display's refresh rate (VRR-aware).

## Acknowledgements

- [**Modern Matrix**](https://github.com/DigitalChewie/ModernMatrixScreensaver) by DigitalChewie — the macOS/Metal original, and source of the Windows port Matrix Reflow is based on and the shared simulation core it still builds on.
- [**Rezmason's Matrix**](https://github.com/Rezmason/matrix) — the WebGL rain that's been a north star for what this effect should look and feel like.
- **XScreenSaver's GLMatrix** — the original 3D digital rain this whole lineage traces back to.
