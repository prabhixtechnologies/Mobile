# Generated OpenAPI clients

Dart Dio sources for oneOps and MobiStack live in `oneops/` and `mobistack/`.
They are produced from the committed `apidocs.json` snapshots:

```powershell
powershell -File tool/generate.ps1
```

Set `ONEOPS_APIDOCS` / `MOBISTACK_APIDOCS` if the backends are not siblings of
this `Mobile` checkout. Requires Node (`npx @openapitools/openapi-generator-cli`).
The generator is invoked with `--skip-validate-spec` because the oneOps snapshot
is OpenAPI 3.1 and fails the generator's 3.0 path-parameter check.

The dump is a **standalone json_serializable client** (`package:prabhix_oneops_api`
/ `package:prabhix_mobistack_api`). It is not wired into `prabhix_api_core` yet:
adopting it needs `json_annotation`, `copy_with_extension`, `build_runner`, and
import path rewrites. Until then `lib/src/models.dart` remains the app facade
(`AuthMe.fromJson` still maps MobiStack `shopId` onto `organizations`). Apps keep
importing `package:prabhix_api_core/prabhix_api_core.dart`.

Analyzer excludes `lib/generated/oneops/**` and `lib/generated/mobistack/**`.

CI in this repository does not regenerate (the snapshots live in other repos).
It only asserts this README exists. oneOps and MobiStack CI regenerate the
TypeScript packages and fail on drift.
