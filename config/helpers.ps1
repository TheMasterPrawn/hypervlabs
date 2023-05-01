function Get-ScriptDirectory { Split-Path $MyInvocation.ScriptName }

# generate the path to the script in the common directory:
function Get-Configs
{
    $configFile = Join-Path (Get-ScriptDirectory) 'configs.json'
    $config = Get-Content -Path $configFile | ConvertFrom-Json
    return $config
}

$config = Get-Configs
New-Item -ItemType Directory -path $config.vmloc -ErrorAction SilentlyContinue
New-Item -ItemType Directory -path $config.medialoc -ErrorAction SilentlyContinue
New-Item -ItemType Directory -path $config.vhdloc -ErrorAction SilentlyContinue

