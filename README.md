# SUNGP Neovim

Cau hinh Neovim theo huong IDE, toi uu cho Python, Go, JavaScript/TypeScript,
Java, C/C++ va Lua. Cau hinh dung `lazy.nvim`, native LSP, Blink completion,
Telescope, FzfLua, Treesitter, DAP va Neotest.

Muc tieu cua repository:

- Mo nhanh: plugin duoc lazy-load theo event, command, keymap hoac filetype.
- Tim nhanh: Telescope cho giao dien day du, FzfLua cho thao tac toc do cao.
- Code day du: LSP, completion, format, lint, debug, test va Git.
- Da he dieu hanh: Windows, Linux va macOS dung chung mot cau hinh.
- De bao tri: plugin spec va phan tich hop duoc tach rieng.

## Muc luc

- [Tinh nang chinh](#tinh-nang-chinh)
- [Yeu cau](#yeu-cau)
- [Cai cong cu theo he dieu hanh](#cai-cong-cu-theo-he-dieu-hanh)
- [Cai cau hinh](#cai-cau-hinh)
- [Khoi dong lan dau](#khoi-dong-lan-dau)
- [Phu thuoc duoc quan ly tu dong](#phu-thuoc-duoc-quan-ly-tu-dong)
- [Ho tro theo ngon ngu](#ho-tro-theo-ngon-ngu)
- [Cau truc cau hinh](#cau-truc-cau-hinh)
- [Cau hinh theo he dieu hanh](#cau-hinh-theo-he-dieu-hanh)
- [Keymap](#keymap)
- [Tinh nang tuy chon](#tinh-nang-tuy-chon)
- [Toi uu hieu nang](#toi-uu-hieu-nang)
- [Bao tri va kiem tra](#bao-tri-va-kiem-tra)
- [Xu ly loi thuong gap](#xu-ly-loi-thuong-gap)

## Tinh nang chinh

| Nhom | Thanh phan |
| --- | --- |
| Quan ly plugin | lazy.nvim va `lazy-lock.json` |
| LSP | Native `vim.lsp`, nvim-lspconfig, Mason |
| Completion | blink.cmp, friendly-snippets, signature help |
| Format | Conform: Ruff, Prettier, Stylua, gofumpt, goimports |
| Lint | nvim-lint, ESLint, Ruff, markdownlint, ShellCheck |
| Tim kiem | Telescope, telescope-fzf-native va FzfLua |
| Dieu huong | Flash, Neo-tree, Bufferline, Treesitter textobjects |
| Chan doan | Trouble, Todo Comments, Lualine |
| Git | Gitsigns, Fugitive, Diffview |
| Debug | nvim-dap, nvim-dap-ui, debugpy, Delve, JS Debug, Java Debug |
| Test | Neotest cho Python, Go, Jest va Java |
| Giao dien | Snacks dashboard, WhichKey, Noice, Notify, Tokyonight |

## Yeu cau

### Bat buoc chung

| Cong cu | Muc dich |
| --- | --- |
| Neovim `>= 0.11` | Dung native LSP API moi |
| Git | Bootstrap lazy.nvim va tai plugin |
| Mang Internet | Chi can khi bootstrap/cap nhat plugin va Mason |
| ripgrep (`rg`) | Live grep, Todo va cac picker |
| fd | Tim file nhanh |
| fzf | Backend tim kiem cho FzfLua |
| make | Build telescope-fzf-native |
| C compiler hoac Zig | Build parser Treesitter va fzf-native |
| unzip, gzip, tar | Giai nen goi cai dat cua Mason |
| curl hoac wget | Tai goi cua Mason |

`Nerd Font` khong bat buoc de Neovim chay, nhung rat nen co. Neu terminal khong
dung Nerd Font, icon trong WhichKey, Neo-tree, Trouble va Lualine co the hien
thanh o vuong.

### Theo ngon ngu

Chi can cai runtime cua ngon ngu ban su dung:

| Ngon ngu | Bat buoc ben ngoai Neovim |
| --- | --- |
| Python | Python 3; `uv` la tuy chon |
| Go | Go toolchain |
| JavaScript/TypeScript | Node.js va npm |
| Java | JDK 21; Maven/Gradle neu project khong kem wrapper |
| C/C++ | Clang/GCC hoac Zig |
| Lua | Khong can runtime rieng de sua cau hinh Neovim |

Mason cai language server, formatter, linter va debug adapter. Mason khong thay
the runtime/compiler cua du an. Vi du: Mason co the cai `gopls`, nhung van can
Go toolchain de build va test project Go.

### Tuy chon

| Cong cu | Khi nao can |
| --- | --- |
| PowerShell 7 (`pwsh`) | Terminal tot hon tren Windows |
| uv | Quan ly Python env va chay Python REPL |
| Maven | Project Java khong co `mvnw` |
| Gradle | Project Java khong co `gradlew` |
| Lazygit | Dung `Space+gg` |
| Lazydocker va Docker | Dung `Space+ld` |
| GitHub Copilot | Goi y AI trong Insert mode |
| xclip/xsel/wl-clipboard | System clipboard tren Linux |

## Cai cong cu theo he dieu hanh

### Windows 10/11

Cau hinh duoc toi uu cho [Scoop](https://github.com/ScoopInstaller/Install).
Mo PowerShell thuong, khong can Administrator:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

scoop bucket add java
scoop install git neovim ripgrep fd fzf make zig nodejs python go maven unzip gzip
scoop install java/temurin21-jdk
```

Nen cai them PowerShell 7:

```powershell
scoop install pwsh
```

Kiem tra:

```powershell
nvim --version
git --version
rg --version
fd --version
fzf --version
zig version
node --version
python --version
go version
java -version
mvn --version
```

Neu Neovim da duoc cai bang Scoop, cau hinh tu dong nhan:

- `%USERPROFILE%\scoop\apps\go\current\bin`
- `%USERPROFILE%\scoop\apps\maven\current\bin`
- `%USERPROFILE%\scoop\apps\temurin21-jdk\current`

Bien `JAVA_HOME` chi duoc gan tu dong khi chua co gia tri. Neu ban da dat
`JAVA_HOME`, cau hinh ton trong gia tri hien co.

### Ubuntu/Debian

```bash
sudo apt update
sudo apt install git ripgrep fd-find fzf make gcc g++ \
  nodejs npm python3 python3-venv python3-pip golang-go \
  openjdk-21-jdk maven unzip gzip curl
```

Mot so phien ban Debian/Ubuntu dat executable la `fdfind`:

```bash
mkdir -p ~/.local/bin
ln -s "$(command -v fdfind)" ~/.local/bin/fd
```

Dam bao `~/.local/bin` nam trong `PATH`. Goi Neovim cua distro cu co the thap
hon `0.11`; khi do cai ban moi theo
[huong dan chinh thuc cua Neovim](https://github.com/neovim/neovim/blob/master/INSTALL.md).

Clipboard tuy chon:

```bash
# Wayland
sudo apt install wl-clipboard

# X11
sudo apt install xclip
```

Neu distro khong co `openjdk-21-jdk`, cai mot JDK 21 khac va dat:

```bash
export JAVA_HOME=/duong/dan/toi/jdk-21
export PATH="$JAVA_HOME/bin:$PATH"
```

### macOS

Cai Xcode Command Line Tools va Homebrew packages:

```bash
xcode-select --install
brew install neovim git ripgrep fd fzf zig node python go openjdk@21 maven
```

Them JDK 21 vao shell profile:

```bash
export JAVA_HOME="$(brew --prefix openjdk@21)/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
```

macOS da co `pbcopy`/`pbpaste`, nen clipboard khong can package rieng.

## Cai cau hinh

### 1. Sao luu cau hinh cu

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

### 2. Clone repository

Windows PowerShell:

```powershell
git clone https://github.com/sung2708/nvim-config.git "$env:LOCALAPPDATA\nvim"
```

Linux/macOS:

```bash
git clone https://github.com/sung2708/nvim-config.git \
  "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
```

### 3. Mo Neovim

```bash
nvim README.md
```

`lazy.nvim` se tu bootstrap vao thu muc data cua Neovim. Vi plugin duoc
lazy-load, man hinh dau tien co the xuat hien truoc khi tat ca cong cu Mason
duoc cai xong. Mo `README.md` kich hoat Treesitter va cong cu Markdown; cac
lenh trong buoc tiep theo se tu lazy-load Mason, DAP va Neotest khi can.

## Khoi dong lan dau

Chay lan luot trong Neovim:

```vim
:Lazy sync
:MasonToolsInstall
:TSUpdate
:Lazy load nvim-dap
:Lazy load neotest
:NeotestJava setup
:checkhealth
```

Giai thich:

1. `Lazy sync` cai/cap nhat plugin theo `lazy-lock.json`.
2. `MasonToolsInstall` cai LSP, formatter, linter va Java/JS debug adapter.
3. `TSUpdate` cai/cap nhat Treesitter parsers.
4. Load `nvim-dap` de Mason cai debugpy, Delve va codelldb.
5. `NeotestJava setup` tai JUnit Console cho Java test.
6. `checkhealth` kiem tra provider, executable va plugin.

Co the bootstrap plugin khong can giao dien:

```bash
nvim --headless "+Lazy! sync" +qa
```

Sau khi cai xong, mo mot file cua tung ngon ngu can dung. LSP va cac plugin
filetype se chi khoi dong khi co buffer phu hop.

## Phu thuoc duoc quan ly tu dong

### lazy.nvim

`lazy.nvim` quan ly toan bo plugin. Phien ban da kiem thu duoc khoa trong
`lazy-lock.json`; khong nen xoa lockfile neu muon cac may dung cung phien ban.

Plugin duoc chia theo vai tro:

| File | Nhom plugin |
| --- | --- |
| `lua/plugins/lsp.lua` | LSP, Mason, format va lint |
| `lua/plugins/completion.lua` | Completion, snippet, signature |
| `lua/plugins/treesitter.lua` | Parser va textobjects |
| `lua/plugins/search.lua` | Telescope va FzfLua |
| `lua/plugins/ui.lua` | Dashboard, statusline, notify, WhichKey |
| `lua/plugins/git.lua` | Gitsigns, Fugitive, Diffview |
| `lua/plugins/editor.lua` | Explorer, Trouble, Flash, Todo, editing |
| `lua/plugins/debug.lua` | DAP, Neotest va cac adapter |
| `lua/plugins/languages.lua` | Python, Go, TypeScript va Java |

### Mason

LSP duoc cai va enable tu dong:

```text
clangd  cssls  eslint  gopls  html  jsonls
lua_ls  pyright  ruff  vimls
```

Tool duoc `mason-tool-installer` quan ly:

```text
clang-format           eslint_d             gomodifytags
gofumpt                goimports            google-java-format
gotests                iferr                impl
java-debug-adapter     jdtls                js-debug-adapter
markdownlint-cli2      prettier             ruff
shellcheck             stylua              typescript-language-server
```

DAP duoc Mason quan ly:

```text
debugpy  delve  codelldb
```

Khong can cai nhung package tren toan he thong tru khi ban muon dung chung ben
ngoai Neovim.

### Treesitter

Parser tu dong:

```text
bash  c  cpp  css  go  gomod  gosum  html  javascript  java
json  lua  markdown  markdown_inline  python  query  toml
tsx  typescript  vim  vimdoc  yaml
```

Tren Windows, `bin/zig-cc.cmd` va `bin/zig-cxx.cmd` giup Treesitter goi Zig nhu
C/C++ compiler. Hai file `.cmd` chi danh cho Windows; Linux/macOS tu tim
`cc`, `clang`, `gcc`, `c++`, `clang++` hoac `g++`.

## Ho tro theo ngon ngu

### Python

| Vai tro | Cong cu |
| --- | --- |
| LSP/type | Pyright |
| Lint/quick fix | Ruff LSP |
| Format/import | Ruff |
| Virtual environment | venv-selector.nvim |
| Debug | debugpy |
| Test | neotest-python |

Python interpreter cho terminal duoc chon theo thu tu:

1. `uv run python`
2. `python3`
3. `python`

### Go

| Vai tro | Cong cu |
| --- | --- |
| LSP | gopls |
| Format/import | gofumpt, goimports |
| Code generation | gopher.nvim, gomodifytags, gotests, impl, iferr |
| Debug | Delve |
| Test | neotest-golang |

Tren Windows x86_64, cau hinh dat `GOARCH=amd64` neu bien nay chua ton tai.

### JavaScript/TypeScript

| Vai tro | Cong cu |
| --- | --- |
| LSP | typescript-tools.nvim |
| Diagnostics | ESLint |
| Format | eslint_d, Prettier |
| Debug | js-debug-adapter |
| Test | neotest-jest |
| JSX/TSX tag | nvim-ts-autotag |

`typescript-tools.nvim` quan ly TypeScript server truc tiep, nen `ts_ls` khong
duoc enable lan thu hai.

### Java

| Vai tro | Cong cu |
| --- | --- |
| LSP | nvim-jdtls + Eclipse JDTLS |
| Annotation | Lombok |
| Format | google-java-format |
| Debug | java-debug-adapter |
| Test | neotest-java + JUnit Console |

JDTLS can JDK 21 trong cau hinh nay. Project nen co mot trong cac file root:
`.git`, `mvnw`, `pom.xml`, `gradlew`, `build.gradle` hoac `settings.gradle`.

Lan dau mo project Java, JDTLS co the can them thoi gian de index va tai source.
`neotest-java` can chay `:NeotestJava setup` mot lan tren moi thu muc data
Neovim moi.

### Indent theo filetype

| Filetype | Thiet lap |
| --- | --- |
| Python, Lua, Java | 4 spaces |
| JavaScript, TypeScript, JSX, TSX | 2 spaces |
| Go | Tab, do rong hien thi 4 |
| Markdown | Bat wrap va linebreak |

## Cau truc cau hinh

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

Vai tro:

- `init.lua`: entrypoint chinh.
- `init.vim`: shim tuong thich neu bien `VIMINIT` cu van tro vao `init.vim`.
- `lua/config/`: option, keymap chung, autocmd va lazy bootstrap.
- `lua/plugins/`: khai bao plugin, dependency va dieu kien lazy-load.
- `lua/integrations/`: setup va ket noi giua cac plugin.
- `after/ftplugin/`: thiet lap rieng cho tung filetype.
- `lazy-lock.json`: khoa commit cua plugin.

Khong can them thu cong `runtimepath` hoac `packpath`. `init.lua` da nam dung
trong `stdpath("config")`, va lazy.nvim tu quan ly runtimepath cua plugin.

## Cau hinh theo he dieu hanh

### PATH va bien moi truong

`lua/config/options.lua`:

- Dung `;` de tach `PATH` tren Windows, `:` tren Linux/macOS.
- Them `UV_PYTHON_BIN_DIR` va `UV_TOOL_BIN_DIR` neu thu muc ton tai.
- Tu nhan Go, Maven va Temurin 21 trong Scoop tren Windows.
- Chi dat `JAVA_HOME` neu nguoi dung chua dat.
- Chi dat `GOARCH=amd64` tren Windows x86_64 khi `GOARCH` chua ton tai.

Co the dat bien truoc khi mo Neovim:

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

- Windows: `clipboard=unnamed`.
- Linux/macOS: `clipboard=unnamedplus`.

Kiem tra provider bang:

```vim
:checkhealth provider
```

### Shell va terminal

- Windows: uu tien `pwsh`, fallback ve Windows PowerShell.
- Windows terminal duoc dat UTF-8 de tranh loi parse output va ky tu.
- Linux/macOS: giu shell ma Neovim nhan tu moi truong.

### Compiler Treesitter

- Windows: uu tien wrapper Zig trong `bin/`.
- Linux/macOS: ton trong `CC`/`CXX`; neu chua co thi tu tim compiler he thong.

## Keymap

`Leader` la `Space`. `LocalLeader` la `\`.

Nhan `Space` va doi mot chut de mo WhichKey. Tat ca nhom chinh co mo ta va icon.

### Nen tang

| Phim | Che do | Chuc nang |
| --- | --- | --- |
| `Alt+h/j/k/l` | Normal/Terminal | Chuyen cua so |
| `Ctrl+Arrow` | Normal | Doi kich thuoc cua so |
| `Space+j/k` | Normal/Visual | Di chuyen dong hoac vung chon |
| `<` / `>` | Visual | Indent va giu nguyen vung chon |
| `Ctrl+d/u` | Normal | Cuon nua trang va can giua |
| `n` / `N` | Normal | Ket qua tim tiep/tru va can giua |
| `Esc` | Normal | Xoa highlight tim kiem |
| `Tab` / `Shift+Tab` | Normal | Buffer tiep/tru |
| `Space+bc` | Normal | Dong buffer, giu bo cuc cua so |
| `Space+bp` | Normal | Ghim/bo ghim buffer |
| `Space+be/bq` | Normal | Di buffer sang phai/trai |

### Explorer va dashboard

| Phim | Chuc nang |
| --- | --- |
| `Ctrl+n` | Neo-tree reveal file hien tai |
| `Ctrl+t` | Bat/tat Neo-tree |
| `Ctrl+f` | Focus Neo-tree |
| `Space+sd` | Mo dashboard SUNGP |

Tai dashboard:

| Phim | Chuc nang |
| --- | --- |
| `f` | Tim file |
| `g` | Live grep |
| `b` | Danh sach buffer |
| `e` | File explorer |
| `s` | Git status |
| `d` | Git diff |
| `x` | Diagnostics |
| `t` | Tests |
| `c` | Mo thu muc cau hinh |
| `n` | File moi |
| `q` | Thoat Neovim |

### Tim kiem

| Phim | Chuc nang |
| --- | --- |
| `Space+ff` | Tim file bang Telescope |
| `Space+fg` | Tim noi dung bang Telescope |
| `Space+fb` | Tim buffer bang Telescope |
| `Space+fh` | Tim help tag |
| `Space+fe` | Telescope file browser |
| `Space+fF` | Tim file nhanh bang FzfLua |
| `Space+fG` | Tim noi dung nhanh bang FzfLua |
| `Space+fB` | Tim buffer nhanh bang FzfLua |

Quy uoc: `f` chu thuong dung Telescope; bien the chu hoa dung FzfLua.

Trong cua so FzfLua:

| Phim | Chuc nang |
| --- | --- |
| `Ctrl+d/u` | Cuon preview xuong/len |
| `Ctrl+q` | Chon tat ca va chap nhan |

### Flash va Treesitter

| Phim | Che do | Chuc nang |
| --- | --- | --- |
| `s` | Normal/Visual/Operator | Flash jump |
| `S` | Normal/Visual/Operator | Flash Treesitter |
| `am` / `im` | Visual/Operator | Function around/inside |
| `ac` / `ic` | Visual/Operator | Class around/inside |
| `as` | Visual/Operator | Scope around |
| `Space+a/A` | Normal | Doi parameter tiep/tru |
| `]m` / `[m` | Normal/Visual/Operator | Function start tiep/tru |
| `]M` / `[M` | Normal/Visual/Operator | Function end tiep/tru |
| `]]` / `[[` | Normal/Visual/Operator | Class start tiep/tru |
| `][` / `[]` | Normal/Visual/Operator | Class end tiep/tru |
| `]o` | Normal/Visual/Operator | Loop tiep theo |
| `]s` | Normal/Visual/Operator | Scope tiep theo |
| `]z` | Normal/Visual/Operator | Fold tiep theo |
| `]C` / `[C` | Normal/Visual/Operator | Conditional tiep/tru |

### LSP

Keymap LSP chi ton tai trong buffer da attach language server:

| Phim | Chuc nang |
| --- | --- |
| `gd` | Definition qua Telescope |
| `gy` | Type definition qua Telescope |
| `gi` | Implementation qua Telescope |
| `gr` | References qua FzfLua |
| `gO` | Document symbols qua FzfLua |
| `Space+cS` | Workspace symbols |
| `K` / `Space+e` | Hover documentation |
| `Space+ca` | Code action |
| `Space+rn` | Rename symbol |
| `Space+cd` | Diagnostic tai dong |
| `]d` / `[d` | Diagnostic tiep/tru |
| `Space+ci` | Bat/tat inlay hints neu server ho tro |
| `Space+cf` | Format buffer hoac vung chon |
| `Space+cL` | Chay lint |
| `Space+cm` | Mo Mason |
| `Space+cs` | Trouble document symbols |
| `Space+cl` | Trouble LSP list |

Diagnostics khong cap nhat khi dang Insert mode, giup go chu on dinh hon.

### Completion trong Insert mode

| Phim | Chuc nang |
| --- | --- |
| `Ctrl+Space` | Mo completion hoac xem documentation |
| `Ctrl+e` | Dong completion |
| `Ctrl+n/p` | Muc tiep/tru |
| `Ctrl+j/k` | Muc tiep/tru hoac snippet jump |
| `Tab` / `Shift+Tab` | Completion/snippet tiep/tru |
| `Enter` | Chap nhan completion |
| `Ctrl+b/f` | Cuon documentation |
| `Ctrl+l` | Signature help |

### Completion trong command line

Khi nhan `:`, Blink tu hien goi y command. Tim kiem bang `/` hoac `?` van
khong tu mo menu, nhung co the goi completion thu cong.

| Phim | Chuc nang |
| --- | --- |
| `Tab` | Hien menu/chen muc dau, sau do chuyen muc tiep |
| `Shift+Tab` | Chuyen ve muc truoc |
| `Ctrl+Space` | Hien completion thu cong |
| `Ctrl+n/p` | Muc tiep/tru |
| `Ctrl+y` | Chap nhan muc hien tai |
| `Ctrl+e` | Huy completion |

### Format va lint

| Lenh/phim | Chuc nang |
| --- | --- |
| `Space+cf` | Format ngay |
| `Space+cL` | Lint ngay |
| `:FormatDisable` | Tat format-on-save toan cuc |
| `:FormatDisable!` | Tat format-on-save buffer hien tai |
| `:FormatEnable` | Bat lai format-on-save |
| `:ConformInfo` | Xem formatter dang dung |

### Todo va Trouble

| Phim | Chuc nang |
| --- | --- |
| `Space+xx` | Diagnostics toan workspace |
| `Space+xX` | Diagnostics buffer hien tai |
| `Space+xL` | Location list |
| `Space+xQ` | Quickfix list |
| `]t` / `[t` | Todo tiep/tru |
| `Space+xt` | Tat ca Todo trong Trouble |
| `Space+xT` | Tat ca Todo trong Telescope |
| `Space+xf` | Tat ca Todo trong FzfLua |
| `Space+xF` | Chi TODO/FIX/FIXME trong FzfLua |
| `Space+xR` | Chi TODO/FIX/FIXME trong Trouble |
| `Space+xq/xl` | Todo trong quickfix/location list |

Tag duoc nhan: `TODO:`, `FIX:`, `FIXME:`, `HACK:`, `WARN:`, `PERF:` va
`NOTE:`.

### Git

| Phim | Chuc nang |
| --- | --- |
| `Space+gs` | Git status |
| `Space+gc` | Git commit |
| `Space+gp` | Git push |
| `Space+gl` | Git pull |
| `Space+gd` | Mo Diffview |
| `Space+gD` | Dong Diffview |
| `Space+gh` | Git file history |
| `]c` / `[c` | Hunk tiep/tru |
| `Space+hs/hr` | Stage/reset hunk |
| `Space+hS/hR` | Stage/reset buffer |
| `Space+hp/hi` | Preview hunk/popup inline |
| `Space+hb` | Blame dong hien tai |
| `Space+hd/hD` | Diff voi index/commit truoc |
| `Space+hq/hQ` | Hunk vao quickfix buffer/toan bo |
| `Space+tb/tw/tl/tn` | Toggle blame/word diff/line/number highlight |
| `ih` | Chon hunk trong Visual/Operator mode |

### Debug

| Phim | Chuc nang |
| --- | --- |
| `F5` | Continue/start |
| `F10` | Step over |
| `F11` | Step into |
| `F12` | Step out |
| `Space+db` | Toggle breakpoint |
| `Space+dB` | Dat conditional breakpoint |
| `Space+dr` | Mo debug REPL |
| `Space+dl` | Chay lai lan debug gan nhat |
| `Space+du` | Bat/tat DAP UI |

### Test

| Phim | Chuc nang |
| --- | --- |
| `Space+nt` | Chay test gan con tro |
| `Space+nf` | Chay test trong file |
| `Space+nT` | Chay toan bo test suite |
| `Space+ns` | Bat/tat test summary |
| `Space+no` | Xem output test |
| `Space+nO` | Bat/tat output panel |
| `Space+nw` | Bat/tat watch mode |

### Keymap Python

| Phim | Chuc nang |
| --- | --- |
| `Space+pv` | Chon virtual environment bang FzfLua |
| `Space+py` | Mo Python REPL trong terminal |

### Keymap Go

| Phim | Chuc nang |
| --- | --- |
| `Space+Gi` | Them `if err != nil` |
| `Space+Gt` | Them JSON struct tags |
| `Space+GT` | Xoa struct tags |
| `Space+Gc` | Tao comment cho symbol |
| `Space+Gf` | Tao test cho function |
| `Space+GF` | Tao test cho toan file |

### Keymap JavaScript/TypeScript

| Phim | Chuc nang |
| --- | --- |
| `Space+Ti` | Sap xep imports |
| `Space+Ta` | Them imports con thieu |
| `Space+Tu` | Xoa code/import khong dung |
| `Space+Tf` | Sua tat ca loi co the |
| `Space+Tr` | Doi ten file va cap nhat imports |

### Keymap Java

| Phim | Che do | Chuc nang |
| --- | --- | --- |
| `Space+Jo` | Normal | Sap xep imports |
| `Space+Jv` | Normal/Visual | Extract variable |
| `Space+Jc` | Normal/Visual | Extract constant |
| `Space+Jm` | Visual | Extract method |
| `Space+Jt` | Normal | Chay test gan nhat |
| `Space+JT` | Normal | Chay tat ca test trong file |
| `Space+Ju` | Normal | Cap nhat cau hinh Maven/Gradle |

### Terminal

| Phim | Che do | Chuc nang |
| --- | --- | --- |
| `Ctrl+\` | Normal/Terminal | Bat/tat terminal |
| `Space+th` | Normal | Terminal ngang |
| `Space+tv` | Normal | Terminal doc |
| `Space+tf` | Normal | Terminal float |
| `Space+py` | Normal | Python REPL |
| `Space+gg` | Normal | Lazygit, can cai them |
| `Space+ld` | Normal | Lazydocker, can cai them |
| `Space+s` | Visual | Gui vung chon sang terminal |
| `Esc` hoac `jk` | Terminal | Ve Normal mode |
| `Ctrl+h/j/k/l` | Terminal | Chuyen cua so |

Lenh terminal Git:

```vim
:TermGitPush
:TermGitPushF
```

`TermGitPushF` dung force push; chi dung khi ban hieu ro lich su branch.

### Comment, surround va multiple cursors

| Phim | Chuc nang |
| --- | --- |
| `gcc` | Comment/uncomment dong |
| `gc{motion}` | Comment theo motion |
| `gc` | Comment vung chon trong Visual mode |
| `ys{motion}{char}` | Them surround |
| `ds{char}` | Xoa surround |
| `cs{old}{new}` | Doi surround |
| `S{char}` | Surround vung chon |
| `Alt+n` | Bat dau/chon con tro cung tu tiep theo |
| `Alt+a` | Chon tat ca cac tu giong nhau |
| `g Alt+n` | Bat dau multiple cursors, khong gioi han bien tu |
| `g Alt+a` | Chon tat ca, khong gioi han bien tu |
| `Alt+p` | Multiple cursor truoc |
| `Alt+x` | Bo qua occurrence hien tai |
| `Esc` | Thoat multiple cursors |

`Ctrl+n` duoc giu rieng cho Neo-tree, vi vay multiple cursors khong dung
keymap mac dinh cua plugin.

## Tinh nang tuy chon

### GitHub Copilot

Copilot mac dinh tat de khong tang startup va khong yeu cau dang nhap. Sua:

```lua
-- lua/config/init.lua
vim.g.copilot_enabled = true
```

Khoi dong lai Neovim, sau do:

```vim
:Copilot setup
```

Trong Insert mode, dung `Alt+\` de chap nhan goi y.

### Catppuccin

Catppuccin duoc khai bao nhung khong phai colorscheme mac dinh:

```vim
:Lazy load catppuccin
:colorscheme catppuccin
```

Muon dung lau dai, doi colorscheme trong file UI integration thay vi goi lenh
moi lan khoi dong.

### Lazygit va Lazydocker

Hai terminal nay chi duoc tao khi goi keymap. Neovim van khoi dong binh thuong
neu chua cai executable, nhung `Space+gg` hoac `Space+ld` se bao khong tim thay
command.

### Python uv

Neu co `uv`, terminal Python uu tien `uv run python`. Hai bien sau duoc them
vao `PATH` neu tro den thu muc ton tai:

```text
UV_PYTHON_BIN_DIR
UV_TOOL_BIN_DIR
```

## Toi uu hieu nang

Cac toi uu duoc bat san:

- Dashboard chi load colorscheme, lazy.nvim, Snacks va devicons.
- LSP/Blink/Mason LSP chi load voi filetype co server duoc cau hinh.
- LazyDev chi load cho Lua; SchemaStore chi load cho JSON/JSONC.
- Treesitter chi cai parser con thieu, chay nen sau khi buffer da mo.
- nvim-lint chi tu load cho Markdown va shell.
- Mason tool installer chay sau startup va chi kiem tra tu dong moi 7 ngay.
- `checktime` chi chay khi focus lai Neovim hoac chuyen buffer.
- Document highlight LSP khong gui request trong Insert mode.
- Cursor line, cursor column va relative number tat trong Insert mode.
- `lazyredraw` khong duoc bat vi co the xung dot voi Noice.

Snacks danh dau big file khi:

- File lon hon 1 MB; hoac
- Do dai dong trung binh lon hon 500 ky tu, thuong la file minified.

Voi big file, cau hinh tat Treesitter, LSP, completion va render cua hlchunk;
relative number, cursor line va cursor column cung duoc tat. Syntax co ban van
duoc giu theo filetype goc de file khong tro thanh van ban hoan toan khong mau.

## Bao tri va kiem tra

### Lenh quan trong

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

### Cap nhat an toan

1. Commit hoac sao luu `lazy-lock.json`.
2. Chay `:Lazy sync`.
3. Chay `:MasonUpdate` va `:TSUpdate`.
4. Mo project Python, Go, TypeScript va Java de kiem tra LSP.
5. Neu plugin moi gay loi, phuc hoi `lazy-lock.json` roi `:Lazy restore`.

### Kiem tra startup

```bash
nvim --startuptime startup.log
```

Trong Neovim:

```vim
:Lazy profile
```

Plugin nang duoc load theo filetype/command/keymap thay vi load het luc startup.

## Xu ly loi thuong gap

### Neovim bat mo lai bang `:source %`

Kiem tra bien `VIMINIT`.

Windows PowerShell:

```powershell
Get-ChildItem Env:VIMINIT
```

Linux/macOS:

```bash
printf '%s\n' "$VIMINIT"
```

Neu no tro vao config cu, xoa bien do khoi shell profile. `init.vim` trong
repository nay chi la shim goi `init.lua`; khong can tu them `runtimepath`.

### `module 'helper.utils' not found`

Dam bao repository nam dung thu muc config:

```vim
:echo stdpath('config')
```

Thu muc do phai chua truc tiep `init.lua` va `lua/helper/utils.lua`, khong phai
them mot cap `nvim-config/` o ben trong.

### Treesitter bao khong co compiler

Kiem tra:

```vim
:echo executable('zig')
:echo $CC
:checkhealth nvim-treesitter
```

Windows can Zig va hai wrapper trong `bin/`. Linux/macOS can GCC/Clang, hoac
dat `CC`/`CXX` truoc khi mo Neovim. Sau khi sua:

```vim
:TSUpdate
```

Neu van gap loi parser ABI/range, xoa parser loi trong thu muc data hoac chay
`:TSUninstall <language>` roi `:TSInstall <language>`.

### JDTLS khong khoi dong

Kiem tra:

```vim
:echo $JAVA_HOME
:echo executable('java')
:LspInfo
:Mason
```

JDK phai la ban 21. Mo Neovim tai root project co `pom.xml`, `build.gradle`,
`mvnw`, `gradlew` hoac `.git`.

### Java test khong chay

Chay:

```vim
:Lazy load neotest
:NeotestJava setup
```

Dam bao Maven/Gradle wrapper chay duoc ben ngoai Neovim. `java-test` cua
vscode-java-test khong duoc Mason quan ly trong cau hinh nay; Java test dung
`neotest-java` va JUnit Console de tranh xung dot dependency.

### `gopls` khong cap nhat hoac khong khoi dong

Kiem tra Go runtime va Mason:

```vim
:echo executable('go')
:LspInfo
:Mason
```

Sau do chay `:MasonUpdate` va khoi dong lai LSP bang `:LspRestart`.

### Tim file/grep khong co ket qua

Kiem tra:

```vim
:echo executable('rg')
:echo executable('fd')
:echo executable('fzf')
```

Telescope live grep can `rg`; FzfLua files can `fd` hoac backend tuong duong.

### Clipboard Linux khong hoat dong

Chay:

```vim
:checkhealth provider
```

Cai `wl-clipboard` tren Wayland hoac `xclip`/`xsel` tren X11, sau do khoi dong
lai terminal va Neovim.

## Tai lieu tham khao

- [Neovim installation](https://github.com/neovim/neovim/blob/master/INSTALL.md)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [Mason](https://github.com/mason-org/mason.nvim)
- [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)
- [neotest-java](https://github.com/rcasia/neotest-java)
