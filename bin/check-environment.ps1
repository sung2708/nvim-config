$ErrorActionPreference = "Continue"
Write-Host "Neovim environment check" -ForegroundColor Cyan
foreach ($name in @("nvim", "git", "rg", "tree-sitter", "zig", "g++", "node", "python", "go", "java")) {
    $command = Get-Command $name -ErrorAction SilentlyContinue
    if ($command) { Write-Host "[OK]   $name -> $($command.Source)" -ForegroundColor Green }
    else { Write-Host "[MISS] $name -> not found in PATH" -ForegroundColor Red }
}
Write-Host ""
Write-Host "After the first launch run: :checkhealth, :MasonToolsInstall, :TSUpdate" -ForegroundColor Yellow
