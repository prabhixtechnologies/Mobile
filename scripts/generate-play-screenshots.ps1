# Placeholder Play screenshots (phone 9:16, tablet 16:9) from branding icons.
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root "build\play"
$docsDir = Join-Path (Split-Path -Parent $root) "Infra\docs\play-store\assets"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
New-Item -ItemType Directory -Force -Path $docsDir | Out-Null

$apps = @(
    @{ Id = "mobistack"; Title = "MobiStack"; Sub = "Inventory, sales, and repairs"; Field = "#0E7490"; Icon = "mobistack.png" }
    @{ Id = "oneops"; Title = "Prabhix OneOps"; Sub = "Visitors, live ops, and team chat"; Field = "#0C1524"; Icon = "oneops.png" }
    @{ Id = "mailroom"; Title = "Prabhix Mailroom"; Sub = "Shared inbox for your organisation"; Field = "#0E7490"; Icon = "mailroom.png" }
    @{ Id = "admin"; Title = "Prabhix Admin"; Sub = "Staff console for Prabhix"; Field = "#0C1524"; Icon = "admin.png" }
)

function Convert-Hex([string]$hex) {
    $h = $hex.TrimStart("#")
    [System.Drawing.Color]::FromArgb(
        [Convert]::ToInt32($h.Substring(0, 2), 16),
        [Convert]::ToInt32($h.Substring(2, 2), 16),
        [Convert]::ToInt32($h.Substring(4, 2), 16)
    )
}

function Save-Shot([string]$path, [int]$w, [int]$h, $app, [string]$line2) {
    $src = [System.Drawing.Image]::FromFile((Join-Path $root "branding\icons\$($app.Icon)"))
    $bmp = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.Clear((Convert-Hex $app.Field))
    $iconSize = [Math]::Min(320, [int]($w / 3.2))
    $g.DrawImage($src, [int](($w - $iconSize) / 2), [int]($h * 0.22), $iconSize, $iconSize)
    $titleSize = [Math]::Max(28, [int]($w / 22))
    $subSize = [Math]::Max(16, [int]($w / 40))
    $titleFont = New-Object System.Drawing.Font "Segoe UI Semibold", $titleSize, ([System.Drawing.FontStyle]::Bold)
    $subFont = New-Object System.Drawing.Font "Segoe UI", $subSize, ([System.Drawing.FontStyle]::Regular)
    $white = [System.Drawing.Brushes]::White
    $g.DrawString($app.Title, $titleFont, $white, 48, [int]($h * 0.58))
    $g.DrawString($line2, $subFont, $white, 48, [int]($h * 0.70))
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $titleFont.Dispose(); $subFont.Dispose(); $g.Dispose(); $bmp.Dispose(); $src.Dispose()
    Write-Host "Wrote $path"
}

foreach ($app in $apps) {
    Save-Shot (Join-Path $outDir "$($app.Id)-phone-1.png") 1080 1920 $app $app.Sub
    Save-Shot (Join-Path $outDir "$($app.Id)-phone-2.png") 1080 1920 $app "A Prabhix product. Sign in with your organisation account."
    Save-Shot (Join-Path $outDir "$($app.Id)-tablet7-1.png") 1080 1920 $app $app.Sub
    Save-Shot (Join-Path $outDir "$($app.Id)-tablet7-2.png") 1080 1920 $app "A Prabhix product. Sign in with your organisation account."
    Save-Shot (Join-Path $outDir "$($app.Id)-tablet10-1.png") 1920 1080 $app $app.Sub
    Save-Shot (Join-Path $outDir "$($app.Id)-tablet10-2.png") 1920 1080 $app "A Prabhix product. Sign in with your organisation account."
    Copy-Item (Join-Path $outDir "$($app.Id)-phone-1.png") (Join-Path $docsDir "$($app.Id)-phone-1.png") -Force
    Copy-Item (Join-Path $outDir "$($app.Id)-phone-2.png") (Join-Path $docsDir "$($app.Id)-phone-2.png") -Force
}

Write-Host "All screenshots in $outDir"
