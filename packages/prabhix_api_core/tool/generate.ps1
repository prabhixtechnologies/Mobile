# Generate Dart Dio clients from committed OpenAPI snapshots.
#
# Looks for apidocs.json in sibling checkouts (oneOps, MobiStack) or in
# ONEOPS_APIDOCS / MOBISTACK_APIDOCS. Requires Node (npx @openapitools/openapi-generator-cli).
#
# Usage (from this package, or any cwd):
#   powershell -File tool/generate.ps1
#   pwsh tool/generate.ps1

$ErrorActionPreference = "Stop"
$pkgRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$workspaceRoot = Resolve-Path (Join-Path $pkgRoot "..\..\..") # PrabhixTechnologies when checked out as siblings
$outRoot = Join-Path $pkgRoot "lib\generated"

function Find-Apidocs([string]$envName, [string]$relative) {
    $fromEnv = [Environment]::GetEnvironmentVariable($envName)
    if ($fromEnv -and (Test-Path $fromEnv)) { return (Resolve-Path $fromEnv).Path }
    $sibling = Join-Path $workspaceRoot $relative
    if (Test-Path $sibling) { return (Resolve-Path $sibling).Path }
    return $null
}

function Invoke-DartDio([string]$spec, [string]$name) {
    $dest = Join-Path $outRoot $name
    $staging = Join-Path $pkgRoot ".dart_tool\openapi-$name"
    if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
    New-Item -ItemType Directory -Path $staging | Out-Null
    Write-Host "Generating $name from $spec"
    npx --yes @openapitools/openapi-generator-cli generate `
        -i $spec `
        -g dart-dio `
        -o $staging `
        --skip-validate-spec `
        --additional-properties=pubName=prabhix_${name}_api,pubLibrary=prabhix_$name,serializationLibrary=json_serializable,useEnumExtension=true
    if ($LASTEXITCODE -ne 0) { throw "openapi-generator-cli failed for $name" }

    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
    New-Item -ItemType Directory -Path $dest | Out-Null
    $libSrc = Join-Path $staging "lib"
    if (Test-Path $libSrc) {
        Copy-Item -Path (Join-Path $libSrc "*") -Destination $dest -Recurse -Force
    } else {
        Copy-Item -Path (Join-Path $staging "*") -Destination $dest -Recurse -Force
    }
    Write-Host "Wrote $dest"
}

$oneOps = Find-Apidocs "ONEOPS_APIDOCS" "oneOps\backend\apidocs.json"
$mobi = Find-Apidocs "MOBISTACK_APIDOCS" "MobiStack\backend\apidocs.json"

if (-not $oneOps -and -not $mobi) {
    Write-Host "No apidocs.json found. Set ONEOPS_APIDOCS / MOBISTACK_APIDOCS or check out oneOps and MobiStack next to Mobile."
    exit 0
}

if ($oneOps) { Invoke-DartDio $oneOps "oneops" }
if ($mobi) { Invoke-DartDio $mobi "mobistack" }

Write-Host "Done. Hand-written models in lib/src/models.dart remain the app facade."
