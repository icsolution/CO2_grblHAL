$ErrorActionPreference = 'Stop'

$port = 'COM6'
$baud = 115200
$sp = New-Object System.IO.Ports.SerialPort $port,$baud,'None',8,'one'
$sp.ReadTimeout = 300
$sp.WriteTimeout = 1000
$sp.DtrEnable = $true
$sp.RtsEnable = $false
$sp.NewLine = "`n"

$commands = @(
  "`r`n",
  '$I',
  '$140','$141','$142','$143','$144',
  '$150','$151','$152',
  'M122'
)

function Read-Response {
  param(
    [System.IO.Ports.SerialPort]$Port,
    [int]$MaxMs = 15000,
    [int]$IdleMs = 1500
  )

  $buffer = New-Object System.Text.StringBuilder
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  $lastDataMs = 0

  while($sw.ElapsedMilliseconds -lt $MaxMs){
    $chunk = $Port.ReadExisting()

    if($chunk){
      [void]$buffer.Append($chunk)
      $lastDataMs = $sw.ElapsedMilliseconds
    } else {
      Start-Sleep -Milliseconds 50
    }

    if($lastDataMs -gt 0 -and (($sw.ElapsedMilliseconds - $lastDataMs) -ge $IdleMs)){
      break
    }
  }

  return $buffer.ToString()
}

try {
  $sp.Open()
  Start-Sleep -Milliseconds 700
  try { while($sp.BytesToRead -gt 0){ $null = $sp.ReadExisting() } } catch {}

  foreach($c in $commands){
    $sp.WriteLine($c)
    Start-Sleep -Milliseconds 200
    $buf = Read-Response -Port $sp -MaxMs 18000 -IdleMs 1600

    Write-Output ("----- CMD: $c -----")
    if([string]::IsNullOrWhiteSpace($buf)){
      Write-Output '<no response>'
    } else {
      Write-Output $buf.TrimEnd()
    }
  }
}
finally {
  if($sp -and $sp.IsOpen){ $sp.Close() }
}
