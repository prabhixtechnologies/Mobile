# Flutter release cutover (store + S3)

Native Kotlin / Expo APKs remain on `s3://prabhix-apk-downloads/` until each Flutter app
passes its parity checklist (see MOBILE-FLUTTER.md). Then:

```bash
cd Mobile/apps/<app>
flutter build apk --release \
  --dart-define=IDENTITY_ISSUER=https://api.prabhixtechnologies.com \
  --dart-define=API_BASE_URL=https://api.prabhixtechnologies.com/api/v1
# mobistack API_BASE_URL=https://mobistack.prabhixtechnologies.com

aws s3 cp build/app/outputs/flutter-apk/app-release.apk \
  s3://prabhix-apk-downloads/<oneops|mailroom|mobistack>/android.apk
aws s3 cp build/app/outputs/flutter-apk/app-release.apk \
  s3://prabhix-apk-downloads/<product>/latest.apk
```

Admin stays internal (not on the public store).

Signing: follow `ANDROID-RELEASE-SIGNING.md` (same keystores / applicationIds as natives so
Play continuity is preserved).

## After Flutter MobiStack is in the field

Drop MobiStack HS256 product auth per IDENTITY.md. Archive:

- `oneOps/mobile/android`, `oneOps/mobile/ios`
- `Mailroom/android`
- `MobiStack/mobile` (Expo)

until then keep shipping natives alongside Flutter debug CI artifacts.
