# Findings

Collected from the engine logs of the reference machine (M1, 8 GiB, macOS 26.5.1, engine `0de6fc3`),
2026-10-09 to 2026-10-19. Identifiers and paths are removed. "Seen" means present in logs; causes are only
stated where the log or a test showed them, everything else is marked as a hypothesis.

## Startup timings (editor/launcher)

| Phase | Slowest run seen | Fastest run seen |
|---|---|---|
| Interop | 2.8 s | 24-180 ms |
| Managed init | 0.8 s | 0.4-0.6 s |
| `SourceEnginePreInit` | 7.1 s | 0.7-1.3 s |
| First frame | 6.0 s | 0.4-0.5 s |

## Log signatures

| Signature | Meaning | Action |
|---|---|---|
| `Vulkan Physical Device: Apple M1`, `Driver: KosmicKrisp Mesa 26.3.0-devel`, Vulkan 1.4 | Normal. Renders through the bundled `libvulkan_kosmickrisp.dylib`. | None. |
| `Disabling VK_EXT_graphics_pipeline_library dependent extensions` | Driver lacks it. | None, informational. |
| `VK_POLYGON_MODE_LINE but ... fillModeNonSolid is not supported` | Wireframe draws as filled. | Cosmetic. |
| `Hammer / ModelDoc / Animgraph is unavailable. Native tools aren't supported on non-Windows builds.` | Expected. | None. |
| `Unable to capture ... Source2PreInit ... virtual memory information` | Seen on every start. | Ignore. |
| `WebSurface unavailable - SteamHTMLSurface is null`; `RequestWebAuthTicket: SteamUser() returned null` | Steam web features unavailable (the second line when Steam is not initialised). | Start and sign in to Steam first. |
| `FrameSync: GPU fence wait exceeded 250ms, idling the queue` + `QueuePresentAndWait() looped for ~24 iterations without a present event`, repeating every ~0.5 s | Rendering stalls. The original local patch comment attributes this to Metal blocking while acquiring a drawable for a covered (occluded) window; that diagnosis was not verified with a controlled test. | `patches/skip-render-when-occluded.patch`: skip drawing an already-shown window that SDL reports as occluded (`SDL_WINDOW_OCCLUDED = 0x4`), still pump events. Compiled and used, but no controlled before/after measurement was taken. |
| `ERROR! VK call failed! result = VK_ERROR_DEVICE_LOST (-4) ( vkQueueSubmit2 ... )`, `FrameSync() failed waiting for 1 fences`, then `GPU CRASH DIAGNOSTICS` | **The crash.** Frame 664, graphics queue. The same report shows `Memory heap 0 (device local): 5419 MiB used of 5461 MiB budget`. | No fix found. Hypothesis (untested): memory pressure on an 8 GiB unified-memory machine. The engine itself suggests relaunching with `-gpu_diagnostics` (or `-gpu_diagnostics_dev`) for breadcrumbs; `VK_EXT_device_fault` was not enabled so no fault address was available. |
| `Couldn't create the SDL window: Failed to load Vulkan Portability library` | Seen once, on the very first launch (2026-10-09). Did not recur in later runs. | Cause not isolated. |
| `NullReferenceException` in `Editor.AssetType.Init()` via `AssetSystem.RegisterAssetType` (56x) | Seen once, on the first run (2026-10-09), during editor asset type registration. Startup continued. Did not recur. | Probably asset types backed by Windows-only native tools; not confirmed. |
| `Project config error (Assert: <projects dir>/my_project does not exist) - deactivating project` | The launcher had a project entry whose folder was absent, so opening failed. Seen twice, 2026-10-19. | Check that the folder exists before opening. Why the folder was missing was not investigated. |
| `Failed to load startup scene` (dedicated `sbox-server`) | Seen once on 2026-10-11. | Not investigated. |

## Things the engine told us that matter for planning

* Native tools missing means no Hammer, ModelDoc or Animgraph; a code-first workflow (C# libraries, components,
  scenes) is the realistic scope on macOS.
* An 8 GiB machine is at the edge: the device-local budget reported was 5461 MiB and was nearly full at the crash.

## Not established

Creating a project from the launcher, opening one in the editor, play mode, `sbox-cli` against the Mac editor,
hosting, and behaviour on other Apple Silicon models or RAM sizes.
