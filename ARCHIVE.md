# Native mobile — archived

Flutter in `Mobile/apps/` is the only mobile codebase that takes new work. The
native trees were frozen, then archived onto dedicated branches after cutover.

| Native tree | Archive branch (from last committed HEAD) | Flutter replacement |
| --- | --- | --- |
| `oneOps/mobile` (Kotlin + unfinished SwiftUI) | `archive/native-oneops` in the OneOps repo | `Mobile/apps/oneops`, `Mobile/apps/admin` |
| `Mailroom/android` (Kotlin) | `archive/native-mailroom` in the Mailroom repo | `Mobile/apps/mailroom` |
| `MobiStack/mobile` (Expo) | `archive/native-mobistack` in the MobiStack repo | `Mobile/apps/mobistack` |

Restore a tree locally with `git checkout archive/native-<product> -- <path>`.
Do not copy natives back onto `main`. Release APKs come from Flutter CI; see
`CUTOVER.md`.
