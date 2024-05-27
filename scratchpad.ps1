
$f = (New-Guid).Guid
$filename = "$($env:TEMP)\$f.log"
Start-Transcript $filename

$PSScriptRoot
$PSCommandPath

$env:COMPUTERNAME
$env:TEMP

Write-Host "Hello"
Stop-Transcript