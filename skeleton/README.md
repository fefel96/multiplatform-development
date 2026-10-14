# MMP Course Development Project

*Students*

- <UID> - Firstname Lastname
- <UID> - Firstname Lastname
- <UID> - Firstname Lastname
- <UID> - Firstname Lastname

## Input system

The shared `InputSystem` API lives in `src/input/InputSystemAPI.h`; native polling is
implemented in `src/input/InputSystem.cpp`. The current Windows backend uses XInput
and polls controller index 0 once per `Update()`. Face buttons are mapped by their
physical position (A/Cross = down, B/Circle = right, X/Square = left, Y/Triangle =
top), alongside the D-pad and shoulder buttons. `ApplyVibrationEffect` applies the
same 0-65535 motor value to both XInput motors.

### Design choice

The platform backend is selected at compile time (`PLATFORM_WINDOWS` or
`PLATFORM_PROSPERO`), while the button snapshot and action-query logic is shared.
This keeps native SDK headers out of the public API and avoids a runtime factory
and virtual backend when each build targets only one platform. A runtime-polymorphic
backend would be preferable if the application needed to switch devices/platform
implementations in one process; duplicated complete implementations would make
button/action behavior harder to keep consistent.

`Update()` stores the preceding and current button masks. This makes hold, pressed,
and released queries stable for all queries in the same frame. A regular disconnect
is treated as an empty state, so held buttons stop reporting hold and can report a
release for that frame. Unexpected XInput errors are printed to `stderr`; vibration
is skipped while disconnected, and values are clamped to the native 16-bit motor
range.

### PS5 / DualSense preparation

The `PLATFORM_PROSPERO` implementation is intentionally not enabled yet: its build
stops with an explicit error rather than silently returning empty input. The native
adapter should use the PS5 SDK's `<pad.h>` and follow this lifecycle:

```cpp
scePadInit();
ScePadHandle handle = scePadOpen(userId, SCE_PAD_PORT_TYPE_STANDARD, 0, nullptr);
ScePadData data = {};
scePadReadState(handle, &data);
// Map SCE_PAD_BUTTON_CROSS/CIRCLE/SQUARE/TRIANGLE, the D-pad, and L1/R1
// in the same shared button mask used by the Windows adapter.
ScePadVibrationParam vibration = {};
// Set both motor intensities, then call scePadSetVibration(handle, &vibration).
scePadClose(handle);
scePadTerm();
```

The PS5 adapter must also initialize/obtain the active user through the user-service
API, check every SCE return value, and close the pad/terminate pad services on
shutdown. Exact initialization parameters and available structures depend on the
installed Prospero SDK and should be verified against that SDK before enabling
`PLATFORM_PROSPERO`.
