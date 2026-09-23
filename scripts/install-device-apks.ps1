# Sideload signed release APKs onto a USB device.
# Play-installed copies must be uninstalled first (different signing cert).
$ErrorActionPreference = "Stop"
$env:Path = "C:\src\flutter\bin;" + $env:LOCALAPPDATA + "\Android\Sdk\platform-tools;" + $env:Path
$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root "build\play"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$apps = @(
    @{ Name = "admin";     Pkg = "com.prabhix.admin";     Api = "https://api.prabhixtechnologies.com/api/v1" }
    @{ Name = "mailroom";  Pkg = "com.prabhix.mailroom";  Api = "https://api.prabhixtechnologies.com/api/v1" }
    @{ Name = "oneops";    Pkg = "com.prabhix.operator";  Api = "https://api.prabhixtechnologies.com/api/v1" }
    @{ Name = "mobistack"; Pkg = "app.prabhix.fixflow";   Api = "https://mobistack.prabhixtechnologies.com/api/v1" }
)

$devices = adb devices | Select-String "\tdevice$"
if (-not $devices) { throw "No adb device. Plug in the phone and enable USB debugging." }

foreach ($app in $apps) {
    $dir = Join-Path $root "apps\$($app.Name)"
    Write-Host "=== $($app.Name) apk ===" -ForegroundColor Cyan
    Push-Location $dir
    try {
        flutter build apk --release --target-platform android-arm64 `
            --dart-define=IDENTITY_ISSUER=https://api.prabhixtechnologies.com `
            --dart-define=API_BASE_URL=$($app.Api)
        if ($LASTEXITCODE -ne 0) { throw "flutter build apk failed for $($app.Name)" }
        $apk = Join-Path $dir "build\app\outputs\flutter-apk\app-release.apk"
        Copy-Item $apk (Join-Path $outDir "$($app.Name)-release.apk") -Force
        adb uninstall $($app.Pkg) 2>$null | Out-Null
        adb install -r $apk
        if ($LASTEXITCODE -ne 0) { throw "adb install failed for $($app.Name)" }
        Write-Host "Installed $($app.Pkg)"
    } finally {
        Pop-Location
    }
}

Write-Host "All four APKs on the device. Sideload copies: $outDir\*-release.apk"
