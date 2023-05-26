# hypervlabs

```ps1
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```

# windows 

Running Get-WindowsISO.ps1 will get win 10, 11 and Server 2022 evals into c:\vm\media

# networking

Create an Internal Network called LAB in Hyper-V virtual Switch manager. 
Then right click your network adapter and share it with the new Internal Network LAB

# windows admin center

https://www.microsoft.com/en-us/evalcenter/download-windows-admin-center

# usage

1. Open the template VM
2. Follow out of box setup experience
3. Create a local account with no password
4. In eleavated powershell paste in Install-Tools.ps1 and run
5. In eleavated powershell paste in New-LocalAdmin.ps1 and run
6. In eleavated powershell paste in SysPrepIt.ps1 and run

c:\windows\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown /unattend:C:\tools\auto.xml

on error

Shift + F10
HKEY_LOCAL_MACHINE\SYSTEM\Setup\Status\ChildCompletion Setup.exe to 3

# slmgr

Look at rearm values
slmgr.vbs /dlv 

# invalid machine state

https://michlstechblog.info/blog/windows-sysprep-error-machine-is-in-an-invalid-state-or-we-couldnt-update-the-recorded-state/

```cmd
reg query HKLM\System\Setup\status\SysprepStatus
```

Should look like 
HKEY_LOCAL_MACHINE\System\Setup\status\SysprepStatus
    GeneralizationState    REG_DWORD    0x7
    CleanupState           REG_DWORD    0x2

If not then 

```cmd
reg add HKLM\System\Setup\status\SysprepStatus /v GeneralizationState /t REG_DWORD /d 7 /f
reg add HKLM\System\Setup\status\SysprepStatus /v CleanupState        /t REG_DWORD /d 2 /f
```

# licence 

Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform