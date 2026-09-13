# Native mobile — freeze / archive policy

These trees ship until the matching Flutter app in `../../Mobile/apps/` passes parity
and a release APK/IPA is on the store (or internal channel for Admin).

| Native tree | Flutter replacement | Freeze when |
| --- | --- | --- |
| `oneOps/mobile/android` (+ unfinished `ios`) | `Mobile/apps/oneops`, `Mobile/apps/admin` | Flutter OneOps + Admin release cutover |
| `Mailroom/android` | `Mobile/apps/mailroom` | Flutter Mailroom release cutover |
| `MobiStack/mobile` (Expo) | `Mobile/apps/mobistack` | Flutter MobiStack release cutover + Identity-only field confirmation |

Do not delete these folders until the cutover checklist in `Mobile/CUTOVER.md` is signed off.
After cutover, move them to an `archive/` branch or delete in a dedicated PR.
