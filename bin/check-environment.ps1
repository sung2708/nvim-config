$ErrorActionPreference = "Continue"

$required = @("nvim", "git", "curl", "rg")
$optional = @("tree-sitter", "make", "zig", "g++", "node", "codex", "codex-acp", "python", "go", "java")
if ($IsMacOS) {
    $optional += "pngpaste"
}
$missingRequired = 0

Write-Host "Neovim environment check" -ForegroundColor Cyan

foreach ($name in $required) {
    $command = Get-Command $name -ErrorAction SilentlyContinue
    if ($command) {
        Write-Host "[OK]       $name -> $($command.Source)" -ForegroundColor Green
    } else {
        Write-Host "[REQUIRED] $name -> not found in PATH" -ForegroundColor Red
        $missingRequired++
    }
}

foreach ($name in $optional) {
    $command = Get-Command $name -ErrorAction SilentlyContinue
    if ($command) {
        Write-Host "[OK]       $name -> $($command.Source)" -ForegroundColor Green
    } else {
        Write-Host "[OPTIONAL] $name -> not found in PATH" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "After the first launch run: :ConfigHealth, :MasonToolsInstall, :TSUpdate" -ForegroundColor Cyan

if ($missingRequired -gt 0) {
    exit 1
}
