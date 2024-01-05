function Get-ScriptDirectory { Split-Path $MyInvocation.ScriptName }

# generate the path to the script in the common directory:
function Get-Configs
{
    $configFile = Join-Path (Get-ScriptDirectory) 'configs.json'
    $configs = Get-Content -Path $configFile | ConvertFrom-Json
    return $configs
}

$configs = Get-Configs
New-Item -ItemType Directory -path $configs.vmloc -ErrorAction SilentlyContinue
New-Item -ItemType Directory -path $configs.medialoc -ErrorAction SilentlyContinue
New-Item -ItemType Directory -path $configs.vhdloc -ErrorAction SilentlyContinue

