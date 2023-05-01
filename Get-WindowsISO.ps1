[CmdletBinding()]
param (
    [Parameter()][bool]$parallel = $true
)
function Get-ScriptDirectory { Split-Path $MyInvocation.ScriptName }

$helperScript = Join-Path (Get-ScriptDirectory) 'config\helpers.ps1'
. $helperScript

$configs = Get-Configs
$OSTemplates = $configs.OperatingSystems.templates

function Get-Media($url, $path) {
    Write-host "Getting $path from $url"
    $stopwatch = [system.diagnostics.stopwatch]::StartNew()
    Invoke-WebRequest -UseBasicParsing -URI $url -Method GET -OutFile "$path"
    $stopwatch.ela
}

$jobs = @()

foreach ($os in $OSTemplates) {
    $outputPath = "$($configs.medialoc)\$($os.ID).iso"
    if ((Test-Path -path $outputPath) -eq $false) {
        if ($parallel) {
            Write-host "$($os.ID).iso"          
            $invokeWebParams = @{
                "Uri"     = $os.URL
                "OutFile" = $outputPath
            }
    
            $jobs += Start-Job -Name $os.ID -ScriptBlock {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
                Invoke-WebRequest @Using:invokeWebParams -UseBasicParsing
            }
        }
        else {
            Write-host "$($os.ID).iso"
            Get-Media -url $os.URL -path $outputPath
        }
    }
    else {
        Write-host "$($os.Name) found at $outputPath" -ForegroundColor DarkGreen
    }   
}

if($jobs.count -ne 0)
{

    $running = $true

    while ($running) {
        $tmpjobs = @()
        foreach ($job in $jobs) {
            $tmpjob = Get-Job -Id $job.id
            Write-Host "job id $($tmpjob.id) download $($tmpjob.Name) is $($tmpjob.State)"
            $tmpjobs += $tmpjob 
        }
        $allState = $tmpjobs | Where-Object { $_.State -eq "Running" }
        if ($null -eq $allState) { $running = $false }
        Start-Sleep -Seconds 5
    }
}




