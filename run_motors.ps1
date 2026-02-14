# Connect, reset, unlock, and run X/Y motors
$p = New-Object System.IO.Ports.SerialPort 'COM6', 115200, 'None', 8, 'one'
$p.ReadTimeout = 300
$p.WriteTimeout = 300
$p.Open()
Start-Sleep -Milliseconds 400

Write-Output "=== Sending reset (Ctrl+X) ==="
# Ctrl+X = 0x18 (ASCII 24)
$p.Write([byte[]]@(0x18), 0, 1)
Start-Sleep -Milliseconds 200
$buf = ''
$sw = [System.Diagnostics.Stopwatch]::StartNew()
while ($sw.ElapsedMilliseconds -lt 1500) {
  $chunk = $p.ReadExisting()
  if ($chunk) {
    $buf += $chunk
    Start-Sleep -Milliseconds 30
  } else {
    Start-Sleep -Milliseconds 20
  }
}
Write-Output $buf.Trim()

Write-Output "`n=== Unlocking machine ==="
$p.WriteLine('$X')
Start-Sleep -Milliseconds 100
$buf = ''
$sw = [System.Diagnostics.Stopwatch]::StartNew()
while ($sw.ElapsedMilliseconds -lt 2000) {
  $chunk = $p.ReadExisting()
  if ($chunk) {
    $buf += $chunk
    Start-Sleep -Milliseconds 30
  } else {
    Start-Sleep -Milliseconds 20
  }
}
Write-Output $buf.Trim()

Write-Output "`n=== Running X and Y motors ==="
Write-Output "Moving X+5mm and Y+5mm at 500mm/min feedrate..."
$p.WriteLine('G0 X5 Y5 F500')
Start-Sleep -Milliseconds 100
$buf = ''
$sw = [System.Diagnostics.Stopwatch]::StartNew()
while ($sw.ElapsedMilliseconds -lt 5000) {
  $chunk = $p.ReadExisting()
  if ($chunk) {
    $buf += $chunk
    Start-Sleep -Milliseconds 50
  } else {
    Start-Sleep -Milliseconds 30
  }
}
Write-Output $buf.Trim()

Write-Output "`n=== Checking machine status ==="
$p.WriteLine('?')
Start-Sleep -Milliseconds 100
$buf = ''
$sw = [System.Diagnostics.Stopwatch]::StartNew()
while ($sw.ElapsedMilliseconds -lt 2000) {
  $chunk = $p.ReadExisting()
  if ($chunk) {
    $buf += $chunk
    Start-Sleep -Milliseconds 30
  } else {
    Start-Sleep -Milliseconds 20
  }
}
Write-Output $buf.Trim()

$p.Close()
Write-Output "`nMOTOR_RUN_COMPLETE"
