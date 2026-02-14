# Quick TMC2209 feature probe
$p = New-Object System.IO.Ports.SerialPort 'COM6', 115200, 'None', 8, 'one'
$p.ReadTimeout = 300
$p.WriteTimeout = 300
$p.Open()
Start-Sleep -Milliseconds 300

$commands = @('$I', '$140', '$141', '$142', '$143', '$144', '$150', '$151', '$152', '$153', '$154', 'M122')

foreach ($c in $commands) {
  $p.WriteLine($c)
  Start-Sleep -Milliseconds 80
  $buf = ''
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  while ($sw.ElapsedMilliseconds -lt 4000) {
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
Write-Output "PROBE_COMPLETE"
