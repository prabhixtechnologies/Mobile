# Flutter release cutover (store + S3)

Native Kotlin / Expo APKs remain on `s3://prabhix-apk-downloads/` until each Flutter app
passes its parity checklist (see MOBILE-FLUTTER.md).

## Automatic (preferred)

Every push to `main` on [prabhixtechnologies/Mobile](https://github.com/prabhixtechnologies/Mobile)
builds OneOps / Mailroom / MobiStack APKs and uploads:

```
s3://prabhix-apk-downloads/{product}/android.apk
s3://prabhix-apk-downloads/{product}/latest.apk
```

Public downloads (via app-store):

- https://store.prabhixtechnologies.com/mobistack/android.apk
- https://store.prabhixtechnologies.com/oneops/android.apk
- https://store.prabhixtechnologies.com/mailroom/android.apk

**IAM:** GitHub OIDC must assume a role that can `s3:PutObject` (and `s3:AbortMultipartUpload`)
on `arn:aws:s3:::prabhix-apk-downloads/*`. Set repository variable `AWS_APK_ROLE_ARN` if that
permission is not already on `prabhix-github-ecr-push`.

Admin stays internal (GitHub Actions artifact only — not on the public store).

## Manual

```bash
cd apps/<app>
flutter build apk --release \
  --dart-define=IDENTITY_ISSUER=https://api.prabhixtechnologies.com \
  --dart-define=API_BASE_URL=https://api.prabhixtechnologies.com/api/v1
# mobistack API_BASE_URL=https://mobistack.prabhixtechnologies.com/api/v1

aws s3 cp build/app/outputs/flutter-apk/app-release.apk \
  s3://prabhix-apk-downloads/<oneops|mailroom|mobistack>/android.apk
aws s3 cp build/app/outputs/flutter-apk/app-release.apk \
  s3://prabhix-apk-downloads/<product>/latest.apk
```

Signing: follow `ANDROID-RELEASE-SIGNING.md` (same keystores / applicationIds as natives so
Play continuity is preserved).

## After Flutter MobiStack is in the field

Drop MobiStack HS256 product auth per IDENTITY.md. Archive:

- `oneOps/mobile/android`, `oneOps/mobile/ios`
- `Mailroom/android`
- `MobiStack/mobile` (Expo)

until then keep shipping natives alongside Flutter CI artifacts.
