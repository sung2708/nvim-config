#!/usr/bin/env bash
set -euo pipefail
staging=''
trap 'if [[ -n $staging && -d $staging ]]; then rm -rf -- "$staging"; fi' EXIT
trap 'printf "Installation failed at line %s. Fix the error above and rerun.\n" "$LINENO" >&2' ERR

[[ $(id -u) != 0 ]] || { echo 'Run as your regular user, not root.' >&2; exit 1; }
case "$(uname -s):$(uname -m)" in
    Darwin:arm64|Darwin:x86_64|Linux:x86_64|Linux:aarch64) ;;
    *) echo 'Supported: macOS, Linux/WSL2 on x86_64 or ARM64.' >&2; exit 1 ;;
esac

if [[ $(uname -s) == Linux ]]; then
    if command -v apt-get >/dev/null; then
        sudo apt-get update
        sudo apt-get install -y build-essential procps curl file git ca-certificates wl-clipboard xclip
    elif command -v dnf >/dev/null; then
        sudo dnf install -y gcc gcc-c++ make procps-ng curl file git ca-certificates wl-clipboard xclip
    elif command -v pacman >/dev/null; then
        sudo pacman -Syu --needed --noconfirm base-devel procps-ng curl file git ca-certificates wl-clipboard xclip
    else
        echo 'Supported Linux package managers: apt-get, dnf, pacman.' >&2; exit 1
    fi
fi

if ! command -v brew >/dev/null; then
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
        if [[ -x $candidate ]]; then eval "$("$candidate" shellenv)"; break; fi
    done
fi
if ! command -v brew >/dev/null; then
    installer=$(mktemp)
    curl --fail --location --retry 3 https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$installer"
    /bin/bash "$installer"
    rm -f "$installer"
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
        if [[ -x $candidate ]]; then eval "$("$candidate" shellenv)"; break; fi
    done
fi
brew install neovim git curl ripgrep fd fzf make unzip gzip node@24 python@3.13 go openjdk@25 maven clang-format
if [[ $(uname -s) == Darwin ]]; then brew install pngpaste; fi

brew_prefix=$(brew --prefix)
shellenv_line="eval \"\$(\"$brew_prefix/bin/brew\" shellenv)\""
login_shell=${SHELL:-/bin/bash}
case "${login_shell##*/}" in
    zsh) profiles=("$HOME/.zprofile" "$HOME/.zshrc") ;;
    bash) profiles=("$HOME/.bashrc" "$HOME/.profile"); [[ ! -f $HOME/.bash_profile ]] || profiles+=("$HOME/.bash_profile") ;;
    *) profiles=("$HOME/.profile") ;;
esac
for profile in "${profiles[@]}"; do
    touch "$profile"
    if ! grep -Fqx "$shellenv_line" "$profile"; then printf '\n%s\n' "$shellenv_line" >> "$profile"; fi
done
node_prefix=$(brew --prefix node@24)
python_prefix=$(brew --prefix python@3.13)
java_prefix=$(brew --prefix openjdk@25)
export JAVA_HOME="$java_prefix/libexec/openjdk.jdk/Contents/Home"
if [[ $(uname -s) == Linux ]]; then export JAVA_HOME="$java_prefix/libexec"; fi
export PATH="$node_prefix/bin:$python_prefix/libexec/bin:$JAVA_HOME/bin:$brew_prefix/bin:$brew_prefix/sbin:$PATH"
export SUNGP_INSTALL_PATH="$node_prefix/bin:$python_prefix/libexec/bin:$JAVA_HOME/bin:$brew_prefix/bin:$brew_prefix/sbin"
export SUNGP_INSTALL_JAVA_HOME="$JAVA_HOME"

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
repo=https://github.com/sung2708/nvim-config.git
mkdir -p "$(dirname "$config_dir")"
if [[ -d $config_dir/.git ]] && [[ $(git -C "$config_dir" remote get-url origin) =~ github.com[:/]sung2708/nvim-config(\.git)?$ ]]; then
    [[ -f $config_dir/bin/bootstrap.lua ]] || { echo 'Update this checkout to include bin/bootstrap.lua, then rerun.' >&2; exit 1; }
else
    staging=$(mktemp -d "$(dirname "$config_dir")/nvim-install.XXXXXX")
    git clone "$repo" "$staging"
    [[ -f $staging/bin/bootstrap.lua ]] || { echo 'Repository does not contain the installer yet.' >&2; exit 1; }
    if [[ -e $config_dir || -L $config_dir ]]; then
        backup="$config_dir.backup-$(date +%Y%m%d-%H%M%S)-$$"
        mv "$config_dir" "$backup"
        printf 'Previous config: %s\n' "$backup"
    fi
    mv "$staging" "$config_dir"
fi

export NVIM_APPNAME=nvim
unset VIMINIT EXINIT
npm install --prefix "$data_dir/nvim-config/toolchain" --no-audit --no-fund --save-exact tree-sitter-cli@0.26.11
export PATH="$data_dir/nvim-config/toolchain/node_modules/tree-sitter-cli:$data_dir/nvim-config/toolchain/node_modules/.bin:$PATH"
export SUNGP_INSTALL_PATH="$data_dir/nvim-config/toolchain/node_modules/tree-sitter-cli:$data_dir/nvim-config/toolchain/node_modules/.bin:$SUNGP_INSTALL_PATH"
python3 -m venv "$data_dir/python-provider"
"$data_dir/python-provider/bin/python" -m pip install --disable-pip-version-check 'pynvim==0.6.0'
export SUNGP_INSTALL_PYTHON="$data_dir/python-provider/bin/python"
nvim --headless -u NONE -i NONE -l "$config_dir/bin/bootstrap.lua" --plugins
nvim --headless -u NONE -i NONE -l "$config_dir/bin/bootstrap.lua"
printf '\nInstalled. Open Neovim: %s/bin/nvim .\n' "$brew_prefix"
printf 'Open a new terminal to use nvim from PATH. Bash/zsh startup files have been configured.\n'
