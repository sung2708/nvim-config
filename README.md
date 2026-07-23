# SUNGP Neovim

An IDE-oriented Neovim configuration for Python, Go, JavaScript/TypeScript,
Java, C/C++, Lua, and Markdown. It uses `lazy.nvim`, native LSP, Blink
completion, Telescope, FzfLua, Treesitter, DAP, Neotest, and a compact Snacks
dashboard.

The configuration is designed around five goals:

- Fast startup through event, command, keymap, and filetype-based lazy loading.
- Fast navigation with Telescope for rich workflows and FzfLua for speed.
- Complete coding support with LSP, completion, formatting, linting, testing,
  debugging, and Git integrations.
- One configuration for Windows, Linux, and macOS.
- Clear ownership boundaries between plugin specifications and integrations.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Install System Tools](#install-system-tools)
- [Install the Configuration](#install-the-configuration)
- [First Start](#first-start)
- [Managed Dependencies](#managed-dependencies)
- [Language Support](#language-support)
- [Configuration Layout](#configuration-layout)
- [Operating System Behavior](#operating-system-behavior)
- [User Interface](#user-interface)
- [Keymaps](#keymaps)
- [Optional Features](#optional-features)
- [Performance](#performance)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting)

## Features

| Area | Components |
| --- | --- |
| Plugin manager | lazy.nvim and `lazy-lock.json` |
| LSP | Native `vim.lsp`, nvim-lspconfig, Mason |
| Completion | blink.cmp, friendly-snippets, signature help |
| Formatting | Conform, Ruff, Prettier, Stylua, gofumpt, goimports |
| Linting | nvim-lint, ESLint, Ruff, markdownlint, ShellCheck |
| Search | Telescope, telescope-fzf-native, FzfLua |
| Navigation | Flash, Neo-tree, Bufferline, Treesitter textobjects |
| Diagnostics | Trouble, Todo Comments, Lualine |
| Git | Gitsigns, Fugitive, Diffview |
| Debugging | nvim-dap, nvim-dap-ui, debugpy, Delve, JS Debug, Java Debug |
| Testing | Neotest for Python, Go, Jest, and Java |
| UI | Snacks dashboard, WhichKey, Noice, Notify, Tokyonight |
| Cursor | smear-cursor.nvim, including Insert mode |

## Requirements

### Core Requirements

| Tool | Purpose |
| --- | --- |
| Neovim `>= 0.11` | Native LSP APIs and current plugin support |
| Git | Bootstrap lazy.nvim and download plugins |
| Internet access | Required only for initial installation and updates |
| ripgrep (`rg`) | File search, live grep, Todo, Telescope, and FzfLua |
| fzf | FzfLua backend |
| make | Build telescope-fzf-native |
| C compiler or Zig | Build native extensions and Treesitter parsers |
| unzip, gzip, tar | Extract packages installed by Mason |
| curl or wget | Download packages installed by Mason |

`fd` is optional. The current Telescope and FzfLua file pickers use
`rg --files`, but other picker configurations may still benefit from `fd`.

A Nerd Font is not required for Neovim itself, but it is strongly recommended.
Without one, icons in WhichKey, Neo-tree, Trouble, Lualine, and the dashboard
may appear as empty squares.

### Language Runtimes

Install only the runtimes for the languages you use:

| Language | External requirement |
| --- | --- |
| Python | Python 3; `uv` is optional |
| Go | Go toolchain |
| JavaScript/TypeScript | Node.js and npm |
| Java | JDK 21; Maven or Gradle when the project has no wrapper |
| C/C++ | Clang, GCC, or Zig |
| Lua | No separate runtime is required to edit Neovim configuration |

Mason installs language servers, formatters, linters, and debug adapters. It
does not replace the runtime or compiler required by a project. For example,
Mason can install `gopls`, but the Go toolchain is still required to build and
test Go code.

### Optional Tools

| Tool | Used by |
| --- | --- |
| PowerShell 7 (`pwsh`) | Improved terminal behavior on Windows |
| fd | Alternative fast file discovery |
| uv | Python environments and the Python REPL |
| Maven | Java projects without `mvnw` |
| Gradle | Java projects without `gradlew` |
| Lazygit | `Space+gg` |
| Lazydocker and Docker | `Space+ld` |
| GitHub Copilot | AI suggestions in Insert mode |
| xclip, xsel, or wl-clipboard | System clipboard integration on Linux |

## Install System Tools

### Windows 10/11

The configuration has first-class support for
[Scoop](https://github.com/ScoopInstaller/Install). Open a regular PowerShell
session; Administrator privileges are not required:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

scoop bucket add java
scoop install git neovim ripgrep fd fzf make zig nodejs python go maven unzip gzip
scoop install java/temurin21-jdk
```

PowerShell 7 is recommended:

```powershell
scoop install pwsh
```

Verify the installation:

```powershell
nvim --version
git --version
rg --version
fzf --version
zig version
node --version
python --version
go version
java -version
mvn --version
```

When Scoop is present, the configuration automatically detects:

- `%USERPROFILE%\scoop\apps\go\current\bin`
- `%USERPROFILE%\scoop\apps\maven\current\bin`
- `%USERPROFILE%\scoop\apps\temurin21-jdk\current`

`JAVA_HOME` is assigned from Scoop only when the variable is not already set.
An existing user-defined value always takes precedence.

### Ubuntu/Debian

```bash
sudo apt update
sudo apt install git ripgrep fd-find fzf make gcc g++ \
  nodejs npm python3 python3-venv python3-pip golang-go \
  openjdk-21-jdk maven unzip gzip curl
```

Some Debian and Ubuntu releases install `fd` as `fdfind`:

```bash
mkdir -p ~/.local/bin
ln -s "$(command -v fdfind)" ~/.local/bin/fd
```

Ensure `~/.local/bin` is in `PATH`. Distribution packages may provide an older
Neovim release. If it is below `0.11`, install a current build using the
[official Neovim instructions](https://github.com/neovim/neovim/blob/master/INSTALL.md).

Optional clipboard packages:

```bash
# Wayland
sudo apt install wl-clipboard

# X11
sudo apt install xclip
```

If the distribution does not provide `openjdk-21-jdk`, install another JDK 21
distribution and export:

```bash
export JAVA_HOME=/path/to/jdk-21
export PATH="$JAVA_HOME/bin:$PATH"
```

### macOS

Install Xcode Command Line Tools and Homebrew packages:

```bash
xcode-select --install
brew install neovim git ripgrep fd fzf zig node python go openjdk@21 maven
```

Add JDK 21 to the shell profile:

```bash
export JAVA_HOME="$(brew --prefix openjdk@21)/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
```

macOS already provides `pbcopy` and `pbpaste`, so no separate clipboard package
is required.

## Install the Configuration

### 1. Back Up an Existing Configuration

Windows PowerShell:

```powershell
Rename-Item "$env:LOCALAPPDATA\nvim" "nvim.backup" -ErrorAction SilentlyContinue
Rename-Item "$env:LOCALAPPDATA\nvim-data" "nvim-data.backup" -ErrorAction SilentlyContinue
```

Linux/macOS:

```bash
mv "${XDG_CONFIG_HOME:-$HOME/.config}/nvim" \
  "${XDG_CONFIG_HOME:-$HOME/.config}/nvim.backup" 2>/dev/null || true
mv "${XDG_DATA_HOME:-$HOME/.local/share}/nvim" \
  "${XDG_DATA_HOME:-$HOME/.local/share}/nvim-data.backup" 2>/dev/null || true
```

### 2. Clone the Repository

Windows PowerShell:

```powershell
git clone https://github.com/sung2708/nvim-config.git "$env:LOCALAPPDATA\nvim"
```

Linux/macOS:

```bash
git clone https://github.com/sung2708/nvim-config.git \
  "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
```

### 3. Open Neovim

```bash
nvim README.md
```

`lazy.nvim` bootstraps itself into Neovim's data directory. Because plugins
are lazy-loaded, the dashboard may appear before Mason has finished installing
development tools. Opening `README.md` also loads the Markdown-specific
Treesitter and rendering integrations.

## First Start

Run these commands inside Neovim:

```vim
:Lazy sync
:MasonToolsInstall
:TSUpdate
:Lazy load nvim-dap
:Lazy load neotest
:NeotestJava setup
:checkhealth
```

What each command does:

1. `Lazy sync` installs plugins at the commits recorded in `lazy-lock.json`.
2. `MasonToolsInstall` installs LSP servers, formatters, linters, and Java/JS
   debug adapters.
3. `TSUpdate` installs or updates Treesitter parsers.
4. Loading `nvim-dap` allows Mason to install debugpy, Delve, and codelldb.
5. `NeotestJava setup` downloads the JUnit Console required by Java tests.
6. `checkhealth` validates providers, executables, and plugin integrations.

Plugins can also be bootstrapped without opening the UI:

```bash
nvim --headless "+Lazy! sync" +qa
```

After installation, open one file for each language you use. LSP servers and
language-specific plugins start only when a matching buffer is opened.

## Managed Dependencies

### lazy.nvim

`lazy.nvim` manages every plugin. Tested plugin commits are recorded in
`lazy-lock.json`; keep the lockfile under version control to use identical
versions across machines.

Plugin specifications are grouped by responsibility:

| File | Responsibility |
| --- | --- |
| `lua/plugins/lsp.lua` | LSP, Mason, formatting, and linting |
| `lua/plugins/completion.lua` | Completion, snippets, and signatures |
| `lua/plugins/treesitter.lua` | Parsers and textobjects |
| `lua/plugins/search.lua` | Telescope and FzfLua |
| `lua/plugins/ui.lua` | Dashboard, statusline, notifications, WhichKey |
| `lua/plugins/git.lua` | Gitsigns, Fugitive, and Diffview |
| `lua/plugins/editor.lua` | Explorer, Trouble, Flash, Todo, editing, cursor |
| `lua/plugins/debug.lua` | DAP, Neotest, and adapters |
| `lua/plugins/languages.lua` | Python, Go, TypeScript, and Java |

### Mason

Language servers installed and enabled automatically:

```text
clangd  cssls  eslint  gopls  html  jsonls
lua_ls  pyright  ruff  vimls
```

Tools managed by `mason-tool-installer`:

```text
clang-format           eslint_d             gomodifytags
gofumpt                goimports            google-java-format
gotests                iferr                impl
java-debug-adapter     jdtls                js-debug-adapter
markdownlint-cli2      prettier             ruff
shellcheck             stylua              typescript-language-server
```

Debug adapters managed through Mason:

```text
debugpy  delve  codelldb
```

These packages do not need to be installed globally unless they are also used
outside Neovim.

### Treesitter

Parsers installed automatically:

```text
bash  c  cpp  css  go  gomod  gosum  html  javascript  java
json  lua  markdown  markdown_inline  python  query  toml
tsx  typescript  vim  vimdoc  yaml
```

On Windows, `bin/zig-cc.cmd` and `bin/zig-cxx.cmd` expose Zig as a C/C++
compiler for Treesitter. These `.cmd` wrappers are Windows-only. Linux and
macOS use `CC`/`CXX` when set, then fall back to `cc`, `clang`, `gcc`, `c++`,
`clang++`, or `g++`.

## Language Support

### Python

| Role | Tool |
| --- | --- |
| LSP and types | Pyright |
| Lint and quick fixes | Ruff LSP |
| Formatting and imports | Ruff |
| Virtual environments | venv-selector.nvim |
| Debugging | debugpy |
| Testing | neotest-python |

The Python terminal chooses an interpreter in this order:

1. `uv run python`
2. `python3`
3. `python`

### Go

| Role | Tool |
| --- | --- |
| LSP | gopls |
| Formatting and imports | gofumpt, goimports |
| Code generation | gopher.nvim, gomodifytags, gotests, impl, iferr |
| Debugging | Delve |
| Testing | neotest-golang |

On Windows x86_64, the configuration sets `GOARCH=amd64` only when `GOARCH`
does not already exist.

### JavaScript/TypeScript

| Role | Tool |
| --- | --- |
| LSP | typescript-tools.nvim |
| Diagnostics | ESLint |
| Formatting | eslint_d and Prettier |
| Debugging | js-debug-adapter |
| Testing | neotest-jest |
| JSX/TSX tags | nvim-ts-autotag |

`typescript-tools.nvim` owns the TypeScript language server integration, so
`ts_ls` is not enabled a second time.

### Java

| Role | Tool |
| --- | --- |
| LSP | nvim-jdtls and Eclipse JDTLS |
| Annotations | Lombok |
| Formatting | google-java-format |
| Debugging | java-debug-adapter |
| Testing | neotest-java and JUnit Console |

This configuration runs JDTLS with JDK 21. A project should contain at least
one recognized root marker: `.git`, `mvnw`, `pom.xml`, `gradlew`,
`build.gradle`, or `settings.gradle`.

The first Java project open may take longer while JDTLS indexes the workspace
and downloads sources. Run `:NeotestJava setup` once for each new Neovim data
directory.

### Filetype Indentation

| Filetype | Settings |
| --- | --- |
| Python, Lua, Java | 4 spaces |
| JavaScript, TypeScript, JSX, TSX | 2 spaces |
| Go | Tabs displayed at width 4 |
| Markdown | Wrap and linebreak enabled |

## Configuration Layout

```text
nvim/
|-- init.lua
|-- init.vim
|-- lazy-lock.json
|-- bin/
|   |-- zig-cc.cmd
|   `-- zig-cxx.cmd
|-- lua/
|   |-- config/
|   |   |-- init.lua
|   |   |-- options.lua
|   |   |-- keymaps.lua
|   |   |-- autocmds.lua
|   |   `-- lazy.lua
|   |-- plugins/
|   |-- integrations/
|   `-- helper/
|-- after/
|   `-- ftplugin/
|-- snippets/
|-- spell/
`-- README.md
```

Responsibilities:

- `init.lua`: primary entrypoint.
- `init.vim`: compatibility shim for environments where `VIMINIT` still
  points to `init.vim`.
- `lua/config/`: global options, keymaps, autocmds, and lazy bootstrap.
- `lua/plugins/`: plugin specifications, dependencies, and lazy-load rules.
- `lua/integrations/`: plugin setup and cross-plugin integration.
- `after/ftplugin/`: per-filetype options.
- `lazy-lock.json`: pinned plugin commits.

Do not manually prepend `runtimepath` or `packpath`. The repository already
lives in `stdpath("config")`, and lazy.nvim owns plugin runtime paths.

## Operating System Behavior

### PATH and Environment Variables

`lua/config/options.lua`:

- Uses `;` as the Windows `PATH` separator and `:` on Linux/macOS.
- Adds `UV_PYTHON_BIN_DIR` and `UV_TOOL_BIN_DIR` when they exist.
- Detects Scoop installations of Go, Maven, and Temurin 21 on Windows.
- Sets `JAVA_HOME` only when the user has not already set it.
- Sets `GOARCH=amd64` only on Windows x86_64 when the variable is unset.

Environment variables may be set before starting Neovim.

Windows PowerShell:

```powershell
$env:JAVA_HOME = "C:\path\to\jdk-21"
$env:CC = "clang"
$env:CXX = "clang++"
nvim
```

Linux/macOS:

```bash
export JAVA_HOME=/path/to/jdk-21
export CC=clang
export CXX=clang++
nvim
```

### Clipboard

- Windows uses `clipboard=unnamed`.
- Linux and macOS use `clipboard=unnamedplus`.

Check clipboard providers with:

```vim
:checkhealth provider
```

### Shell and Terminal

- Windows prefers `pwsh` and falls back to Windows PowerShell.
- The Windows shell is configured for UTF-8 input and output.
- Linux and macOS retain the shell inherited by Neovim.

### Treesitter Compiler

- Windows prefers the Zig wrappers in `bin/`.
- Linux and macOS honor `CC` and `CXX`, then detect a system compiler.

## User Interface

### Dashboard

The Snacks dashboard displays the `SUNGP` header, shortcuts, four recent
files, and a compact Git status section.

Lualine and Bufferline are hidden while the dashboard is active so the content
can remain vertically centered. Both are restored automatically when the
dashboard closes or a file is opened.

Dashboard spacing is intentionally compact:

- No empty row between every shortcut.
- Small gaps separate the header, shortcut list, recent files, and Git status.
- Width and pane spacing are reduced to avoid an excessively wide layout.

### Command Line and Completion

Noice renders the centered command line. Blink supplies command completion
after `:` and uses a separate rounded menu with horizontal content padding.
The menu is positioned below the Noice border with a visible row of separation.

### Popup Spacing

- Noice content popups use rounded borders and inner padding.
- WhichKey uses one row and two columns of padding.
- FzfLua uses one row and two columns of internal padding.
- Telescope adds left-side spacing to prompts and results.
- Trouble adds top and left spacing to result views.
- Notify uses its wrapped renderer for message padding.

### Smear Cursor

Smear Cursor starts with Neovim and remains enabled in Insert mode:

```lua
cursor_color = "#7DCFFF"
smear_insert_mode = true
vertical_bar_cursor_insert_mode = true
```

Toggle it at runtime with:

```vim
:SmearCursorToggle
```

## Keymaps

`Leader` is `Space`. `LocalLeader` is `\`.

Press `Space` and wait briefly to open WhichKey. All major groups include
descriptions and icons.

### Core Navigation

| Key | Mode | Action |
| --- | --- | --- |
| `Alt+h/j/k/l` | Normal/Terminal | Move between windows |
| `Ctrl+Arrow` | Normal | Resize the current window |
| `Space+j/k` | Normal/Visual | Move a line or selection |
| `<` / `>` | Visual | Indent and retain the selection |
| `Ctrl+d/u` | Normal | Half-page scroll and center |
| `n` / `N` | Normal | Next/previous search result and center |
| `Esc` | Normal | Clear search highlighting |
| `Tab` / `Shift+Tab` | Normal | Next/previous buffer |
| `Space+bc` | Normal | Close buffer while preserving layout |
| `Space+bp` | Normal | Pin or unpin buffer |
| `Space+be/bq` | Normal | Move buffer right/left |

### Explorer and Dashboard

| Key | Action |
| --- | --- |
| `Ctrl+n` | Reveal the current file in Neo-tree |
| `Ctrl+t` | Toggle Neo-tree |
| `Ctrl+f` | Focus Neo-tree |
| `Space+sd` | Open the SUNGP dashboard |

Dashboard keys:

| Key | Action |
| --- | --- |
| `f` | Find file |
| `g` | Live grep |
| `b` | List buffers |
| `e` | Open file explorer |
| `s` | Git status |
| `d` | Git diff |
| `x` | Diagnostics |
| `t` | Test summary |
| `c` | Open the configuration directory |
| `n` | Create a new file |
| `q` | Quit Neovim |

### Search

| Key | Action |
| --- | --- |
| `Space+ff` | Find files with Telescope |
| `Space+fg` | Live grep with Telescope |
| `Space+fb` | Find buffers with Telescope |
| `Space+fh` | Search help tags |
| `Space+fe` | Telescope file browser |
| `Space+fF` | Fast file search with FzfLua |
| `Space+fG` | Fast live grep with FzfLua |
| `Space+fB` | Fast buffer search with FzfLua |

Convention: lowercase `f` mappings use Telescope; uppercase variants use
FzfLua.

Inside FzfLua:

| Key | Action |
| --- | --- |
| `Ctrl+d/u` | Scroll preview down/up |
| `Ctrl+q` | Select all and accept |

### Flash and Treesitter

| Key | Mode | Action |
| --- | --- | --- |
| `s` | Normal/Visual/Operator | Flash jump |
| `S` | Normal/Visual/Operator | Flash Treesitter |
| `am` / `im` | Visual/Operator | Around/inside function |
| `ac` / `ic` | Visual/Operator | Around/inside class |
| `as` | Visual/Operator | Around scope |
| `Space+a/A` | Normal | Swap next/previous parameter |
| `]m` / `[m` | Normal/Visual/Operator | Next/previous function start |
| `]M` / `[M` | Normal/Visual/Operator | Next/previous function end |
| `]]` / `[[` | Normal/Visual/Operator | Next/previous class start |
| `][` / `[]` | Normal/Visual/Operator | Next/previous class end |
| `]o` | Normal/Visual/Operator | Next loop |
| `]s` | Normal/Visual/Operator | Next scope |
| `]z` | Normal/Visual/Operator | Next fold |
| `]C` / `[C` | Normal/Visual/Operator | Next/previous conditional |

### LSP

LSP mappings are buffer-local and exist only after a language server attaches:

| Key | Action |
| --- | --- |
| `gd` | Definitions through Telescope |
| `gy` | Type definitions through Telescope |
| `gi` | Implementations through Telescope |
| `gr` | References through FzfLua |
| `gO` | Document symbols through FzfLua |
| `Space+cS` | Workspace symbols |
| `K` / `Space+e` | Hover documentation |
| `Space+ca` | Code action |
| `Space+rn` | Rename symbol |
| `Space+cd` | Line diagnostics |
| `]d` / `[d` | Next/previous diagnostic |
| `Space+ci` | Toggle inlay hints when supported |
| `Space+cf` | Format buffer or selection |
| `Space+cL` | Run lint |
| `Space+cm` | Open Mason |
| `Space+cs` | Trouble document symbols |
| `Space+cl` | Trouble LSP list |

Diagnostics do not update while Insert mode is active, which keeps typing
stable and reduces unnecessary redraws.

### Insert Completion

| Key | Action |
| --- | --- |
| `Ctrl+Space` | Show completion or documentation |
| `Ctrl+e` | Hide completion |
| `Ctrl+n/p` | Select next/previous item |
| `Ctrl+j/k` | Select item or jump through snippets |
| `Tab` / `Shift+Tab` | Completion or snippet next/previous |
| `Enter` | Accept completion |
| `Ctrl+b/f` | Scroll documentation |
| `Ctrl+l` | Toggle signature help |

### Command-Line Completion

Typing `:` automatically opens Blink command suggestions. `/` and `?` search
do not open the menu automatically, but completion can still be requested
manually.

| Key | Action |
| --- | --- |
| `Tab` | Show the menu or select the next item |
| `Shift+Tab` | Select the previous item |
| `Ctrl+Space` | Show completion manually |
| `Ctrl+n/p` | Select next/previous item |
| `Ctrl+y` | Accept the selected item |
| `Ctrl+e` | Cancel completion |

### Formatting and Linting

| Command or key | Action |
| --- | --- |
| `Space+cf` | Format now |
| `Space+cL` | Lint now |
| `:FormatDisable` | Disable format-on-save globally |
| `:FormatDisable!` | Disable format-on-save for the current buffer |
| `:FormatEnable` | Re-enable format-on-save |
| `:ConformInfo` | Show active formatter information |

### Todo and Trouble

| Key | Action |
| --- | --- |
| `Space+xx` | Workspace diagnostics |
| `Space+xX` | Current buffer diagnostics |
| `Space+xL` | Location list |
| `Space+xQ` | Quickfix list |
| `]t` / `[t` | Next/previous Todo |
| `Space+xt` | All Todos in Trouble |
| `Space+xT` | All Todos in Telescope |
| `Space+xf` | All Todos in FzfLua |
| `Space+xF` | TODO/FIX/FIXME only in FzfLua |
| `Space+xR` | TODO/FIX/FIXME only in Trouble |
| `Space+xq/xl` | Todos in quickfix/location list |

Recognized tags: `TODO:`, `FIX:`, `FIXME:`, `HACK:`, `WARN:`, `PERF:`, and
`NOTE:`.

### Git

| Key | Action |
| --- | --- |
| `Space+gs` | Git status |
| `Space+gc` | Git commit |
| `Space+gp` | Git push |
| `Space+gl` | Git pull |
| `Space+gd` | Open Diffview |
| `Space+gD` | Close Diffview |
| `Space+gh` | File history |
| `]c` / `[c` | Next/previous hunk |
| `Space+hs/hr` | Stage/reset hunk |
| `Space+hS/hR` | Stage/reset buffer |
| `Space+hp/hi` | Preview hunk in popup/inline |
| `Space+hb` | Blame current line |
| `Space+hd/hD` | Diff against index/previous commit |
| `Space+hq/hQ` | Buffer/all hunks to quickfix |
| `Space+tb/tw/tl/tn` | Toggle blame/word diff/line/number highlight |
| `ih` | Select hunk in Visual/Operator mode |

### Debugging

| Key | Action |
| --- | --- |
| `F5` | Continue or start |
| `F10` | Step over |
| `F11` | Step into |
| `F12` | Step out |
| `Space+db` | Toggle breakpoint |
| `Space+dB` | Set conditional breakpoint |
| `Space+dr` | Open debug REPL |
| `Space+dl` | Run the previous debug configuration |
| `Space+du` | Toggle DAP UI |

### Testing

| Key | Action |
| --- | --- |
| `Space+nt` | Run nearest test |
| `Space+nf` | Run tests in the current file |
| `Space+nT` | Run the complete test suite |
| `Space+ns` | Toggle test summary |
| `Space+no` | Open test output |
| `Space+nO` | Toggle output panel |
| `Space+nw` | Toggle watch mode |

### Python Keymaps

| Key | Action |
| --- | --- |
| `Space+pv` | Select a virtual environment with FzfLua |
| `Space+py` | Open a Python REPL terminal |

### Go Keymaps

| Key | Action |
| --- | --- |
| `Space+Gi` | Insert `if err != nil` |
| `Space+Gt` | Add JSON struct tags |
| `Space+GT` | Remove struct tags |
| `Space+Gc` | Generate a symbol comment |
| `Space+Gf` | Generate a function test |
| `Space+GF` | Generate tests for the current file |

### JavaScript/TypeScript Keymaps

| Key | Action |
| --- | --- |
| `Space+Ti` | Organize imports |
| `Space+Ta` | Add missing imports |
| `Space+Tu` | Remove unused code and imports |
| `Space+Tf` | Apply all available fixes |
| `Space+Tr` | Rename file and update imports |

### Java Keymaps

| Key | Mode | Action |
| --- | --- | --- |
| `Space+Jo` | Normal | Organize imports |
| `Space+Jv` | Normal/Visual | Extract variable |
| `Space+Jc` | Normal/Visual | Extract constant |
| `Space+Jm` | Visual | Extract method |
| `Space+Jt` | Normal | Run nearest test |
| `Space+JT` | Normal | Run all tests in the file |
| `Space+Ju` | Normal | Refresh Maven/Gradle project configuration |

### Terminal

| Key | Mode | Action |
| --- | --- | --- |
| `Ctrl+\` | Normal/Terminal | Toggle terminal |
| `Space+th` | Normal | Horizontal terminal |
| `Space+tv` | Normal | Vertical terminal |
| `Space+tf` | Normal | Floating terminal |
| `Space+py` | Normal | Python REPL |
| `Space+gg` | Normal | Lazygit, when installed |
| `Space+ld` | Normal | Lazydocker, when installed |
| `Space+s` | Visual | Send selection to terminal |
| `Esc` or `jk` | Terminal | Return to Normal mode |
| `Ctrl+h/j/k/l` | Terminal | Move between windows |

Git terminal commands:

```vim
:TermGitPush
:TermGitPushF
```

`TermGitPushF` performs a force push. Use it only when the branch history and
remote impact are understood.

### Comments, Surround, and Multiple Cursors

| Key | Action |
| --- | --- |
| `gcc` | Toggle line comment |
| `gc{motion}` | Comment by motion |
| `gc` | Comment Visual selection |
| `ys{motion}{char}` | Add surround |
| `ds{char}` | Delete surround |
| `cs{old}{new}` | Change surround |
| `S{char}` | Surround Visual selection |
| `Alt+n` | Start/select next word occurrence |
| `Alt+a` | Select all matching words |
| `g Alt+n` | Start without word boundaries |
| `g Alt+a` | Select all without word boundaries |
| `Alt+p` | Previous multiple-cursor occurrence |
| `Alt+x` | Skip current occurrence |
| `Esc` | Exit multiple cursors |

`Ctrl+n` is reserved for Neo-tree, so multiple cursors use custom mappings
instead of the plugin defaults.

## Optional Features

### GitHub Copilot

Copilot is disabled by default to avoid startup work and login requirements.
Enable it in:

```lua
-- lua/config/init.lua
vim.g.copilot_enabled = true
```

Restart Neovim, then run:

```vim
:Copilot setup
```

Use `Alt+\` in Insert mode to accept a suggestion.

### Catppuccin

Catppuccin is declared but is not the default colorscheme:

```vim
:Lazy load catppuccin
:colorscheme catppuccin
```

To keep it enabled, change the colorscheme in the UI integration instead of
running the command after every restart.

### Lazygit and Lazydocker

These terminals are created only when their keymaps are used. Neovim starts
normally without either executable, but `Space+gg` or `Space+ld` will fail
until the corresponding program is installed.

### Python uv

When `uv` is available, the Python terminal prefers `uv run python`. The
following variables are added to `PATH` when they point to existing
directories:

```text
UV_PYTHON_BIN_DIR
UV_TOOL_BIN_DIR
```

## Performance

Enabled optimizations:

- Startup loads only core configuration, the colorscheme, lazy.nvim, Snacks,
  devicons, and Smear Cursor.
- LSP and language plugins load when matching files are opened.
- Blink loads on Insert or command-line entry.
- LazyDev loads only for Lua; SchemaStore loads only for JSON and JSONC.
- Treesitter installs missing parsers in the background after buffer startup.
- nvim-lint loads only for supported filetypes.
- Mason tool installation checks run after startup and no more than once every
  seven days.
- `checktime` runs only after focus returns to Neovim or the buffer changes.
- LSP document highlights are cleared and suspended in Insert mode.
- Cursor line, cursor column, and relative numbers are hidden in Insert mode.
- Smear Cursor remains enabled in Insert mode by explicit user preference.
- `lazyredraw` is not enabled because it can conflict with Noice.
- Dashboard statusline and tabline are hidden and restored automatically.

Snacks marks a buffer as a big file when:

- The file is larger than 1 MB; or
- The average line length exceeds 500 characters, which commonly indicates a
  minified file.

For big files, the configuration disables Treesitter, LSP, completion, and
hlchunk rendering. Relative numbers, cursor line, and cursor column are also
disabled. Basic filetype syntax remains enabled so the file does not become
completely unhighlighted text.

## Maintenance

### Useful Commands

```vim
:Lazy
:Lazy sync
:Lazy profile
:Mason
:MasonToolsInstall
:MasonUpdate
:TSUpdate
:LspInfo
:LspRestart
:ConformInfo
:checkhealth
:checkhealth vim.lsp
:checkhealth nvim-treesitter
```

### Safe Update Process

1. Commit or back up `lazy-lock.json`.
2. Run `:Lazy sync`.
3. Run `:MasonUpdate` and `:TSUpdate`.
4. Open Python, Go, TypeScript, and Java projects and verify LSP behavior.
5. If an update causes a regression, restore `lazy-lock.json` and run
   `:Lazy restore`.

### Startup Profiling

```bash
nvim --startuptime startup.log
```

Inside Neovim:

```vim
:Lazy profile
```

Heavy plugins should load through filetypes, commands, or keymaps instead of
all loading during startup.

## Troubleshooting

### Neovim Works Only After `:source %`

Check the `VIMINIT` environment variable.

Windows PowerShell:

```powershell
Get-ChildItem Env:VIMINIT
```

Linux/macOS:

```bash
printf '%s\n' "$VIMINIT"
```

If it points to an older configuration, remove it from the shell profile. The
repository's `init.vim` is only a compatibility shim that loads `init.lua`;
manual `runtimepath` or `packpath` changes are not required.

### `module 'helper.utils' not found`

Confirm the repository is installed directly in the Neovim configuration
directory:

```vim
:echo stdpath('config')
```

That directory must directly contain `init.lua` and `lua/helper/utils.lua`.
There should not be another nested `nvim-config/` directory between them.

### Treesitter Cannot Find a Compiler

Check:

```vim
:echo executable('zig')
:echo $CC
:checkhealth nvim-treesitter
```

Windows requires Zig and the two wrappers in `bin/`. Linux and macOS require
GCC, Clang, or explicit `CC`/`CXX` variables. After fixing the compiler, run:

```vim
:TSUpdate
```

For parser ABI or `range` errors, uninstall and reinstall the affected parser:

```vim
:TSUninstall <language>
:TSInstall <language>
```

### JDTLS Does Not Start

Check:

```vim
:echo $JAVA_HOME
:echo executable('java')
:LspInfo
:Mason
```

JDK 21 is required by this configuration. Start Neovim from a project root
containing `pom.xml`, `build.gradle`, `mvnw`, `gradlew`, or `.git`.

### Java Tests Do Not Run

Run:

```vim
:Lazy load neotest
:NeotestJava setup
```

Verify that the Maven or Gradle wrapper works outside Neovim. The
`vscode-java-test` `java-test` package is not managed through Mason here;
`neotest-java` and JUnit Console are used to avoid dependency conflicts.

### `gopls` Does Not Start or Update

Check the Go runtime and Mason:

```vim
:echo executable('go')
:LspInfo
:Mason
```

Then run `:MasonUpdate` and restart the server with `:LspRestart`.

### File Search or Grep Returns No Results

Check:

```vim
:echo executable('rg')
:echo executable('fzf')
```

Both Telescope and FzfLua currently use `rg` for files and live grep. Ensure
the command is available in the environment that starts Neovim.

### Linux Clipboard Does Not Work

Run:

```vim
:checkhealth provider
```

Install `wl-clipboard` on Wayland or `xclip`/`xsel` on X11, then restart the
terminal and Neovim.

### Dashboard Is Cropped or Shifted Up

The dashboard automatically hides `laststatus` and `showtabline`. If another
plugin forces them back on, check:

```vim
:set laststatus?
:set showtabline?
:set filetype?
```

The dashboard buffer should use `filetype=snacks_dashboard`; its open and close
events then hide and restore Lualine and Bufferline.

### Smear Cursor Is Too Bright or Distracting

Toggle it temporarily:

```vim
:SmearCursorToggle
```

To change its color or disable Insert-mode animation, edit the
`sphamba/smear-cursor.nvim` options in `lua/plugins/editor.lua`.

## References

- [Neovim installation](https://github.com/neovim/neovim/blob/master/INSTALL.md)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [Mason](https://github.com/mason-org/mason.nvim)
- [Blink completion](https://github.com/Saghen/blink.cmp)
- [Snacks dashboard](https://github.com/folke/snacks.nvim)
- [Smear Cursor](https://github.com/sphamba/smear-cursor.nvim)
- [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)
- [neotest-java](https://github.com/rcasia/neotest-java)
