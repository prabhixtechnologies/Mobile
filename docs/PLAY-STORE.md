# Play Store (Flutter)

See the canonical playbook: [`../Infra/docs/PLAY-STORE.md`](../Infra/docs/PLAY-STORE.md) from the workspace root.

```powershell
powershell -File scripts/build-play-aabs.ps1
```

AABs land in `build/play/`. Signing uses `android/key.properties` → `D:\Projects\KEYS\prabhix-play-upload.jks`.
