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
    $vmloc = "$($configs.vmloc)\$($machine.Name)"
    $vhdPath = "$($configs.vhdloc)\$($machine.Name)\$($machine.Name).vhdx"
    New-VM -Name $machine.Name -Path $vmloc -MemoryStartupBytes ($machine.MemoryStartupBytes / 1) `
        -NewVHDPath $vhdPath -NewVHDSizeBytes ($machine.VHDSizeBytes / 1) -SwitchName $machine.SwitchName `
        -Generation $machine.Generation 

    Set-VMProcessor -VMName $machine.Name -Count $machine.Processors
    $medialoc = "$($config.medialoc)\$($machine.Type).iso"
    Add-VMDVDDrive -VMName $machine.Name -Path $medialoc

    # add keys and enable TPM
    Update-VMVersion -VMName $machine.Name -Confirm:$false
    
    if($null -eq (Get-HgsGuardian "UntrustedGuardian"))
    {
        New-HgsGuardian -Name "UntrustedGuardian" -GenerateCertificates 
    }
    
    $owner = Get-HgsGuardian "UntrustedGuardian"
    $kp = New-HgsKeyProtector -Owner $owner -AllowUntrustedRoot
    Set-VMKeyProtector -VMName $machine.Name -KeyProtector $kp.RawData
    Enable-VMTPM -VMName $machine.Name
}