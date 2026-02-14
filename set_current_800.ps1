# Set all motors to 800 mA
$p = New-Object System.IO.Ports.SerialPort 'COM6', 115200, 'None', 8, 'one'
$p.ReadTimeout = 300
$p.WriteTimeout = 300
$p.Open()
Start-Sleep -Milliseconds 300

$commands = @('$140=800', '$141=800', '$142=800')

foreach ($c in $commands) {
  $p.WriteLine($c)
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
  Write-Output ("----- $c -----")
  Write-Output $buf.Trim()
}

# Verify the changes
Write-Output "`n--- Verification ---"
$verify = @('$140', '$141', '$142')
foreach ($c in $verify) {
  $p.WriteLine($c)
  Start-Sleep -Milliseconds 80
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
  Write-Output ("----- $c -----")
  Write-Output $buf.Trim()
}

$p.Close()
Write-Output "`nCURRENT_SET_COMPLETE"
