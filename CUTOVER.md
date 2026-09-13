# Flutter release cutover (store + S3)

Native Kotlin / Expo APKs remain on `s3://prabhix-apk-downloads/` until each Flutter app
passes its parity checklist (see MOBILE-FLUTTER.md).

## Automatic (preferred)

Every push to `main` (and manual **workflow_dispatch**) on
[prabhixtechnologies/Mobile](https://github.com/prabhixtechnologies/Mobile)
builds OneOps / Mailroom / MobiStack APKs and uploads:

```
s3://prabhix-apk-downloads/{product}/android.apk
s3://prabhix-apk-downloads/{product}/latest.apk
```

Public downloads (via app-store):

- https://store.prabhixtechnologies.com/mobistack/android.apk
- https://store.prabhixtechnologies.com/oneops/android.apk
- https://store.prabhixtechnologies.com/mailroom/android.apk

Admin stays internal (GitHub Actions artifact `prabhix-admin` — not on the public store).

### Status check (Option B)

| Step | Status |
|------|--------|
| GitHub variable `AWS_APK_ROLE_ARN` | Set (role assume works via OIDC) |
| Analyze + APK build on `main` | Passing |
| S3 `PutObject` to `prabhix-apk-downloads` | **Blocked** — CI role has no S3 write policy |
| Store URLs serving Flutter builds | Not yet (still older artifacts until S3 works) |
| Release signing secrets | Optional next — unsigned release sideloads; Play/update continuity needs keystore |

### IAM (one-time, AWS root / IAM admin — `prabhix` IAM user cannot do this)

```bash
# From Infra/
aws iam create-policy \
  --policy-name PrabhixApkS3Push \
  --policy-document file://deploy/aws/apk-s3-push-policy.json

aws iam attach-role-policy \
  --role-name prabhix-github-ecr-push \
  --policy-arn arn:aws:iam::029096972251:policy/PrabhixApkS3Push
```

Then re-run **Flutter mobile CI** → **Run workflow** on `main` (workflow_dispatch), or push
another commit. No long-lived AWS keys needed — the workflow uses OIDC (`id-token: write`).

Signing: follow `ANDROID-RELEASE-SIGNING.md` (same keystores / applicationIds as natives so
Play continuity is preserved).

## Manual

```bash
cd apps/<app>
flutter build apk --release \
  --dart-define=IDENTITY_ISSUER=https://api.prabhixtechnologies.com \
  --dart-define=API_BASE_URL=https://api.prabhixtechnologies.com/api/v1
# mobistack API_BASE_URL=https://mobistack.prabhixtechnologies.com/api/v1
# admin also: MOBISTACK_API_BASE_URL=https://mobistack.prabhixtechnologies.com/api/v1

aws s3 cp build/app/outputs/flutter-apk/app-release.apk \
  s3://prabhix-apk-downloads/<oneops|mailroom|mobistack>/android.apk
aws s3 cp build/app/outputs/flutter-apk/app-release.apk \
  s3://prabhix-apk-downloads/<product>/latest.apk
```

## After Flutter MobiStack is in the field

Drop MobiStack HS256 product auth per IDENTITY.md. Archive:

- `oneOps/mobile/android`, `oneOps/mobile/ios`
- `Mailroom/android`
- `MobiStack/mobile` (Expo)

until then keep shipping natives alongside Flutter CI artifacts.
