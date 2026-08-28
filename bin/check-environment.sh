#!/usr/bin/env sh
set -u

missing_required=0

check_required() {
    if command -v "$1" >/dev/null 2>&1; then
        printf '[OK]       %s -> %s\n' "$1" "$(command -v "$1")"
    else
        printf '[REQUIRED] %s -> not found in PATH\n' "$1"
        missing_required=$((missing_required + 1))
    fi
}

check_optional() {
    if command -v "$1" >/dev/null 2>&1; then
        printf '[OK]       %s -> %s\n' "$1" "$(command -v "$1")"
    else
        printf '[OPTIONAL] %s -> not found in PATH\n' "$1"
    fi
}

printf '%s\n' 'Neovim environment check'
for command_name in nvim git curl rg; do
    check_required "$command_name"
done

for command_name in tree-sitter make cc clang gcc node codex codex-acp python3 python go java; do
    check_optional "$command_name"
done

if [ "$(uname -s)" = "Darwin" ]; then
    check_optional pngpaste
fi

printf '\n%s\n' 'After the first launch run: :ConfigHealth, :MasonToolsInstall, :TSUpdate'
exit "$missing_required"
