# Prabhix Mobile (Flutter)

Melos workspace replacing product-by-product natives. See `../Infra/docs/MOBILE-FLUTTER.md`
and `CUTOVER.md`.

```powershell
$env:Path = "C:\src\flutter\bin;" + $env:Path
cd Mobile\apps\admin   # or mailroom | oneops | mobistack
flutter pub get
flutter run --dart-define=IDENTITY_ISSUER=http://10.0.2.2:8081 --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
# mobistack: API_BASE_URL=http://10.0.2.2:8085 (or prod https://mobistack.prabhixtechnologies.com)
flutter build apk --debug --dart-define=IDENTITY_ISSUER=https://api.prabhixtechnologies.com --dart-define=API_BASE_URL=https://api.prabhixtechnologies.com/api/v1
```

Apps: `admin`, `mailroom`, `oneops`, `mobistack`.
Packages: `prabhix_identity`, `prabhix_api_core`, `prabhix_offline`.

**Downloads (auto-updated on every `main` push):**  
https://store.prabhixtechnologies.com/mobistack/android.apk ·  
https://store.prabhixtechnologies.com/oneops/android.apk ·  
https://store.prabhixtechnologies.com/mailroom/android.apk  

See `CUTOVER.md` for S3 / IAM details.

Package IDs and OAuth redirects are frozen (same as natives). Do not rename.
