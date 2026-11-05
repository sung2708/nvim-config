# Run in a regular Windows PowerShell 5.1+ or PowerShell 7 window.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Invoke-Native {
    param([string]$Command, [string[]]$Arguments)
    $global:LASTEXITCODE = 0
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Command failed with exit code $LASTEXITCODE" }
}

if ($env:OS -ne 'Windows_NT' -or $env:PROCESSOR_ARCHITECTURE -ne 'AMD64') {
    throw 'This installer supports Windows x64. Use the Linux installer inside WSL2.'
}
$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($admin) { throw 'Open a regular PowerShell window, without Administrator privileges.' }

$scoopRoot = if ($env:SCOOP) { $env:SCOOP } else { Join-Path $env:USERPROFILE 'scoop' }
$env:PATH = "$(Join-Path $scoopRoot 'shims');$env:PATH"
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    $installer = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName() + '.ps1')
    Invoke-WebRequest 'https://get.scoop.sh' -UseBasicParsing -OutFile $installer
    try { & $installer } finally { Remove-Item $installer }
}
Invoke-Native scoop @('install', 'git')
foreach ($bucket in @('java', 'versions', 'extras')) {
    if (-not (Test-Path (Join-Path $scoopRoot "buckets\$bucket"))) { Invoke-Native scoop @('bucket', 'add', $bucket) }
}
Invoke-Native scoop @('install', 'extras/vcredist2022')
$packages = @('neovim', 'ripgrep', 'fd', 'fzf', 'make', 'zig', 'gcc', 'llvm', 'nodejs-lts', 'python313', 'go', 'maven', 'unzip', 'gzip', 'curl', 'temurin25-jdk')
Invoke-Native scoop (@('install') + $packages)
Invoke-Native scoop (@('update') + $packages)
$env:JAVA_HOME = Join-Path $scoopRoot 'apps\temurin25-jdk\current'
$env:PATH = "$env:JAVA_HOME\bin;$(Join-Path $scoopRoot 'shims');$env:PATH"
$env:SUNGP_INSTALL_JAVA_HOME = $env:JAVA_HOME
$runtimePaths = @('apps\python313\current', 'apps\nodejs-lts\current', 'apps\llvm\current\bin', 'apps\gcc\current\bin', 'shims') | ForEach-Object { Join-Path $scoopRoot $_ }
$env:SUNGP_INSTALL_PATH = "$env:JAVA_HOME\bin;" + ($runtimePaths -join ';')
$env:PATH = "$env:SUNGP_INSTALL_PATH;$env:PATH"

$env:NVIM_APPNAME = 'nvim'
Remove-Item Env:VIMINIT, Env:EXINIT -ErrorAction SilentlyContinue
$configDir = (Invoke-Native nvim @('--headless', '-u', 'NONE', '-i', 'NONE', '--cmd', "lua io.stdout:write(vim.fn.stdpath('config'))", '+qa')) -join ''
$dataDir = (Invoke-Native nvim @('--headless', '-u', 'NONE', '-i', 'NONE', '--cmd', "lua io.stdout:write(vim.fn.stdpath('data'))", '+qa')) -join ''
if (-not $configDir -or -not $dataDir) { throw 'Could not determine Neovim directories' }
New-Item -ItemType Directory -Force -Path (Split-Path $configDir -Parent) | Out-Null
$reuse = $false
if (Test-Path (Join-Path $configDir '.git')) {
    $origin = & git -C $configDir remote get-url origin
    $reuse = $LASTEXITCODE -eq 0 -and $origin -match 'github\.com[:/]sung2708/nvim-config(\.git)?$'
}
if ($reuse) {
    if (-not (Test-Path (Join-Path $configDir 'bin\bootstrap.lua'))) { throw 'Update this checkout to include bin/bootstrap.lua, then rerun.' }
} else {
    $staging = Join-Path (Split-Path $configDir -Parent) ('nvim-install-' + [guid]::NewGuid())
    Invoke-Native git @('clone', 'https://github.com/sung2708/nvim-config.git', $staging)
    if (-not (Test-Path (Join-Path $staging 'bin\bootstrap.lua'))) { throw 'Repository does not contain the installer yet.' }
    if (Test-Path $configDir) {
        $backup = $configDir + '.backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid()
        Move-Item $configDir $backup
        Write-Host "Previous config: $backup"
    }
    Move-Item $staging $configDir
}

$toolchain = Join-Path $dataDir 'nvim-config\toolchain'
Invoke-Native npm.cmd @('install', '--prefix', $toolchain, '--no-audit', '--no-fund', '--save-exact', 'tree-sitter-cli@0.26.11')
$env:PATH = "$toolchain\node_modules\tree-sitter-cli;$toolchain\node_modules\.bin;$env:PATH"
$env:SUNGP_INSTALL_PATH = "$toolchain\node_modules\tree-sitter-cli;$toolchain\node_modules\.bin;$env:SUNGP_INSTALL_PATH"
$provider = Join-Path $dataDir 'python-provider'
$python = Join-Path $scoopRoot 'apps\python313\current\python.exe'
Invoke-Native $python @('-m', 'venv', $provider)
$providerPython = Join-Path $provider 'Scripts\python.exe'
Invoke-Native $providerPython @('-m', 'pip', 'install', '--disable-pip-version-check', 'pynvim==0.6.0')
$env:SUNGP_INSTALL_PYTHON = $providerPython
Invoke-Native nvim @('--headless', '-u', 'NONE', '-i', 'NONE', '-l', (Join-Path $configDir 'bin\bootstrap.lua'), '--plugins')
Invoke-Native nvim @('--headless', '-u', 'NONE', '-i', 'NONE', '-l', (Join-Path $configDir 'bin\bootstrap.lua'))
Write-Host 'Installed. Open a new terminal and run: nvim .'
