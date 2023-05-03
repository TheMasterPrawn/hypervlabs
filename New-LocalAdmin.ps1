[CmdletBinding()]
param (
    [Parameter()][String]$uname = "labmanager",
    [Parameter()][String]$pswd = "Labmanager2023!!"
)

$Password = convertto-securestring "$pswd" -asplaintext -force

New-LocalUser $uname -Password $Password -FullName $uname -Description "For lab management" `
    -PasswordNeverExpires:$true -UserMayNotChangePassword:$true
Add-LocalGroupMember -Group "Administrators" -Member $uname
