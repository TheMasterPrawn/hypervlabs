

function Get-Packages {
    #Set-ExecutionPolicy Bypass -Scope Process -Force

    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    choco install git.install -y
    choco install bginfo -y # machine info
    choco install vscode -y
    choco install firefox -y
    
    choco install speedtest -y
    choco install notepadplusplus -y
    choco install googlechrome -y
    choco install winaero-tweaker -y
    choco install fiddler -y

    choco install sysinternals --params "/InstallDir:C:\tools" --ignore-checksum -y --force
}


#Write-Host "Trusting PSgallery"
#Set-PSRepository -name "PSGallery" -InstallationPolicy Trusted 
Get-Packages


