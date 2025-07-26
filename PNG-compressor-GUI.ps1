# Ensure STA mode
if ([System.Threading.Thread]::CurrentThread.ApartmentState -ne [System.Threading.ApartmentState]::STA) {
    [System.Diagnostics.Process]::Start(
        [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName,
        "-sta -file `"$PSCommandPath`""
    )
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Logging function
$LogPath = "$PSScriptRoot\PNG-compressor.log"
function Write-Log {
    param($Message, $Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "[$timestamp] [$Level] $Message"
}

# Compress function
function CompressPng {
    param($InputPath)
    if (-not (Test-Path $InputPath)) { Write-Error "Not found: $InputPath"; return }
    $dir = Split-Path $InputPath
    $base = [System.IO.Path]::GetFileNameWithoutExtension($InputPath)
    $tmp = Join-Path $dir ("$base-temp.png")

    try {
        pngquant --quality=80-100 --strip --skip-if-larger --force --output $tmp $InputPath
        if ($LASTEXITCODE -eq 98 -or $LASTEXITCODE -eq 99) {
            Write-Warning "pngquant produced no smaller output."
            Copy-Item $InputPath $tmp -Force
        } elseif ($LASTEXITCODE -ne 0) {
            Write-Warning "pngquant error code $LASTEXITCODE"
            Copy-Item $InputPath $tmp -Force
        }
    }
    catch {
        Write-Log "ERROR pngquant on $InputPath - $($_.Exception.Message)" "ERROR"
        return
    }

    try {
        oxipng -o 4 --strip safe --alpha --force $tmp | Out-Null
    }
    catch {
        Write-Log "ERROR oxipng on $InputPath - $($_.Exception.Message)" "ERROR"
        return
    }

    try {
        Move-Item $tmp $InputPath -Force
        Write-Log "Compressed OK: $InputPath"
    }
    catch {
        Write-Log "ERROR moving temp file for $InputPath - $($_.Exception.Message)" "ERROR"
    }
}

# Form setup
$form = New-Object System.Windows.Forms.Form
$form.Text = "PNG Compressor"
$form.Size = New-Object System.Drawing.Size(500, 400)
$form.StartPosition = "CenterScreen"

# ImageList with PNG icon
$imageList = New-Object System.Windows.Forms.ImageList
$imageList.ImageSize = New-Object System.Drawing.Size(16,16)
# Create dummy PNG file to extract registered icon
$dummy = "$env:TEMP\dummy.png"
New-Item -ItemType File -Path $dummy -Force | Out-Null
$pngIcon = [System.Drawing.Icon]::ExtractAssociatedIcon($dummy)
$imageList.Images.Add("png", $pngIcon)
Remove-Item $dummy -Force

# ListView - columns for file paths and sizes
$list = New-Object System.Windows.Forms.ListView
$list.View = 'Details'
$list.SmallImageList = $imageList
$list.FullRowSelect = $true
$list.AllowDrop = $true
$list.Dock = 'Top'
$list.Height = 250
$list.Columns.Add("File Path",200) | Out-Null
$list.Columns.Add("Old Size(KB)",90) | Out-Null
$list.Columns.Add("New Size(KB)",90) | Out-Null
$list.Columns.Add("Saved%",50) | Out-Null
$list.Columns.Add("Status",50) | Out-Null
$form.Controls.Add($list)


# Status label
$status = New-Object System.Windows.Forms.Label
$status.Text = "Drag files or folders here."
$status.Dock = 'Top'
$form.Controls.Add($status)

# Progress bar
$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Style = 'Continuous'
$progress.Dock = 'Top'
$form.Controls.Add($progress)

# TableLayoutPanel to center buttons
$table = New-Object System.Windows.Forms.TableLayoutPanel
$table.RowCount = 1
$table.ColumnCount = 1
$table.Dock = 'Bottom'
$table.AutoSize = $true
$table.AutoSizeMode = 'GrowAndShrink'
$table.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('AutoSize')))
$table.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('AutoSize')))
$form.Controls.Add($table)

# FlowLayoutPanel for buttons
$flow = New-Object System.Windows.Forms.FlowLayoutPanel
$flow.FlowDirection = 'LeftToRight'
$flow.AutoSize = $true
$flow.AutoSizeMode = 'GrowAndShrink'
$flow.WrapContents = $false
$flow.Anchor = [System.Windows.Forms.AnchorStyles]::None

# Add FlowLayoutPanel to TableLayoutPanel
$table.Controls.Add($flow, 0, 0)

# Start button
$buttonStart = New-Object System.Windows.Forms.Button
$buttonStart.Text = "Start"
$buttonStart.AutoSize = $true
$buttonStart.Anchor = [System.Windows.Forms.AnchorStyles]::None
$flow.Controls.Add($buttonStart)

# Clear list button
$buttonClear = New-Object System.Windows.Forms.Button
$buttonClear.Text = "Clear List"
$buttonClear.AutoSize = $true
$buttonClear.Anchor = [System.Windows.Forms.AnchorStyles]::None
$flow.Controls.Add($buttonClear)

# Start button click handler
$buttonStart.Add_Click({
    $count = $list.Items.Count
    $progress.Maximum = $count

    for ($i=0; $i -lt $count; $i++) {
        $item = $list.Items[$i]
        $status.Text = "Processing: $($item.Text)"
        $errorOccurred = $false

        $originalSize = (Get-Item $item.Text).Length / 1KB

        try {
            CompressPng $item.Text
        }
        catch {
            $errorOccurred = $true
            Write-Log "ERROR compressing $($item.Text): $($_.Exception.Message)" "ERROR"
        }

        if ($errorOccurred) {
            $item.ForeColor = [System.Drawing.Color]::Red
            $item.UseItemStyleForSubItems = $false
            $item.SubItems[2].Text = "-"
            $item.SubItems[4].Text = "Failed"
        } else {
            $newSize = (Get-Item $item.Text).Length / 1KB

            if ($originalSize -gt 0) {
                $savedPercent = [math]::Round((($originalSize - $newSize) / $originalSize * 100), 1)
            } else {
                $savedPercent = 0
            }

            $item.SubItems[2].Text = [math]::round($newSize, 1)
            $item.SubItems[3].Text = "$savedPercent%"
            $item.SubItems[4].Text = "OK"
        }

        $progress.Value = $i + 1
    }

    [System.Windows.Forms.MessageBox]::Show("Done compressing $count file(s).")
    $status.Text = "Completed"
})

# Clear List button click handler
$buttonClear.Add_Click({
    $list.Items.Clear()
    $progress.Value = 0
    $status.Text = "List cleared!"
})

# DragEnter
$list.Add_DragEnter({
    if ($_.Data.GetDataPresent([System.Windows.Forms.DataFormats]::FileDrop)) {
        $_.Effect = [System.Windows.Forms.DragDropEffects]::Copy
    } else {
        $_.Effect = 'None'
    }
})

# DragDrop - add files/folders
$list.Add_DragDrop({
    $items = $_.Data.GetData([System.Windows.Forms.DataFormats]::FileDrop)
    foreach ($path in $items) {
        if (Test-Path $path) {
            if ((Get-Item $path).PSIsContainer) {
                Get-ChildItem -Path $path -Recurse -Filter *.png | ForEach-Object {
                    $origKB = [math]::round($_.Length/1KB,1)
                    $li = $list.Items.Add($_.FullName)
                    $li.SubItems.Add($origKB)
                    $li.SubItems.Add("") # Placeholder for new size
                    $li.SubItems.Add("") # Placeholder for saved percentage
                    $li.SubItems.Add("") # Placeholder for status
                    $li.ImageKey = "png"
                }
            }
            elseif ($path.ToLower().EndsWith('.png')) {
                $origKB = [math]::round((Get-Item $path).Length/1KB,1)
                $li = $list.Items.Add($path)
                $li.SubItems.Add($origKB)
                $li.SubItems.Add("") # Placeholder for new size
                $li.SubItems.Add("") # Placeholder for saved percentage
                $li.SubItems.Add("") # Placeholder for status
                $li.ImageKey = "png"
            }
        }
    }
    $status.Text = "Files listed: $($list.Items.Count)"
})

$form.ShowDialog()
