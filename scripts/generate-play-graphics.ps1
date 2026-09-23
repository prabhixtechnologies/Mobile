# 512x512 Play icons + 1024x500 feature graphics from Mobile/branding/icons.
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path (Split-Path -Parent $root) "Infra\docs\play-store\assets"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$apps = @(
    @{ Id = "mobistack"; Title = "MobiStack";      Field = "#0E7490"; Icon = "mobistack.png" }
    @{ Id = "oneops";    Title = "Prabhix OneOps"; Field = "#0C1524"; Icon = "oneops.png" }
    @{ Id = "mailroom";  Title = "Prabhix Mailroom"; Field = "#0E7490"; Icon = "mailroom.png" }
    @{ Id = "admin";     Title = "Prabhix Admin";  Field = "#0C1524"; Icon = "admin.png" }
)

function Convert-Hex([string]$hex) {
    $h = $hex.TrimStart("#")
    [System.Drawing.Color]::FromArgb(
        [Convert]::ToInt32($h.Substring(0, 2), 16),
        [Convert]::ToInt32($h.Substring(2, 2), 16),
        [Convert]::ToInt32($h.Substring(4, 2), 16)
    )
}

foreach ($app in $apps) {
    $srcPath = Join-Path $root "branding\icons\$($app.Icon)"
    $src = [System.Drawing.Image]::FromFile($srcPath)

    $icon = New-Object System.Drawing.Bitmap 512, 512, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($icon)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.DrawImage($src, 0, 0, 512, 512)
    $iconPath = Join-Path $outDir "$($app.Id)-icon-512.png"
    $icon.Save($iconPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $icon.Dispose()

    $feat = New-Object System.Drawing.Bitmap 1024, 500, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $fg = [System.Drawing.Graphics]::FromImage($feat)
    $fg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $fg.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $fg.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $fg.Clear((Convert-Hex $app.Field))
    $fg.DrawImage($src, 72, 90, 320, 320)
    $font = New-Object System.Drawing.Font "Segoe UI Semibold", 42, ([System.Drawing.FontStyle]::Bold)
    $sub = New-Object System.Drawing.Font "Segoe UI", 18, ([System.Drawing.FontStyle]::Regular)
    $white = [System.Drawing.Brushes]::White
    $fg.DrawString($app.Title, $font, $white, 430, 175)
    $fg.DrawString("A Prabhix product", $sub, $white, 430, 250)
    $featPath = Join-Path $outDir "$($app.Id)-feature-1024x500.png"
    $feat.Save($featPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $font.Dispose(); $sub.Dispose(); $fg.Dispose(); $feat.Dispose(); $src.Dispose()
    Write-Host "Wrote $iconPath"
    Write-Host "Wrote $featPath"
}
