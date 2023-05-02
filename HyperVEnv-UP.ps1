[CmdletBinding()]
param (
    [Parameter()][string]$machineConfigs = "",
    [Parameter()][string]$lab = "base" # get from machineConfigs 
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
    $hyperVMachineName = "$lab-$($machine.Name)"
    $vmloc = "$($configs.vmloc)\$($hyperVMachineName)"
    $vhdPath = "$($configs.vhdloc)\$($hyperVMachineName)\$($hyperVMachineName).vhdx"
    if (Test-Path -path $vhdPath) {
        try {
            Remove-item -path $vhdPath -Force -Confirm:$false
        }
        catch {
            Write-Host "Unable to remove VHD at $vhdPath" -ForegroundColor DarkRed
            $_
        }
    }
    
    New-VM -Name $hyperVMachineName -Path $vmloc -MemoryStartupBytes ($machine.MemoryStartupBytes / 1) `
        -NewVHDPath $vhdPath -NewVHDSizeBytes ($machine.VHDSizeBytes / 1) -SwitchName $machine.SwitchName `
        -Generation $machine.Generation 

    Set-VMMemory $hyperVMachineName -DynamicMemoryEnabled $false
    Set-VMProcessor -VMName $hyperVMachineName -Count $machine.Processors
    $medialoc = "$($config.medialoc)\$($machine.Type).iso"
    Add-VMDVDDrive -VMName $hyperVMachineName -Path $medialoc

    # Start and stop behaviour
    Set-VM $hyperVMachineName -AutomaticStartAction Nothing 
    Set-VM $hyperVMachineName -AutomaticStopAction TurnOff

    Set-VM $hyperVMachineName -Notes "$($machine.username) : $($machine.password)"

    # add keys and enable TPM
    Update-VMVersion -VMName $hyperVMachineName -Confirm:$false
    
    if ($null -eq (Get-HgsGuardian "UntrustedGuardian")) {
        New-HgsGuardian -Name "UntrustedGuardian" -GenerateCertificates 
    }
    
    $owner = Get-HgsGuardian "UntrustedGuardian"
    $kp = New-HgsKeyProtector -Owner $owner -AllowUntrustedRoot
    Set-VMKeyProtector -VMName $hyperVMachineName -KeyProtector $kp.RawData
    Enable-VMTPM -VMName $hyperVMachineName
}