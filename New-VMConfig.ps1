[CmdletBinding()]
param (
    [Parameter()][string]$hyperVMachineName = "Win10Pro1",
    [Parameter()][string]$MemoryStartupBytes = "4GB",
    [Parameter()][string]$VHDSizeBytes = "80GB",
    [Parameter()][string]$SwitchName = "LAB",
    [Parameter()][int]$Generation = 2,
    [Parameter()][int]$Processors = 4,
    [Parameter()][string]$MediaPath = "C:\vms\media\Windows10pro.iso"
)
function Get-ScriptDirectory { Split-Path $MyInvocation.ScriptName }

$helperScript = Join-Path (Get-ScriptDirectory) 'config\helpers.ps1'
. $helperScript

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

New-VM -Name $hyperVMachineName -Path $vmloc -MemoryStartupBytes ($MemoryStartupBytes / 1) `
    -NewVHDPath $vhdPath -NewVHDSizeBytes ($VHDSizeBytes / 1) -SwitchName $SwitchName `
    -Generation $Generation

Set-VMMemory $hyperVMachineName -DynamicMemoryEnabled $false
Set-VMProcessor -VMName $hyperVMachineName -Count $Processors
$medialoc = "$MediaPath"
Add-VMDVDDrive -VMName $hyperVMachineName -Path $medialoc

# Start and stop behaviour
Set-VM $hyperVMachineName -AutomaticStartAction Nothing 
Set-VM $hyperVMachineName -AutomaticStopAction TurnOff
Set-VM $hyperVMachineName -AutomaticCheckpointsEnabled $false
Set-VM $hyperVMachineName -Notes "Put something here"
Enable-VMIntegrationService -Name "Guest Service Interface" $hyperVMachineName

# add keys and enable TPM
Update-VMVersion -VMName $hyperVMachineName -Confirm:$false
    
if ($null -eq (Get-HgsGuardian "UntrustedGuardian")) {
    New-HgsGuardian -Name "UntrustedGuardian" -GenerateCertificates 
}
    
$owner = Get-HgsGuardian "UntrustedGuardian"
$kp = New-HgsKeyProtector -Owner $owner -AllowUntrustedRoot
Set-VMKeyProtector -VMName $hyperVMachineName -KeyProtector $kp.RawData
Enable-VMTPM -VMName $hyperVMachineName
