[CmdletBinding()]
param (
    [Parameter()][bool]$parallel = $true,
    [Parameter()][string]$machineConfigs = "",
    [Parameter()][string]$lab = "Hypervlab"
)
function Get-ScriptDirectory { Split-Path $MyInvocation.ScriptName }

$helperScript = Join-Path (Get-ScriptDirectory) 'config\helpers.ps1'
. $helperScript

$configs = Get-Configs

if ($machineConfigs -eq "") {
    $machineConfigs = Join-Path (Get-ScriptDirectory) 'config\machines.json'
    if ((Test-Path -Path $machineConfigs) -eq $false) {
        Write-Host "Cannot find configs $machineConfigs and none supplied" -ForegroundColor DarkRed
        Exit
    }
}

$machines = Get-Content -Path $machineConfigs | ConvertFrom-Json
$machines = $machines.$lab.Machines

foreach ($machine in $machines) {
    $machine
    Invoke-Command -VMName $machine.Name -ScriptBlock{Rename-Computer -NewName 'LON-DC1' -LocalCredential $Cred1 -Force -Restart}
}