[CmdletBinding()]
param(
    [ValidateSet("Status", "SaveVersions", "BuildAab", "BuildApk", "InstallApk", "CommitPush", "Upload", "QuickRelease", "WatchRun")]
    [string]$Action = "Status",
    [string]$Apps = "all",
    [string]$Versions = "",
    [ValidateSet("internal", "alpha", "beta", "production")]
    [string]$Track = "internal",
    [string]$CommitMessage = "",
    [string]$Confirm = "",
    [string]$RunId = "",
    [switch]$Json,
    [switch]$DryRun,
    [switch]$AllowDirtyPreview
)

$ErrorActionPreference = "Stop"
$env:Path = "C:\src\flutter\bin;$env:LOCALAPPDATA\Android\Sdk\platform-tools;" + $env:Path
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$outDir = Join-Path $root "build\play"
$repo = "prabhixtechnologies/Mobile"
$knownPlay = @{
    mobistack = "1.3.6+16"
    oneops = "1.1.1+5"
    mailroom = "1.1.1+5"
    admin = "1.1.1+5"
}
$catalog = [ordered]@{
    admin = @{ Package = "com.prabhix.admin"; Api = "https://api.prabhixtechnologies.com/api/v1" }
    mailroom = @{ Package = "com.prabhix.mailroom"; Api = "https://api.prabhixtechnologies.com/api/v1" }
    oneops = @{ Package = "com.prabhix.operator"; Api = "https://api.prabhixtechnologies.com/api/v1" }
    mobistack = @{ Package = "app.prabhix.fixflow"; Api = "https://mobistack.prabhixtechnologies.com/api/v1" }
}

function Invoke-Tool {
    param(
        [string]$File,
        [string[]]$Arguments,
        [string]$WorkingDirectory = $root,
        [switch]$Mutating,
        [switch]$Quiet
    )
    Write-Verbose "$File $($Arguments -join ' ')"
    if ($DryRun -and $Mutating) {
        Write-Host "DRY RUN: $File $($Arguments -join ' ')"
        return [pscustomobject]@{ ExitCode = 0; Output = "" }
    }
    Push-Location $WorkingDirectory
    try {
        $prior = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        $lines = @(& $File @Arguments 2>&1 | ForEach-Object { "$_" })
        $code = $LASTEXITCODE
        $ErrorActionPreference = $prior
    } finally {
        Pop-Location
        $ErrorActionPreference = "Stop"
    }
    $text = ($lines | Out-String).TrimEnd()
    if ($text -and -not $Quiet) { Write-Host $text }
    [pscustomobject]@{ ExitCode = $code; Output = $text }
}

function Get-SelectedApps {
    if ($Apps -eq "all") { return @($catalog.Keys) }
    $selected = @($Apps.Split(",") | ForEach-Object { $_.Trim().ToLowerInvariant() } | Where-Object { $_ })
    if ($selected.Count -eq 0) { throw "Select at least one app." }
    foreach ($app in $selected) {
        if (-not $catalog.Contains($app)) { throw "Unknown app '$app'." }
    }
    @($catalog.Keys | Where-Object { $selected -contains $_ })
}

function ConvertTo-Version {
    param([string[]]$Lines, [string]$Source)
    $line = $Lines | Where-Object { $_ -match '^version:\s*' } | Select-Object -First 1
    if (-not $line -or $line -notmatch '^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$') {
        throw "Could not read a Flutter version from $Source."
    }
    [pscustomobject]@{ Text = "$($Matches[1])+$($Matches[2])"; Name = $Matches[1]; Code = [int]$Matches[2] }
}

function Get-CommittedVersion {
    param([string]$App)
    Push-Location $root
    try {
        $lines = @(& git show "HEAD:apps/$App/pubspec.yaml" 2>$null)
        $code = $LASTEXITCODE
    } finally {
        Pop-Location
    }
    if ($code -ne 0) { throw "Could not read the committed version of apps/$App/pubspec.yaml." }
    ConvertTo-Version $lines "HEAD:apps/$App/pubspec.yaml"
}

function Get-Version {
    param([string]$App)
    $path = Join-Path $root "apps\$App\pubspec.yaml"
    $line = Get-Content $path | Where-Object { $_ -match '^version:\s*' } | Select-Object -First 1
    if (-not $line -or $line -notmatch '^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$') {
        throw "Could not read a Flutter version from apps/$App/pubspec.yaml."
    }
    [pscustomobject]@{
        Text = "$($Matches[1])+$($Matches[2])"
        Name = $Matches[1]
        Code = [int]$Matches[2]
        Path = $path
        RelativePath = "apps/$App/pubspec.yaml"
    }
}

function Get-VersionMap {
    $map = @{}
    foreach ($pair in @($Versions -split ',' | Where-Object { $_ })) {
        if ($pair -notmatch '^([a-z-]+)=(\d+\.\d+\.\d+\+\d+)$') {
            throw "Invalid version entry '$pair'. Use app=major.minor.patch+code."
        }
        $map[$Matches[1]] = $Matches[2]
    }
    $map
}

function Get-StatusRows {
    foreach ($app in $catalog.Keys) {
        $version = Get-Version $app
        [pscustomobject]@{
            App = $app
            Package = $catalog[$app].Package
            LocalVersion = $version.Text
            CommittedVersion = (Get-CommittedVersion $app).Text
            RecordedPlayVersion = $knownPlay[$app]
            Pubspec = $version.RelativePath
        }
    }
}

function Assert-VersionIncrease {
    param([string]$App, [string]$Next)
    if ($Next -notmatch '^(\d+)\.(\d+)\.(\d+)\+(\d+)$') {
        throw "$App version '$Next' must be major.minor.patch+versionCode."
    }
    $nextCode = [int]$Matches[4]
    $committed = Get-CommittedVersion $App
    $nextName = "$($Matches[1]).$($Matches[2]).$($Matches[3])"
    if ($nextCode -eq $committed.Code -and $nextName -eq $committed.Name) { return }
    if ($nextCode -le $committed.Code) {
        throw "$App versionCode must be greater than the committed $($committed.Code), or left unchanged to publish that build to another track."
    }
}

function Save-Versions {
    param([string[]]$Selected, $Map)
    foreach ($app in $Selected) {
        if (-not $Map.ContainsKey($app)) { throw "No next version supplied for $app." }
        Assert-VersionIncrease $app $Map[$app]
    }
    foreach ($app in $Selected) {
        $current = Get-Version $app
        if ($current.Text -eq $Map[$app]) {
            Write-Host "${app}: already at $($current.Text)"
            continue
        }
        Write-Host "${app}: $($current.Text) -> $($Map[$app])"
        if (-not $DryRun) {
            $content = [IO.File]::ReadAllText($current.Path)
            $updated = [regex]::Replace($content, '(?m)^version:\s*\d+\.\d+\.\d+\+\d+\s*$', "version: $($Map[$app])", 1)
            if ($updated -eq $content) { throw "Version line was not updated for $app." }
            [IO.File]::WriteAllText($current.Path, $updated, (New-Object Text.UTF8Encoding($false)))
        }
    }
}

function Assert-Tools {
    param([string[]]$Names)
    foreach ($name in $Names) {
        if (-not (Get-Command $name -ErrorAction SilentlyContinue)) { throw "$name is not installed or not on PATH." }
    }
}

function Build-Apps {
    param([string[]]$Selected, [ValidateSet("aab", "apk")][string]$Kind)
    Assert-Tools @("flutter")
    if (-not (Test-Path "D:\Projects\KEYS\prabhix-play-upload.jks")) {
        throw "Play upload keystore is missing."
    }
    $properties = "D:\Projects\KEYS\prabhix-play-upload.key.properties"
    if (-not (Test-Path $properties)) { throw "Play key properties file is missing." }
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    foreach ($app in $Selected) {
        $dir = Join-Path $root "apps\$app"
        if (-not $DryRun) {
            Copy-Item $properties (Join-Path $dir "android\key.properties") -Force
        }
        $arguments = @("build", $(if ($Kind -eq "aab") { "appbundle" } else { "apk" }), "--release")
        if ($Kind -eq "apk") { $arguments += @("--target-platform", "android-arm64") }
        $arguments += @(
            "--dart-define=IDENTITY_ISSUER=https://identity.prabhixtechnologies.com",
            "--dart-define=API_BASE_URL=$($catalog[$app].Api)"
        )
        $result = Invoke-Tool "flutter" $arguments $dir -Mutating
        if ($result.ExitCode -ne 0) { throw "Flutter $Kind build failed for $app." }
        if (-not $DryRun) {
            $source = if ($Kind -eq "aab") {
                Join-Path $dir "build\app\outputs\bundle\release\app-release.aab"
            } else {
                Join-Path $dir "build\app\outputs\flutter-apk\app-release.apk"
            }
            Copy-Item $source (Join-Path $outDir "$app-release.$Kind") -Force
            Write-Host "Wrote build/play/$app-release.$Kind"
        }
    }
}

function Install-Apks {
    param([string[]]$Selected)
    Assert-Tools @("adb")
    $devices = @(& adb devices | Select-String "\tdevice$")
    if (-not $DryRun -and $devices.Count -eq 0) { throw "No adb device is connected." }
    foreach ($app in $Selected) {
        $apk = Join-Path $outDir "$app-release.apk"
        if (-not $DryRun -and -not (Test-Path $apk)) { throw "Build $app-release.apk first." }
        [void](Invoke-Tool "adb" @("uninstall", $catalog[$app].Package) -Mutating)
        $result = Invoke-Tool "adb" @("install", "-r", $apk) -Mutating
        if ($result.ExitCode -ne 0) { throw "APK install failed for $app." }
    }
}

function Get-GitOutput {
    param([string[]]$Arguments)
    $result = Invoke-Tool "git" $Arguments
    if ($result.ExitCode -ne 0) { throw "git $($Arguments -join ' ') failed." }
    $result.Output.Trim()
}

function Assert-MainReady {
    param([string[]]$Selected, [switch]$RequireClean)
    $branch = Get-GitOutput @("branch", "--show-current")
    if ($branch -ne "main") { throw "Mobile must be on main, not '$branch'." }
    if (-not $DryRun) {
        $fetch = Invoke-Tool "git" @("fetch", "origin", "main")
        if ($fetch.ExitCode -ne 0) { throw "Could not fetch origin/main." }
        $counts = (Get-GitOutput @("rev-list", "--left-right", "--count", "HEAD...origin/main")) -split '\s+'
        if ([int]$counts[1] -gt 0) { throw "Mobile is behind origin/main. Pull before releasing." }
    }
    $allowed = @($Selected | ForEach-Object { "apps/$_/pubspec.yaml" })
    $status = Invoke-Tool "git" @("status", "--porcelain=v1", "--untracked-files=all")
    if ($status.ExitCode -ne 0) { throw "git status failed." }
    # Porcelain lines start with a two-letter status that can begin with a space, so they must
    # not be trimmed before the path is read.
    $changed = @(
        foreach ($line in @($status.Output -split "`r?`n")) {
            if ($line -match '^.. (.+)$') { ($Matches[1] -split ' -> ')[-1].Trim('"').Replace('\', '/') }
        }
    )
    if ($DryRun -and $AllowDirtyPreview -and $changed.Count -gt 0) {
        Write-Host "DRY RUN: ignoring working-tree changes for command preview."
        return
    }
    if ($RequireClean -and $changed.Count -gt 0) {
        throw "This Play action requires a clean Mobile working tree. Changed: $($changed -join ', ')"
    }
    $unexpected = @($changed | Where-Object { $allowed -notcontains $_ })
    $secrets = @($unexpected | Where-Object {
        $_ -match '(^|/)(\.env(\..*)?|key\.properties|[^/]*\.(jks|pem|p12|pfx)|[^/]*credentials[^/]*)$'
    })
    if ($secrets.Count -gt 0) {
        throw "Refusing to release while these files are changed: $($secrets -join ', ')"
    }
    if ($unexpected.Count -gt 0) {
        Write-Host "Leaving these files uncommitted: $($unexpected -join ', ')"
    }
}

function Commit-Push {
    param([string[]]$Selected)
    Assert-MainReady $Selected
    $paths = @($Selected | ForEach-Object { "apps/$_/pubspec.yaml" })
    if (-not $CommitMessage) { throw "A commit message is required." }
    $pending = Invoke-Tool "git" (@("status", "--porcelain=v1", "--") + $paths)
    if ($DryRun -or $pending.Output) {
        $add = Invoke-Tool "git" (@("add", "--") + $paths) -Mutating
        if ($add.ExitCode -ne 0) { throw "Could not stage version files." }
        $commit = Invoke-Tool "git" (@("commit", "-m", $CommitMessage, "--") + $paths) -Mutating
        if ($commit.ExitCode -ne 0) { throw "Could not commit version files." }
    } else {
        Write-Host "Version files are already committed."
    }
    $push = Invoke-Tool "git" @("push", "origin", "main") -Mutating
    if ($push.ExitCode -ne 0) { throw "Could not push Mobile main." }
}

function Assert-UploadApproval {
    if ($Track -eq "production") {
        if ($Confirm -cne "APPROVE PRODUCTION") { throw "Production requires APPROVE PRODUCTION." }
    } elseif ($Confirm -cne "deploy") {
        throw "$Track upload requires deploy."
    }
}

function Start-PlayUpload {
    param([string[]]$Selected)
    Assert-UploadApproval
    Assert-Tools @("gh")
    Assert-MainReady $Selected
    $head = Get-GitOutput @("rev-parse", "HEAD")
    if (-not $DryRun) {
        $remote = Get-GitOutput @("rev-parse", "origin/main")
        if ($head -ne $remote) { throw "Push Mobile main before uploading to Play." }
    }
    $names = $Selected -join ","
    $result = Invoke-Tool "gh" @(
        "workflow", "run", "play-upload.yml", "--repo", $repo, "--ref", "main",
        "-f", "track=$Track", "-f", "confirm=$Confirm", "-f", "apps=$names"
    ) -Mutating
    if ($result.ExitCode -ne 0) { throw "Could not dispatch the Play upload workflow." }
    if ($DryRun) { return }
    Start-Sleep -Seconds 4
    $list = Invoke-Tool "gh" @(
        "run", "list", "--repo", $repo, "--workflow", "play-upload.yml",
        "--event", "workflow_dispatch", "--limit", "10",
        "--json", "databaseId,url,status,conclusion,createdAt,headSha"
    ) -Quiet
    if ($list.ExitCode -ne 0) { throw "Upload started, but its workflow run could not be found." }
    $parsedRuns = ConvertFrom-Json -InputObject $list.Output
    $matchingRuns = @(
        foreach ($candidate in $parsedRuns) {
            if ($candidate.headSha -eq $head) { $candidate }
        }
    )
    $run = @($matchingRuns | Sort-Object { [DateTime]$_.createdAt } -Descending)[0]
    if (-not $run) { throw "Upload started, but its workflow run has not appeared yet. Check GitHub Actions." }
    Write-Host "PLAY_RUN_ID=$($run.databaseId)"
    Write-Host "PLAY_RUN_URL=$($run.url)"
    Watch-PlayRun $run.databaseId
}

function Watch-PlayRun {
    param($Id)
    $deadline = (Get-Date).AddMinutes(50)
    while ($true) {
        $view = Invoke-Tool "gh" @(
            "run", "view", "$Id", "--repo", $repo,
            "--json", "status,conclusion,jobs,url"
        ) -Quiet
        if ($view.ExitCode -ne 0) { throw "Could not read Play workflow $Id." }
        $run = $view.Output | ConvertFrom-Json
        $state = if ($run.status -eq "completed") { $run.conclusion } else { $run.status }
        Write-Host "Play upload ${Id}: $state"
        $jobs = @($run.jobs)
        if ($jobs.Count -eq 0) {
            Write-Host "  waiting for the build jobs to start"
        }
        foreach ($job in $jobs) {
            $jobState = if ($job.status -eq "completed") { $job.conclusion } else { $job.status }
            Write-Host "  $($job.name): $jobState"
        }
        if ($run.status -eq "completed") {
            if ($run.conclusion -ne "success") {
                throw "Play upload finished with $($run.conclusion). $($run.url)"
            }
            Write-Host "Play upload succeeded. $($run.url)"
            return
        }
        if ((Get-Date) -gt $deadline) {
            throw "Play upload is still running after 50 minutes. $($run.url)"
        }
        Start-Sleep -Seconds 15
    }
}

$selectedApps = @(Get-SelectedApps)
switch ($Action) {
    "Status" {
        $rows = @(Get-StatusRows)
        if ($Json) { $rows | ConvertTo-Json -Depth 4 } else { $rows | Format-Table -AutoSize | Out-String | Write-Host }
    }
    "SaveVersions" { Save-Versions $selectedApps (Get-VersionMap) }
    "BuildAab" { Build-Apps $selectedApps "aab" }
    "BuildApk" { Build-Apps $selectedApps "apk" }
    "InstallApk" { Install-Apks $selectedApps }
    "CommitPush" { Commit-Push $selectedApps }
    "Upload" { Start-PlayUpload $selectedApps }
    "QuickRelease" {
        Assert-MainReady $selectedApps
        Save-Versions $selectedApps (Get-VersionMap)
        Commit-Push $selectedApps
        Start-PlayUpload $selectedApps
    }
    "WatchRun" {
        if ($RunId -notmatch '^\d+$') { throw "A numeric GitHub run ID is required." }
        $result = Invoke-Tool "gh" @("run", "watch", $RunId, "--repo", $repo, "--exit-status")
        if ($result.ExitCode -ne 0) { throw "Play upload workflow failed." }
    }
}
