# Check machine state and attempt to clear alarm
$p = New-Object System.IO.Ports.SerialPort 'COM6', 115200, 'None', 8, 'one'
$p.ReadTimeout = 300
$p.WriteTimeout = 300
$p.Open()
Start-Sleep -Milliseconds 400

Write-Output "=== Initial machine status ==="
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

Write-Output "`n=== Querying settings to check alarm state ==="
$p.WriteLine('$$')
Start-Sleep -Milliseconds 100
$buf = ''
$sw = [System.Diagnostics.Stopwatch]::StartNew()
while ($sw.ElapsedMilliseconds -lt 3000) {
  $chunk = $p.ReadExisting()
  if ($chunk) {
    $buf += $chunk
    Start-Sleep -Milliseconds 30
  } else {
    Start-Sleep -Milliseconds 20
  }
}
Write-Output ($buf.Trim() | Select-Object -First 20)

Write-Output "`n=== Checking alarm/error state ==="
$p.WriteLine('$H')
Start-Sleep -Milliseconds 200
$buf = ''
$sw = [System.Diagnostics.Stopwatch]::StartNew()
while ($sw.ElapsedMilliseconds -lt 3000) {
  $chunk = $p.ReadExisting()
  if ($chunk) {
    $buf += $chunk
    Start-Sleep -Milliseconds 50
  } else {
    Start-Sleep -Milliseconds 30
  }
}
Write-Output $buf.Trim()

$p.Close()
Write-Output "`nDIAGNOSTIC_COMPLETE"
