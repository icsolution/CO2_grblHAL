# Temporarily disable init_lock, unlock, and test motor movement
$p = New-Object System.IO.Ports.SerialPort 'COM6', 115200, 'None', 8, 'one'
$p.ReadTimeout = 300
$p.WriteTimeout = 300
$p.Open()
Start-Sleep -Milliseconds 500

Write-Output "=== Step 1: Disable init_lock (homing requirement) ==="
$p.WriteLine('$29=0')
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

Write-Output "`n=== Step 2: Verify init_lock is disabled ==="
$p.WriteLine('$29')
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

Write-Output "`n=== Step 3: Unlock machine ==="
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

Write-Output "`n=== Step 4: Check machine status ==="
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

Write-Output "`n=== Step 5: Move X+5mm and Y+5mm ==="
Write-Output "Sending: G0 X5 Y5 F500"
$p.WriteLine('G0 X5 Y5 F500')
Start-Sleep -Milliseconds 200
$buf = ''
$sw = [System.Diagnostics.Stopwatch]::StartNew()
while ($sw.ElapsedMilliseconds -lt 6000) {
  $chunk = $p.ReadExisting()
  if ($chunk) {
    $buf += $chunk
    Start-Sleep -Milliseconds 50
  } else {
    Start-Sleep -Milliseconds 30
  }
}
Write-Output $buf.Trim()

Write-Output "`n=== Step 6: Check final status ==="
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
Write-Output "`nMOTOR_TEST_COMPLETE"
