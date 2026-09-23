# Build Play-signed Android App Bundles for all four Flutter apps.
# Requires D:\Projects\KEYS\prabhix-play-upload.jks (see Infra/docs/PLAY-STORE.md).
$ErrorActionPreference = "Stop"
$env:Path = "C:\src\flutter\bin;" + $env:Path
$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root "build\play"

$apps = @(
    @{ Name = "admin";     Api = "https://api.prabhixtechnologies.com/api/v1" }
    @{ Name = "mailroom";  Api = "https://api.prabhixtechnologies.com/api/v1" }
    @{ Name = "oneops";    Api = "https://api.prabhixtechnologies.com/api/v1" }
    @{ Name = "mobistack"; Api = "https://mobistack.prabhixtechnologies.com/api/v1" }
)

New-Item -ItemType Directory -Force -Path $outDir | Out-Null

foreach ($app in $apps) {
    $dir = Join-Path $root "apps\$($app.Name)"
    Write-Host "=== $($app.Name) appbundle ===" -ForegroundColor Cyan
    Push-Location $dir
    try {
        flutter build appbundle --release `
            --dart-define=IDENTITY_ISSUER=https://api.prabhixtechnologies.com `
            --dart-define=API_BASE_URL=$($app.Api)
        if ($LASTEXITCODE -ne 0) { throw "flutter build appbundle failed for $($app.Name)" }
        $aab = Join-Path $dir "build\app\outputs\bundle\release\app-release.aab"
        Copy-Item $aab (Join-Path $outDir "$($app.Name)-release.aab") -Force
        Write-Host "Wrote $outDir\$($app.Name)-release.aab"
    } finally {
        Pop-Location
    }
}

Write-Host "All AABs in $outDir"
