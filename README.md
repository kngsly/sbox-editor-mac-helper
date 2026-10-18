# sbox-editor-mac-helper

Notes, scripts and one small patch from an attempt to run the **s&box editor on an Apple Silicon Mac** by
building [Facepunch/sbox-public](https://github.com/Facepunch/sbox-public) from source (its `Setup.sh` has a
macOS arm64 path).

## Status (honest summary)

| | |
|---|---|
| Builds and starts | Yes. `sbox-dev` (editor) and `sbox-launcher` both boot, init Steam, create a Vulkan device and draw UI. |
| Stable | **No** on the reference machine (M1, 8 GiB): the GPU device was lost (`VK_ERROR_DEVICE_LOST`) after ~660 frames while GPU memory was at 99% of its budget. See [docs/findings.md](docs/findings.md). |
| Project create/open, play mode, sbox-cli, hosting | **Not established.** The one project-open attempt in the logs failed because the project folder did not exist. Nothing here proves these work or do not work. |
| Native tools (Hammer, ModelDoc, Animgraph) | Unavailable by design on non-Windows. |

If you only need to certify a library or server against s&box, use Windows. Results from this setup are not
editor evidence.

Reference machine: MacBook (Apple M1, 8 GiB), macOS 26.5.1, engine commit `0de6fc3`
(2026-10-07), .NET SDK 10.0.401 / runtime 10.0.12, Steam running and signed in. Tested 2026-10-09 to 2026-10-19.
Not tested: Intel Macs (unsupported upstream), M2 and later, 16 GiB or more.

## What is here

| Path | What |
|---|---|
| `scripts/install-dotnet.sh` | Private .NET 10 SDK in `~/.sbox-dotnet`, leaves any system dotnet alone. |
| `scripts/setup-engine.sh` | Clone `Facepunch/sbox-public`, check out the pinned commit, apply the patch, run upstream `Setup.sh`. |
| `scripts/launch-editor.sh` | Run `game/sbox-dev` with the right `DOTNET_ROOT`. |
| `scripts/make-launcher-app.sh` | Create a Dock-able `s&box Launcher.app` that wraps `sbox-launcher` (or `sbox-dev` with `--editor`). |
| `patches/skip-render-when-occluded.patch` | Stop rendering fully covered editor windows. |
| `docs/findings.md` | Log signatures, what each meant, what helped. |

## Quick start

```sh
git clone https://github.com/kngsly/sbox-editor-mac-helper && cd sbox-editor-mac-helper
sh scripts/install-dotnet.sh
sh scripts/setup-engine.sh            # SBOX_COMMIT=<sha> SBOX_DIR=<dir> to override
sh scripts/make-launcher-app.sh       # optional Dock shortcut
sh scripts/launch-editor.sh
```

Verification status of these scripts: `shellcheck` clean, `make-launcher-app.sh` run and its `Info.plist`
validated with `plutil -lint`, the patch checked with `git apply --check` against the upstream files at
`0de6fc3`. `install-dotnet.sh` and `setup-engine.sh` were **not re-run end to end** when this repo was written;
they reproduce the layout of the original manual setup.

## Rules that mattered

* **Pin the commit.** `Setup.sh` downloads prebuilt macOS arm64 native libraries. Moving the managed code
  forward without matching natives gives interop mismatches. Re-pin deliberately.
* **Steam must be running and signed in** (`SteamAPI_Init`, AppID 590830); without it web auth tickets and the
  embedded web surface are unavailable.
* Rendering uses Vulkan through the bundled `libvulkan_kosmickrisp.dylib` (Mesa KosmicKrisp), not Metal directly.

## Licence

Scripts and docs: MIT. `patches/` is a modification of Facepunch's MIT-licensed engine source
(Copyright (c) 2025 Facepunch Studios Ltd) and stays under that licence. Prebuilt native binaries in the engine are
under the s&box EULA and are not distributed here. Not affiliated with or endorsed by Facepunch.
