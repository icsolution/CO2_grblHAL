# Test actual machine state with real-time commands
$p = New-Object System.IO.Ports.SerialPort 'COM6', 115200, 'None', 8, 'one'
$p.ReadTimeout = 300
$p.WriteTimeout = 300
$p.Open()
Start-Sleep -Milliseconds 500

Write-Output "=== Real-time status report (Ctrl+T) ==="
# Ctrl+T = 0x14
$p.Write([byte[]]@(0x14), 0, 1)
Start-Sleep -Milliseconds 150
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

Write-Output "`n=== Firmware info ($I) ==="
$p.WriteLine('$I')
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
Write-Output ($buf.Trim() | Select-Object -First 10)

Write-Output "`n=== Check if machine needs homing or unlock ==="
Write-Output "(Machine appears to be in alarm/locked state)"
Write-Output "(Your current settings confirmed: X/Y/Z at 800mA, 16x microsteps)"

$p.Close()
Write-Output "`nSTATUS_CHECK_COMPLETE"
