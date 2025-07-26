<#
.SYNOPSIS
  Compress one or more PNG files using pngquant and oxipng.

.DESCRIPTION
  Pass a single file path or wildcard (e.g. *.png) to patch process multiple PNGs.
#>

param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [string[]]$InputPaths
)

function CompressSingle {
    param($InputPath)

    # Check to see if file exists
    if (-not (Test-Path $InputPath)) {
        Write-Error "[-] File not found: $InputPath"
        return
    }

    # Generate temp filename
    $dir = Split-Path $InputPath
    $base = [System.IO.Path]::GetFileNameWithoutExtension($InputPath)
    $tmp = Join-Path $dir ("$base-temp.png")

    # Set quality range for pngquant to 80-100
    Write-Host "[+] Running pngquant..."
    pngquant --quality=80-100 --strip --skip-if-larger --force --output $tmp $InputPath
    if ($LASTEXITCODE -eq 98 -or $LASTEXITCODE -eq 99) {
        Write-Warning "pngquant didn't produce a smaller file - falling back to original."
        Copy-Item $InputPath $tmp -Force
    } elseif ($LASTEXITCODE -ne 0) {
        Write-Warning "pngquant error ($LASTEXITCODE) - falling back to original."
        Copy-Item $InputPath $tmp -Force
    }

    # Use oxipng with level 4 preset
    Write-Host "[+] Running oxipng..."
    oxipng -o 4 --strip safe --alpha --force $tmp | Out-Null

    # Replace original with temp file
    Move-Item $tmp $InputPath -Force
    Write-Host "[+] Compression for $InputPath complete!"
}

# Use wildcard for batch mode
foreach ($path in $InputPaths) {
    Get-ChildItem -Path $path -File | ForEach-Object {
        CompressSingle $_.FullName
    }
}