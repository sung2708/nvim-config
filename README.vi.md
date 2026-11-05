# sungp Neovim

Ngôn ngữ: [English](README.md) | [Tiếng Việt](README.vi.md)

Một cấu hình Neovim theo hướng IDE cho Python, Go, JavaScript/TypeScript,
Java, C/C++, Lua và Markdown. Cấu hình dùng `lazy.nvim`, native LSP, Blink
completion, FzfLua, Treesitter, DAP, Neotest và dashboard gọn của Snacks.

Cấu hình này tập trung vào năm mục tiêu:

- Khởi động nhanh nhờ lazy-load theo sự kiện, lệnh, phím tắt và filetype.
- Điều hướng nhanh qua một hệ picker FzfLua duy nhất.
- Hỗ trợ lập trình đầy đủ: LSP, completion, format, lint, test, debug và Git.
- Một cấu hình dùng được trên Windows, Linux và macOS.
- Phân chia rõ trách nhiệm giữa file khai báo plugin và file tích hợp chi tiết.

## Cài bằng một lệnh

Chạy **đúng một dòng cho hệ điều hành của bạn**, bằng tài khoản thường.
Bộ cài dùng Homebrew trên macOS/Linux và Scoop trên Windows. Linux cần tài
khoản có quyền sudo; macOS có thể hỏi quyền cài Command Line Tools/Homebrew.
Windows dùng cửa sổ **PowerShell 64-bit thông thường**; Visual C++ runtime có
thể hiện hộp thoại UAC. Cần Internet, vài phút đến lâu hơn tùy mạng/máy và
vài GB dung lượng trống.

### macOS

```bash
bash -c 'p=$(mktemp) && curl --fail --location --retry 3 https://raw.githubusercontent.com/sung2708/nvim-config/main/bin/install.sh -o "$p" && bash "$p"; s=$?; rm -f "$p"; exit "$s"'
```

### Ubuntu / Debian / WSL2

```bash
sudo apt-get update && sudo apt-get install -y curl && bash -c 'p=$(mktemp) && curl --fail --location --retry 3 https://raw.githubusercontent.com/sung2708/nvim-config/main/bin/install.sh -o "$p" && bash "$p"; s=$?; rm -f "$p"; exit "$s"'
```

### Fedora

```bash
sudo dnf install -y curl && bash -c 'p=$(mktemp) && curl --fail --location --retry 3 https://raw.githubusercontent.com/sung2708/nvim-config/main/bin/install.sh -o "$p" && bash "$p"; s=$?; rm -f "$p"; exit "$s"'
```

### Arch Linux

```bash
sudo pacman -Syu --needed --noconfirm curl && bash -c 'p=$(mktemp) && curl --fail --location --retry 3 https://raw.githubusercontent.com/sung2708/nvim-config/main/bin/install.sh -o "$p" && bash "$p"; s=$?; rm -f "$p"; exit "$s"'
```

### Windows 10/11 x64 — PowerShell

```powershell
& { $ErrorActionPreference = 'Stop'; Set-ExecutionPolicy Bypass -Scope Process -Force; $p = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName() + '.ps1'); Invoke-WebRequest 'https://raw.githubusercontent.com/sung2708/nvim-config/main/bin/install.ps1' -UseBasicParsing -OutFile $p; try { & $p } finally { Remove-Item $p } }
```

Sau đó mở **terminal mới** và chạy `nvim .`. Bộ cài cấu hình PATH cho Bash/Zsh
trên macOS/Linux. Shell khác cần làm theo
[hướng dẫn Homebrew](https://docs.brew.sh/Installation#installation).
Chọn Nerd Font trong terminal để icon hiển thị đúng.
Lệnh Arch cập nhật toàn hệ thống để tránh nâng cấp package không đồng bộ.

Nếu đang có cấu hình khác, bộ cài sao lưu thành `nvim.backup-<thời gian>` và
giữ dữ liệu Neovim. Nếu đã cài đúng repository này, bộ cài dùng lại checkout,
không tự pull đè thay đổi của bạn. Chạy lại cùng lệnh để tiếp tục khi mạng/cài
đặt bị gián đoạn; tool Mason đã cài sẽ được giữ nguyên.

Xem [chi tiết cài đặt](#cài-công-cụ-hệ-thống) để biết phạm vi được cài tự động.

## Quy trình IDE hằng ngày

Phím leader là `Space`. Mở từ thư mục dự án bằng `nvim .`.

| Công việc | Phím / lệnh |
| --- | --- |
| Tìm file / tìm trong dự án | `Space ff` / `Space fg` |
| Định nghĩa / tham chiếu / đổi tên | `gd` / `grr` / `Space rn` |
| Gợi ý / chấp nhận / chữ ký hàm | `Ctrl-Space` / `Tab` / `Ctrl-l` trong Insert |
| Code action / format | `Space ca` / `Space cf` |
| Lỗi toàn dự án | `Space xx` |
| Test gần nhất / cả file | `Space nt` / `Space nf` |
| Breakpoint / debug | `Space db` / `F5` |
| Kiểm tra môi trường | `:ConfigHealth`, `:LspInfo`, `:ConformInfo` |

Đã bật Python, Go, TypeScript/React, C/C++, Java, Lua, HTML/CSS, JSON và
Vimscript theo filetype. Java do nvim-jdtls quản lý riêng để tránh hai server;
Lua dùng LazyDev cho kiểu dữ liệu Neovim. Conform quản lý format khi lưu;
ESLint LSP/Ruff báo lỗi ngôn ngữ, nvim-lint kiểm tra Shell/Markdown.
Dùng `:FormatDisable!` để tắt format riêng buffer. Đã bật undo qua lần mở,
swap recovery và `writebackup` bảo vệ file gốc khi ghi thất bại.

Ưu tiên cấu hình trong dự án: `pyproject.toml`, `tsconfig.json`, ESLint,
Prettier, `compile_commands.json`, Maven/Gradle wrapper. Cài thư viện test
trong dự án. Các lệnh AI là tùy chọn.

Bộ cài cung cấp JDK 25 cho jdtls hiện tại và cài sẵn JUnit Console.
JDK của dự án có thể khác; khai báo theo build của dự án. Cấu hình máy riêng
đặt trong `lua/config/local.lua` được Git bỏ qua.

`tests/ide.lua` mở file tạm, chờ LSP thật, kiểm tra formatter ngoài cho tám
ngôn ngữ và ShellCheck sau khi lưu. Cần cài tool và JDK trước khi chạy.

Tham khảo: [LSP native](https://neovim.io/doc/user/lsp/),
[Conform](https://github.com/stevearc/conform.nvim),
[nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls),
[lockfile lazy.nvim](https://lazy.folke.io/usage/lockfile).

## Mục Lục

- [Cài bằng một lệnh](#cài-bằng-một-lệnh)
- [Tính Năng](#tính-năng)
- [Yêu Cầu](#yêu-cầu)
- [Cài Công Cụ Hệ Thống](#cài-công-cụ-hệ-thống)
- [Cài Cấu Hình](#cài-cấu-hình)
- [Lần Chạy Đầu](#lần-chạy-đầu)
- [Phụ Thuộc Được Quản Lý](#phụ-thuộc-được-quản-lý)
- [Hỗ Trợ Ngôn Ngữ](#hỗ-trợ-ngôn-ngữ)
- [Bố Cục Cấu Hình](#bố-cục-cấu-hình)
- [Hành Vi Theo Hệ Điều Hành](#hành-vi-theo-hệ-điều-hành)
- [Giao Diện](#giao-diện)
- [Phím Tắt](#phím-tắt)
- [Tính Năng Tùy Chọn](#tính-năng-tùy-chọn)
- [Hiệu Năng](#hiệu-năng)
- [Bảo Trì](#bảo-trì)
- [Xử Lý Lỗi](#xử-lý-lỗi)

## Tính Năng

| Khu vực        | Thành phần                                                     |
| -------------- | -------------------------------------------------------------- |
| Quản lý plugin | lazy.nvim và `lazy-lock.json`                                  |
| LSP            | Native `vim.lsp`, nvim-lspconfig, Mason                        |
| Completion     | blink.cmp, friendly-snippets, signature help                   |
| Format         | Conform, Ruff, Prettier, Stylua, gofumpt, goimports            |
| Lint           | nvim-lint, ESLint, Ruff, markdownlint, ShellCheck              |
| Tìm kiếm       | FzfLua, Snacks Picker, Grug Far                                |
| Điều hướng     | Flash, Neo-tree, Oil, Bufferline, Treesitter, Mini textobjects |
| Chỉnh sửa      | Dial, IncRename xem trước, Yanky, surround, autopairs          |
| Workflow       | Overseer tasks, Persistence sessions, Yanky history            |
| AI             | CodeCompanion v19 agent chat qua Codex ACP                     |
| Diagnostics    | Trouble, Todo Comments, Lualine                                |
| Git            | Gitsigns, Fugitive, Diffview                                   |
| Debug          | nvim-dap, nvim-dap-ui, debugpy, Delve, JS Debug, Java Debug    |
| Test           | Neotest cho Python, Go, Jest và Java                           |
| UI             | Catppuccin, Snacks dashboard, WhichKey, Noice, Notify          |

## Yêu Cầu

### Yêu Cầu Cốt Lõi

| Công cụ             | Mục đích                                       |
| ------------------- | ---------------------------------------------- |
| Neovim `>= 0.12`    | Native LSP API và nvim-treesitter nhánh `main` |
| Git                 | Bootstrap lazy.nvim và tải plugin              |
| Internet            | Chỉ cần cho lần cài đặt và cập nhật đầu tiên   |
| ripgrep (`rg`)      | Tìm file, live grep, Todo và FzfLua            |
| fzf                 | Backend cho FzfLua                             |
| C compiler hoặc Zig | Build native extension và Treesitter parser    |
| tree-sitter-cli     | Biên dịch/cập nhật Treesitter parser           |
| unzip, gzip, tar    | Giải nén package do Mason cài                  |
| curl                | CodeCompanion và tải package qua Mason         |

`fd` là tùy chọn. FzfLua ưu tiên `fd` khi tìm file và dùng `rg --files`
nếu thiếu `fd`. Live grep dùng `rg`.

Nerd Font không bắt buộc để chạy Neovim, nhưng rất nên cài. Nếu không có,
icon trong WhichKey, Neo-tree, Trouble, Lualine hoặc dashboard có thể hiện
thành ô vuông.

### Runtime Theo Ngôn Ngữ

Chỉ cần cài runtime cho ngôn ngữ bạn dùng:

| Ngôn ngữ              | Yêu cầu ngoài Neovim                                   |
| --------------------- | ------------------------------------------------------ |
| Python                | Python 3; `uv` là tùy chọn                             |
| Go                    | Go toolchain                                           |
| JavaScript/TypeScript | Node.js và npm                                         |
| Java                  | JDK 25 cho jdtls; Maven/Gradle hoặc wrapper của dự án   |
| C/C++                 | Clang, GCC hoặc Zig                                    |
| Lua                   | Không cần runtime riêng để sửa cấu hình Neovim         |

Mason cài language server, formatter, linter và debug adapter. Mason không
thay thế runtime hoặc compiler của project. Ví dụ Mason có thể cài `gopls`,
nhưng bạn vẫn cần Go toolchain để build và test code Go.

## Cài Công Cụ Hệ Thống

[Bộ cài một lệnh](#cài-bằng-một-lệnh) tự cài:

- Neovim stable (kiểm tra `>= 0.12`), Git, curl, ripgrep, fd, fzf, make và công cụ giải nén.
- Node.js LTS, Python 3.13, Go, JDK 25, Maven, bộ biên dịch C/C++ và clang-format.
- Tree-sitter CLI **0.26.11** riêng trong thư mục dữ liệu Neovim, không cài npm toàn cục.
- Python provider riêng với **pynvim 0.6.0**, không dùng pip toàn cục.
- Công cụ clipboard Linux và pngpaste trên macOS.
- Visual C++ runtime, GCC, LLVM và Zig trên Windows.

Linux hỗ trợ distro apt/dnf/pacman, x86_64/ARM64, dùng glibc và đáp ứng yêu cầu
Homebrew. Không hỗ trợ Alpine/musl, hệ 32-bit hoặc WSL1. macOS cần nền tảng còn
được Homebrew hỗ trợ. Windows native hỗ trợ x64; Windows ARM có thể dùng Linux
ARM64 trong WSL2.

Gói hệ thống dùng bản stable và cơ chế kiểm tra toàn vẹn của package manager.
Plugin được khôi phục theo `lazy-lock.json`. Mason cài từ registry hiện tại
**chỉ khi tool còn thiếu**, chưa khóa phiên bản tất cả tool. Phiên bản đã cài
được ghi tại `stdpath("data")/nvim-config/install-report.json`.

## Cài Cấu Hình

Bộ cài clone `sung2708/nvim-config` vào `stdpath("config")`, ghi đường dẫn máy
vào `lua/config/toolchain.lua` đã được Git bỏ qua. File này tải trước
`lua/config/local.lua` để cấu hình cá nhân của bạn được ưu tiên. Không sao chép
file toolchain đã sinh giữa các hệ điều hành.

Với checkout đã có, tự cập nhật repository trước khi chạy bộ cài nếu muốn lấy
cấu hình mới. Bộ cài không commit, reset hoặc pull các thay đổi của bạn; phiên
bản plugin được khôi phục theo lockfile của checkout đang dùng.

Không tự cài CLI AI, Docker, thư viện/test runner của dự án hoặc chọn font
terminal. Dùng pytest/Jest trong dự án và Maven/Gradle wrapper khi có. Provider
Node/Perl/Ruby và tính năng ảnh/PDF Snacks đã tắt nên không cần cài thêm gói.

## Lần Chạy Đầu

Bộ cài chờ hoàn tất từng bước và báo lỗi nếu xác minh thất bại:

1. Cài plugin, khôi phục và kiểm tra từng commit trong lockfile.
2. Làm mới Mason; cài các LSP, formatter, linter và debug adapter đã cấu hình.
3. Build và kiểm tra toàn bộ Treesitter parser đã khai báo.
4. Cài JUnit Console theo phiên bản neotest-java đã khóa, kiểm tra SHA-256.
5. Chỉ ghi báo cáo cài đặt khi các bước bắt buộc đã thành công.

Lần mở đầu không cần chạy tay `Lazy sync`, `MasonToolsInstall` hoặc `TSUpdate`.
Chạy lại có thể cập nhật gói hệ thống/runtime; xem thông báo của package manager.
Bộ cài dừng khi lỗi để bạn sửa và chạy lại.

### Kiểm Tra Sau Cài

Mở `nvim .` từ thư mục dự án và chạy:

```vim
:ConfigHealth
:LspInfo
:ConformInfo
:messages
```

Kiểm tra checkout mà không cài lại công cụ hệ thống:

```bash
nvim --headless -u NONE -i NONE -l tests/ide.lua
```

Bài kiểm tra chạy LSP thật, format, kiểm tra nội dung đã lưu và ShellCheck;
cần tool/runtime đã được cài. Xác minh bộ cài không bảo đảm mọi dự án build
được hoặc các dịch vụ AI đã đăng nhập.

Tài liệu chính thức: [Homebrew](https://docs.brew.sh/Installation),
[Homebrew trên Linux](https://docs.brew.sh/Homebrew-on-Linux),
[Scoop](https://github.com/ScoopInstaller/Install),
[lockfile lazy.nvim](https://lazy.folke.io/usage/lockfile).

## Phụ Thuộc Được Quản Lý

### lazy.nvim

`lazy.nvim` quản lý toàn bộ plugin. Commit đã kiểm thử nằm trong
`lazy-lock.json`; nên đưa lockfile vào version control để dùng cùng phiên bản
trên nhiều máy.

Các file plugin được nhóm theo trách nhiệm:

| File                         | Trách nhiệm                                   |
| ---------------------------- | --------------------------------------------- |
| `lua/plugins/lsp.lua`        | LSP, Mason, format và lint                    |
| `lua/plugins/completion.lua` | Completion, snippet và signature              |
| `lua/plugins/ai.lua`         | CodeCompanion v19 chat qua Codex ACP          |
| `lua/plugins/treesitter.lua` | Parser và textobject                          |
| `lua/plugins/search.lua`     | FzfLua và Grug Far                            |
| `lua/plugins/ui.lua`         | Dashboard, statusline, notification, WhichKey |
| `lua/plugins/git.lua`        | Gitsigns, Fugitive và Diffview                |
| `lua/plugins/editor.lua`     | Explorer, Trouble, Flash, Todo, fold, editing |
| `lua/plugins/debug.lua`      | DAP, Neotest và adapter                       |
| `lua/plugins/languages.lua`  | Python, Go, TypeScript và Java                |
| `lua/plugins/terminal.lua`   | Terminal và Overseer task                     |
| `lua/plugins/sessions.lua`   | Phiên làm việc theo project                   |

### Mason

Language server được cài và bật tự động:

```text
clangd  cssls  eslint  gopls  html  jsonls
lua_ls  pyright  ruff  vimls
```

Công cụ do `mason-tool-installer` quản lý:

```text
clang-format           eslint_d             gomodifytags
gofumpt                goimports            google-java-format
gotests                iferr                impl
java-debug-adapter     jdtls                js-debug-adapter
markdownlint-cli2      prettier             ruff
shellcheck             stylua              typescript-language-server
```

Debug adapter do Mason quản lý:

```text
debugpy  delve  codelldb
```

Các package này không cần cài global nếu bạn chỉ dùng chúng trong Neovim.

### Treesitter

Parser được cài tự động:

```text
bash  c  cpp  css  go  gomod  gosum  gotmpl  gowork  html
javascript  java  json  latex  lua  markdown  markdown_inline
python  query  regex  toml  tsx  typescript  vim  vimdoc  yaml
```

Trên Windows, `bin/zig-cc.cmd` và `bin/zig-cxx.cmd` cho phép dùng Zig như
compiler C/C++ cho Treesitter. Các wrapper `.cmd` này chỉ dành cho Windows.
Linux và macOS dùng `CC`/`CXX` nếu có, rồi fallback sang `cc`, `clang`, `gcc`,
`c++`, `clang++` hoặc `g++`.

## Hỗ Trợ Ngôn Ngữ

### C/C++

| Vai trò  | Công cụ             |
| -------- | ------------------- |
| LSP      | clangd qua Mason    |
| Format   | clang-format        |
| Compiler | GCC, Clang hoặc Zig |

clangd dùng lệnh biên dịch của dự án và toolchain hệ thống. Tạo
`compile_commands.json` bằng build system để dùng đúng compiler, kiến trúc và
header. File lẻ dùng mặc định của clangd; GCC/MinGW tùy chỉnh có thể cần khai
báo include path trong dự án. Xem
[hướng dẫn header của clangd](https://clangd.llvm.org/guides/system-headers).

### Python

| Vai trò             | Công cụ            |
| ------------------- | ------------------ |
| LSP và type         | Pyright            |
| Lint và quick fix   | Ruff LSP           |
| Format và import    | Ruff               |
| Virtual environment | venv-selector.nvim |
| Debug               | debugpy            |
| Test                | neotest-python     |

Python terminal chọn interpreter theo thứ tự:

1. `uv run python`
2. `python3`
3. `python`

### Go

| Vai trò          | Công cụ                                         |
| ---------------- | ----------------------------------------------- |
| LSP              | gopls                                           |
| Format và import | gofumpt, goimports                              |
| Sinh code        | go.nvim, gomodifytags, gotests, impl, iferr     |
| Debug            | Delve                                           |
| Test             | neotest-golang                                  |

### JavaScript/TypeScript

| Vai trò      | Công cụ               |
| ------------ | --------------------- |
| LSP          | ts_ls (typescript-language-server) |
| Diagnostics  | ESLint                |
| Format       | Prettier              |
| Debug        | js-debug-adapter      |
| Test         | neotest-jest          |
| JSX/TSX tags | nvim-ts-autotag       |

`ts_ls` là server TypeScript đang dùng.
Khi LSP đã gắn vào buffer: `Space+Ti` sắp xếp import, `Space+Ta` thêm import thiếu,
`Space+Tu` bỏ code không dùng, `Space+Tf` sửa lỗi mà server hỗ trợ.

### Java

| Vai trò    | Công cụ                       |
| ---------- | ----------------------------- |
| LSP        | nvim-jdtls và Eclipse JDTLS   |
| Annotation | Lombok                        |
| Format     | google-java-format            |
| Debug      | java-debug-adapter            |
| Test       | neotest-java và JUnit Console |

Cấu hình chạy JDTLS với JDK 25. Project nên có ít nhất một root marker:
`.git`, `mvnw`, `pom.xml`, `gradlew`, `build.gradle` hoặc `settings.gradle`.

## Bố Cục Cấu Hình

| Đường dẫn           | Nội dung                               |
| ------------------- | -------------------------------------- |
| `init.lua`          | Điểm vào chính                         |
| `lua/config/`       | Bootstrap, option, keymap và lazy.nvim |
| `lua/plugins/`      | Khai báo plugin theo nhóm              |
| `lua/integrations/` | Cấu hình chi tiết cho plugin           |
| `lua/helper/`       | Hàm dùng chung                         |
| `bin/`              | Wrapper Windows cho Zig C/C++          |
| `lazy-lock.json`    | Phiên bản plugin đã khóa               |

Quy tắc chung: `lua/plugins/*.lua` quyết định plugin load khi nào, còn
`lua/integrations/*.lua` chứa cấu hình chi tiết sau khi plugin đã load.

## Hành Vi Theo Hệ Điều Hành

Windows được ưu tiên hỗ trợ qua Scoop. Cấu hình tự nhận một số đường dẫn Scoop
phổ biến và dùng wrapper `.cmd` khi cần. Linux và macOS dựa nhiều hơn vào
`PATH`, `CC`, `CXX`, `JAVA_HOME` và package manager của hệ thống.

### Cấu hình riêng cho từng máy

Không đưa đường dẫn hoặc sở thích chỉ dùng trên một máy vào cấu hình chung.
Sao chép file mẫu sang `local.lua`, file này đã được Git bỏ qua:

```powershell
Copy-Item .\lua\config\local.example.lua .\lua\config\local.lua
```

Trên Linux/macOS dùng `cp ./lua/config/local.example.lua ./lua/config/local.lua`.

Database và lịch sử plugin dùng `stdpath("data")`, không nằm trong repository.
Nếu một công cụ chạy được trong terminal nhưng không chạy trong Neovim, hãy mở
Neovim từ đúng terminal đó để đảm bảo `PATH` giống nhau.

## Giao Diện

Theme mặc định là Catppuccin Frappe; giao diện còn dùng Lualine, Bufferline, Neo-tree,
Noice, Notify, WhichKey và Snacks dashboard. Dashboard tự ẩn statusline/tabline
khi mở và khôi phục khi rời dashboard. Snacks sở hữu `vim.ui.select`.

Các thông báo diagnostic dùng icon từ Nerd Font. Nếu icon bị lỗi, kiểm tra
font terminal trước khi debug plugin.

Hlchunk bật đường nối khối, đường thụt lề, tô số dòng và dấu chấm trên dòng
trống. Treesitter nhận diện khối; đường dẫn thụt lề theo khoảng trắng thực tế. `viH` chọn khối hiện tại; `Space ui` bật/tắt
đường thụt lề, `Space uc` bật/tắt đường nối khối. Animation vẫn tắt; file lớn
và buffer phụ được loại trừ.

## Phím Tắt

Normal mode: `]b` / `[b` đổi buffer; `Ctrl-i` giữ thao tác nhảy tiến trong
lịch sử vị trí. `Tab` trong Insert vẫn dùng cho completion/snippet.

Leader mặc định là `Space`.

### LSP

LSP mapping chỉ tồn tại sau khi language server attach vào buffer:

| Phím            | Hành động                             |
| --------------- | ------------------------------------- |
| `gd`            | Đi tới definition qua FzfLua          |
| `gy`            | Đi tới type definition qua FzfLua     |
| `gi`            | Đi tới implementation qua FzfLua      |
| `grr`           | Xem references qua FzfLua             |
| `gO`            | Document symbols                      |
| `Space+cS`      | Workspace symbols                     |
| `K` / `Space+e` | Hover documentation                   |
| `Space+ca`      | Code action                           |
| `Space+rn`      | Rename symbol với xem trước trực tiếp |
| `Space+cd`      | Diagnostic của dòng hiện tại          |
| `]d` / `[d`     | Diagnostic kế tiếp/trước đó           |
| `Space+ci`      | Bật/tắt inlay hints nếu server hỗ trợ |
| `Space+cf`      | Format buffer hoặc selection          |
| `Space+cL`      | Chạy lint                             |
| `Space+cm`      | Mở Mason                              |
| `Space+cs`      | Trouble document symbols              |
| `Space+cl`      | Trouble LSP list                      |

Diagnostics không cập nhật khi đang Insert mode để việc gõ ổn định hơn.

### Completion

| Phím                | Hành động                             |
| ------------------- | ------------------------------------- |
| `Ctrl+Space`        | Hiện completion hoặc documentation    |
| `Ctrl+e`            | Ẩn completion                         |
| `Ctrl+n/p`          | Chọn item tiếp theo/trước đó          |
| `Ctrl+j/k`          | Chọn item hoặc nhảy snippet           |
| `Tab` / `Shift+Tab` | Chấp nhận/chọn hoặc nhảy snippet      |
| `Ctrl+y`            | Chấp nhận completion                  |
| `Enter`             | Xuống dòng; fallback theo ngữ cảnh    |
| `Ctrl+b/f`          | Cuộn documentation                    |
| `Ctrl+l`            | Bật/tắt signature help                |

### Công Cụ Thường Dùng

| Phím        | Hành động                       |
| ----------- | ------------------------------- |
| `Space+ff`  | Tìm file trong project          |
| `Space+fg`  | Live grep trong project         |
| `Space+fb`  | Tìm buffer                      |
| `Space+ld`  | Lazydocker, nếu đã cài          |
| `Ctrl+\`    | Bật/tắt terminal                |
| `Space+xx`  | Trouble diagnostics             |
| `Ctrl+a/x`  | Tăng/giảm số, ngày hoặc giá trị |

### Quickfix Với Quicker

Các nguồn này dùng chung một workflow Quickfix: kết quả từ FzfLua (`Ctrl+q`),
Grug Far (`\\q`), comment TODO (`Space+xq`), Git hunk (`Space+hq`/`Space+hQ`)
và diagnostics của LSP (`Space+xD`) đều có thể rà soát bằng `Space+qF`,
`Enter`, `]q`, `[q`. Nhờ vậy chỉ cần nhớ một cách duyệt danh sách giữa các
plugin.

Neotest cũng nối với DAP: `Space+nt`/`Space+nf` chạy test bình thường, còn
`Space+nd`/`Space+nD` chạy test gần con trỏ hoặc cả file dưới debugger. DAP vẫn
được lazy-load và chỉ tải khi dùng luồng debug test này.

Dùng `Space+dc` để chạy tới con trỏ, `Space+dt` để kết thúc debug, và
`Space+nx` để dừng test đang chạy gần con trỏ. Hộp nhập breakpoint điều kiện
dùng giao diện chung; hủy hoặc để trống sẽ không tạo breakpoint.

Quicker cải thiện quickfix chuẩn mà không thay thế Trouble. Dùng `Space+qf`
để bật/tắt quickfix, hoặc `Space+qF` để bật/tắt và đưa focus vào đó. Trong
cửa sổ quickfix, nhấn `>` để mở thêm hai dòng ngữ cảnh quanh kết quả và `<` để
thu gọn. Danh sách giữ tô màu grep, cột file/dòng và icon diagnostics. Có thể
sửa dòng nguồn trực tiếp trong buffer quickfix rồi `:w`; chỉ các buffer nguồn
chưa bị sửa lúc mở danh sách mới được tự ghi. `Space+xQ` vẫn là cây diagnostics
đầy đủ của Trouble.

Quicker yêu cầu Neovim 0.10 trở lên và quản lý `quickfixtextfunc`; tránh thêm
plugin quickfix có khả năng chỉnh sửa trùng như quickfix-reflector hoặc
replacer. Plugin dùng chung được với Trouble, nhưng nên chọn một giao diện cho
mỗi danh sách.

`Space+xD` đưa toàn bộ diagnostics LSP vào Quickfix. Dùng `]q` và `[q` để đi
qua kết quả tiếp theo/trước đó từ mọi nguồn.

Lazygit bị tắt trên Windows vì lỗi ConPTY không ổn định; các lệnh Git native,
Fugitive, Gitsigns và Diffview vẫn hoạt động bình thường.

### Tìm Kiếm Theo Phạm Vi

| Phím | Hành động |
| --- | --- |
| `Space+fF` / `Space+fG` | Tìm file / grep theo thư mục hiện hành (cwd) |
| `Space+fe` / `Space+fE` | Tìm file / grep theo thư mục file đang mở |
| `Space+fN` | Alias của `Space+fg` |
| `Space+fR` | Mở lại picker trước, giữ query và phạm vi cũ |
| `Space+fw` | Tìm từ dưới con trỏ; ở Visual mode, tìm vùng chọn |
| `Space+fl` | Tìm dòng trong buffer hiện tại |
| `Space+fO` | File mở gần đây, trên các project |
| `Space+fk` | Tìm phím tắt |

Project được xác định từ file đang mở: thư mục cha gần nhất có `.git`
(hỗ trợ cả Git worktree), rồi marker ngôn ngữ như `package.json`,
`pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml` hoặc `.project-root`,
sau cùng là cwd. Trong monorepo Git, `ff/fg` tìm toàn repo; dùng `fe/fE`
để giới hạn theo thư mục package. Buffer chưa đặt tên hoặc buffer đặc biệt
dùng cwd làm điểm bắt đầu. Search không đổi `:pwd`, thư mục terminal hay session.
`fr` giữ phạm vi cwd của Grug Far; kiểm tra ô Paths trước khi thay thế.

Đường dẫn truyền trực tiếp qua tùy chọn picker, không ghép lệnh shell `cd`.
Giữ xử lý escape ripgrep trên Windows và fallback fd/rg. Grep nhanh vẫn theo
quy tắc ignore của ripgrep, nhưng bỏ icon và bước xử lý kết quả Lua;
`fg` thường vẫn có icon file. `Alt+h` bật/tắt tìm file ẩn.

### Điều Khiển UI Và Hiệu Năng

| Phím | Hành động |
| --- | --- |
| `Space+uz` / `Space+uZ` | Zen / phóng to cửa sổ; thoát để khôi phục bố cục |
| `Space+u.` / `Space+uS` | Ghi chú Markdown nhanh / chọn scratch đã lưu |
| `Space+uw` | Bật/tắt wrap cho cửa sổ hiện tại |
| `Space+ud` | Bật/tắt diagnostics toàn cục |
| `Space+ui` / `Space+uc` | Bật/tắt đường indent / highlight khối |
| `Space+ub` | Bật/tắt breadcrumbs |
| `Space+uf` / `Space+uF` | Bật/tắt autoformat toàn cục / buffer |
| `Space+up` | Xem thời gian tải plugin (`Lazy profile`) |
| `Space+uP` | Bắt đầu/dừng profiler Lua và xem kết quả |

Phím `Space+ci` hiện có vẫn bật/tắt inlay hints khi LSP hỗ trợ. Scratch lưu
trong thư mục data của Neovim, phân theo cwd, nhánh Git và count; copy config
không tự copy ghi chú. Zen không bật hiệu ứng dim.

Autoformat thông thường chờ tối đa 1000 ms. Java format nền sau khi lưu;
khi thoát Neovim, chờ tối đa 3000 ms để công việc nền hoàn tất.
Bỏ qua buffer đặc biệt/không cho sửa, cờ `bigfile`, file trên 1 MiB hoặc
trung bình trên 500 byte/dòng, kể cả file lớn lên sau khi mở. `Space+cf`
vẫn format thủ công bất đồng bộ cho file lớn. Ngôn ngữ khác format trước khi
ghi. Java ghi ngay rồi ghi lại sau khi format, nên file watcher có thể chạy
hai lần. Nếu bạn sửa tiếp khi Java đang format, Conform bỏ kết quả cũ để
giữ nguyên các thay đổi mới.

Nếu formatter timeout, xem `:ConformInfo`, dùng format thủ công hoặc đặt
`vim.g.autoformat_timeout_ms = 2000` trong `lua/config/local.lua`.
`vim.b.autoformat_timeout_ms` ưu tiên hơn thiết lập toàn cục. Tắt autoformat
toàn cục có ưu tiên hơn toggle buffer; `:FormatEnable` xóa cả hai cờ tắt.

### Trợ Lý AI

CodeCompanion v19 dùng Codex qua ACP cho buffer chat. Bảo đảm `curl`, `codex` và
`codex-acp` đều có trong `PATH`. Chat local qua Ollama không cần đăng nhập web;
chỉ chạy `codex login` nếu dùng provider Codex qua ChatGPT.

| Phím       | Chế độ        | Hành động                                       |
| ---------- | ------------- | ----------------------------------------------- |
| `Space+a?` | Normal/Visual | Mở action palette của CodeCompanion             |
| `Space+aa` | Normal        | Mở action palette của CodeCompanion             |
| `Space+aa` | Visual        | Thêm vùng chọn vào chat hiện tại                |
| `Space+am` | Visual        | Mở menu hành động vùng chọn bằng NUI            |
| `Space+aq` | Visual        | Hỏi tự do về đoạn mã đã chọn                    |
| `Space+ae` | Visual        | Giải thích đoạn mã đã chọn                      |
| `Space+af` | Visual        | Tìm và sửa lỗi trong đoạn mã đã chọn            |
| `Space+al` | Visual        | Giải thích chẩn đoán LSP trong vùng chọn        |
| `Space+at` | Visual        | Tạo test cho đoạn mã đã chọn                    |
| `Space+aR` | Visual        | Refactor đoạn mã đã chọn                        |
| `Space+ac` | Normal/Visual | Ghi nhận xét review cho dòng hoặc vùng chọn     |
| `Space+ai` | Normal/Visual | Bật/tắt chat hiện tại                           |
| `Space+an` | Normal/Visual | Tạo chat mới                                    |
| `Space+ar` | Normal        | Làm mới cache tính năng/tool chat               |
| `Space+av` | Normal        | Review thay đổi do agent hiện tại tạo           |
| `Space+aV` | Normal        | Review mọi thay đổi từ mốc baseline             |
| `Space+ax` | Normal        | Liệt kê file CodeCompanion đã thay đổi          |
| `Space+aS` | Normal        | Dừng yêu cầu của chat gần nhất                  |

`Space+am` mở menu NUI gọn với Ask, Explain, Diagnostics, Fix, Refactor,
Tests, Documentation và Code workflow ba bước. Menu lưu vùng chọn trước khi
mở popup nên đoạn mã vẫn được đính kèm sau khi chọn hành động. `Space+aq` mở
thẳng ô nhập câu hỏi NUI.

Action palette vẫn dùng Snacks nhưng chỉ liệt kê prompt chạy được qua chat ACP
của Codex: Explain, Fix, Diagnostics, Tests, Refactor, Documentation,
selection workflow và Commit message. Các prompt inline có sẵn trong repo được
ẩn vì chúng cần một HTTP adapter cấu hình riêng.

Chat mới không tự thêm file hiện tại. Chèn `#{buffer}` vào prompt để gửi ngữ
cảnh file và theo dõi phần thay đổi; dùng `#{buffer}{all}` nếu mỗi lượt cần gửi
toàn bộ file. Dùng `/buffer` để chọn buffer đang mở hoặc `/file` để chọn file
trong thư mục làm việc.

Buffer chat và prompt xác nhận thay đổi bổ sung keymap cục bộ, nên các phím này
không ghi đè keymap editor ở nơi khác:

| Phím                    | Phạm vi                        | Hành động                                      |
| ----------------------- | ------------------------------ | ---------------------------------------------- |
| `<CR>` hoặc `<C-s>`     | Normal; `<C-s>` dùng cả Insert | Gửi prompt                                     |
| `q`                     | Chat, Normal                   | Dừng yêu cầu hiện tại                          |
| `ga`                    | Chat, Normal                   | Chọn adapter và model                          |
| `Space+ab`              | Chat, Normal                   | Chọn buffer đang mở bằng FzfLua                |
| `Space+af`              | Chat, Normal                   | Chọn file bằng FzfLua                          |
| `Space+ah`              | Chat, Normal                   | Chọn tài liệu Neovim bằng FzfLua               |
| `Space+am`              | Chat, Normal                   | Đổi model, mode hoặc reasoning của ACP         |
| `Space+ap`              | Chat, Normal                   | Chọn ảnh bằng Snacks                           |
| `Space+aP`              | Chat, Normal                   | Dán ảnh clipboard qua img-clip                 |
| `Space+aR`              | Chat mới, Normal               | Tiếp tục một phiên ACP trước đó                |
| `Space+as`              | Chat, Normal                   | Chọn symbol trong file bằng FzfLua             |
| `Space+ad`              | Xác nhận trong chat, Normal    | Xem diff được đề xuất                          |
| `?`                     | Chat, Normal                   | Xem các tùy chọn và keymap có trong chat       |

Blink cung cấp completion trong chat. Action palette và bộ chọn ảnh dùng
Snacks; các bộ chọn liên quan đến file dùng FzfLua. Trong quickfix code review,
`d` mở hunk đang chọn so với baseline của CodeCompanion bằng Diffview; các phím
`a`, `c` và `x` có sẵn để chấp nhận, ghi nhận xét hoặc bỏ qua hunk đó.

Dùng `Space+aP` (hoặc `:PasteImage`) trong chat để đính kèm ảnh từ clipboard,
hoặc `Space+ap` (hay `/image`) để chọn ảnh từ file hay URL. Dán ảnh cần
`pngpaste` trên macOS và `xclip` hoặc `wl-clipboard` trên Linux.

Adapter ACP chỉ dùng được với tương tác chat của CodeCompanion. Hãy dùng action
palette, action trên vùng chọn hoặc `:CodeCompanion /<alias>`; prompt inline
`:CodeCompanion` thông thường, `CodeCompanionCmd` và CLI interaction cần HTTP
hoặc CLI adapter được cấu hình riêng.

Tài khoản và cấu hình Codex vẫn nằm trong `~/.codex` mặc định của từng hệ điều
hành. Cấu hình đặt `CODEX_SQLITE_HOME` thành
`stdpath("data")/nvim-config/codex-sqlite` để tách SQLite đang chạy của ACP khỏi
Codex Desktop mà không sao chép token hoặc đặt `CODEX_HOME`.

## Tính Năng Tùy Chọn

### CodeCompanion v19 Với Codex ACP

Để dùng CodeCompanion v19, cần có `curl`. Cài Codex CLI và bản `codex-acp` hiện
hành, bảo đảm cả ba lệnh có trong `PATH`. Chỉ chạy `codex login` nếu dùng
provider Codex qua ChatGPT:

```powershell
npm install --global @openai/codex @agentclientprotocol/codex-acp
codex login
codex login status
```

Mở Neovim và dùng `Space+an` để tạo chat mới hoặc `Space+ai` để bật/tắt chat.
Chat local qua Ollama không cần đăng nhập ACP trong trình duyệt. CodeCompanion
tắt web search tích hợp và tăng ngân sách danh sách skills chỉ trong các phiên
này; chat Codex thông thường giữ cấu hình riêng. Codex ACP chỉ dùng cho chat và
không cần đặt biến môi trường `CODEX_HOME`.

Lazydocker, Docker, Maven, Gradle và `uv` chỉ cần cài nếu dùng workflow tương
ứng. Tích hợp Lazygit hiện bị tắt trên Windows.

## Hiệu Năng

Phần lõi khi startup chỉ gồm lazy.nvim, options/keymaps/autocmd, Catppuccin,
Treesitter (yêu cầu của nhánh `main`) và dashboard Snacks.
Plugin nặng load theo filetype, command, event hoặc keymap. Devicons
được hoãn tới sau frame đầu.

Với file lớn, cấu hình tắt hoặc không khởi động Treesitter, LSP, completion và
một số tính năng nặng để giữ editor phản hồi tốt. LSP attach muộn cũng được
detach khỏi buffer bigfile; buffer ảo như Diffview cũng không nhận LSP để tránh
URI không hợp lệ.

Autocmd trong cấu hình xử lý file trên 1 MiB trước khi nhận diện filetype. Bộ kiểm tra
bổ sung nhận file trên 10.000 dòng hoặc có dòng dài trên 2.000 byte; Snacks
bigfile đã tắt để tránh xử lý trùng. Chế độ này tắt cả syntax highlighting,
nhưng giữ undo và swap recovery. File lớn lên vượt ngưỡng dung lượng/số dòng
trong lúc sửa cũng được bảo vệ.
Autoformat còn bỏ qua file trung bình trên 500 byte/dòng.
Phím TODO tải plugin ngay lần nhấn đầu ở cả hai profile; tự lưu session cũng
hoạt động ở profile máy yếu, còn khôi phục session vẫn do bạn chủ động.

Mason tool installation chạy sau startup và được giới hạn tần suất để tránh
kiểm tra quá thường xuyên.

Đo cả thao tác mở file rồi gõ ngay, grep repo lớn và lưu file có formatter.
Hoãn tải plugin chỉ chuyển công việc sang sau frame đầu. `Space+uP` chỉ ghi
lại lời gọi Lua khi được bật và có thêm overhead; dùng để tìm hàm tốn thời
gian, không xem đó là benchmark độ trễ tuyệt đối. Profiler không tự chạy.

Giao diện code action chỉ tải khi dùng; Copilot tải lúc vào Insert lần đầu.
Exa MCP chỉ tự khởi động khi có `EXA_API_KEY`; nếu chưa đặt, có thể chọn qua
`/mcp` trong chat. Nhấn Stop khi ACP đang kết nối sẽ hủy câu hỏi đang chờ.
`TermGitPushF` dùng `--force-with-lease` để từ chối ghi đè nhánh remote đã có
thay đổi mới kể từ lần fetch cuối.

## Bảo Trì

Kiểm tra hồi quy từ thư mục config:

```sh
nvim --headless -u NONE -i NONE -l tests/ide.lua
nvim --headless -u NONE -i NONE -l tests/upgrades.lua
nvim --headless -u NONE -i NONE -l tests/startup.lua
nvim --headless -u NONE -i NONE -l tests/dashboard_pick.lua
```

Bài kiểm tra startup cần `fzf`, `rg` và các plugin đã cài; kiểm tra lần Insert
đầu và kết quả picker bằng chế độ headless.
Bài kiểm tra nâng cấp dùng dữ liệu tạm và plugin đã cài, không update plugin
hay ghi vào scratch/session thật. Khi mang sang máy khác, giữ `lazy-lock.json`
và chạy `:Lazy restore`. Giữ workaround Treesitter cho frame đầu và Blink
cho lần Insert đầu; kiểm tra completion ngay lần gõ đầu và chọn file từ
dashboard sau khi update plugin.

Cập nhật plugin và tool:

```vim
:Lazy sync
:Lazy update
:Lazy restore
:Mason
:MasonToolsInstall
:MasonUpdate
:TSUpdate
```

Khi cập nhật plugin, chạy `:Lazy update` để lấy commit mới và cập nhật
`lazy-lock.json`. Trên máy mới, dùng `:Lazy install` rồi `:Lazy restore` để cài theo lockfile.
Giữ lockfile trong Git để môi trường có thể tái lập. Nếu có lỗi parser
Treesitter sau cập nhật, thử gỡ và cài lại parser bị lỗi.

## Xử Lý Lỗi

### `:checkhealth` Chung Báo Lỗi Snacks Hoặc `vim.pack`

Cấu hình dùng dashboard, quickfile, input và picker của Snacks; picker
sở hữu `vim.ui.select`. Snacks image và notifier riêng bị tắt, còn Notify xử lý
thông báo. Cấu hình dùng lazy.nvim thay cho `vim.pack`. `:checkhealth` không có
tham số vẫn kiểm tra các thành phần đã tắt. Trong terminal headless, nó có thể
báo thiếu Kitty graphics, dashboard chưa chạy, image/notifier bị tắt hoặc thiếu
`nvim-pack-lock.json`; đây không phải lỗi khởi động của cấu hình.

Hãy dùng lệnh kiểm tra đúng phạm vi:

```vim
:checkhealth lazy vim.lsp vim.provider vim.deprecated vim.treesitter
```

CodeCompanion được lazy-load. Muốn kiểm tra riêng, hãy load trước:

```vim
:Lazy load codecompanion.nvim
:checkhealth codecompanion
```

Khi offline, `vim.provider` có thể chỉ lỗi ở bước tùy chọn kiểm tra phiên bản
trên PyPI; Python provider vẫn dùng được nếu executable và phiên bản `pynvim`
được báo thành công.

Node, Perl và Ruby remote provider được tắt có chủ đích vì không plugin nào
trong cấu hình sử dụng chúng. Việc này không tắt language server/formatter dùng
Node, Treesitter CLI hoặc plugin Lua thông thường.

### Lệnh Headless Báo Lỗi PSReadLine Prediction

Thông báo này đến từ PowerShell profile, không phải Neovim. Chỉ bật prediction
trong terminal tương tác:

```powershell
if ($Host.UI.SupportsVirtualTerminal -and -not [Console]::IsOutputRedirected) {
    Set-PSReadLineOption -PredictionSource History
}
```

Đặt điều kiện này trong `Microsoft.PowerShell_profile.ps1`, rồi mở lại
terminal. Các lệnh redirect như health-check headless sẽ không còn in lỗi
PSReadLine không liên quan.

### Codex ACP Báo Lỗi Quyền SQLite Hoặc `arg0`

Không đặt `CODEX_HOME` trong cấu hình Neovim. Đăng nhập bằng Codex home mặc
định:

```powershell
codex login
codex doctor --summary
```

CodeCompanion vẫn dùng tài khoản/cấu hình Codex trong `~/.codex` mặc định của hệ
điều hành, nhưng `CODEX_SQLITE_HOME` tách runtime ACP vào
`stdpath("data")/nvim-config/codex-sqlite`. Cách này tránh Codex Desktop và
`codex-acp` tranh chấp cùng database. Sau khi đổi đăng nhập, đóng Neovim/ACP cũ
rồi mở lại Neovim.

### Markdown Để Lại `E31: No such mapping`

Cập nhật cấu hình này rồi khởi động lại Neovim. Neovim 0.12 đã cung cấp mapping
Lua cho heading Markdown, nên cấu hình tắt bộ mapping Vimscript cũ bị trùng.
`[[` và `]]` vẫn hoạt động để đi tới heading trước/sau.

### Neovim Chỉ Hoạt Động Sau Khi Chạy `:source %`

Kiểm tra biến môi trường `VIMINIT`.

Windows PowerShell:

```powershell
Get-ChildItem Env:VIMINIT
```

Linux/macOS:

```bash
printf '%s\n' "$VIMINIT"
```

Nếu biến này trỏ tới cấu hình cũ, hãy xóa nó khỏi shell profile rồi mở lại
Neovim. Repo này chỉ dùng `init.lua`; không cần và không nên tạo thêm
`init.vim`, vì Neovim mới sẽ báo `E5422: Conflicting configs` khi cả hai file
cùng tồn tại.

### `module 'helper.utils' not found`

Kiểm tra repo được đặt trực tiếp trong thư mục cấu hình Neovim:

```vim
:echo stdpath('config')
```

Thư mục đó phải chứa trực tiếp `init.lua` và `lua/helper/utils.lua`; không nên
có thêm thư mục lồng như `nvim-config/` ở giữa.

### Treesitter Không Tìm Thấy Compiler

Kiểm tra:

```vim
:echo executable('zig')
:echo $CC
:checkhealth nvim-treesitter
```

Windows cần Zig và hai wrapper trong `bin/`. Linux/macOS cần GCC, Clang hoặc
biến `CC`/`CXX`. Sau khi sửa compiler, chạy:

```vim
:TSUpdate
```

Nếu gặp lỗi parser ABI hoặc `range`, gỡ và cài lại parser bị ảnh hưởng:

```vim
:TSUninstall <language>
:TSInstall <language>
```

### Thiếu Header Chuẩn C/C++

Nếu `clangd` báo lỗi như `'iostream' file not found`, trước tiên kiểm tra có
C++ compiler thật trong môi trường khởi động Neovim hay chưa.

Windows PowerShell với Scoop GCC:

```powershell
g++ --version
where g++
```

Linux/macOS:

```bash
g++ --version || clang++ --version
```

Sau đó mở buffer C/C++ và kiểm tra LSP:

```vim
:LspInfo
:Mason
```

Restart `clangd` sau khi thay đổi compiler hoặc `PATH`:

```vim
:LspRestart clangd
```

Nếu thấy `Too many errors emitted, stopping now`, hãy xem diagnostic đầu tiên
thay vì dòng tổng kết cuối:

```vim
:lua vim.diagnostic.setqflist()
:copen
```

Với CMake, Meson hoặc project lớn, tạo `compile_commands.json` để `clangd`
dùng cùng compiler flags với build system.

### JDTLS Không Khởi Động

Kiểm tra:

```vim
:echo $JAVA_HOME
:echo executable('java')
:LspInfo
:Mason
```

Cấu hình này yêu cầu JDK 25. Hãy mở Neovim từ project root có `pom.xml`,
`build.gradle`, `mvnw`, `gradlew` hoặc `.git`.

### Java Test Không Chạy

Chạy:

```vim
:Lazy load neotest
:NeotestJava setup
```

Kiểm tra Maven hoặc Gradle wrapper có chạy bên ngoài Neovim không. Package
`vscode-java-test` `java-test` không được Mason quản lý ở đây; cấu hình dùng
`neotest-java` và JUnit Console để tránh xung đột dependency.

### `gopls` Không Khởi Động Hoặc Không Cập Nhật

Kiểm tra Go runtime và Mason:

```vim
:echo executable('go')
:LspInfo
:Mason
```

Sau đó chạy `:MasonUpdate` và restart server bằng `:LspRestart`.

### Tìm File Hoặc Grep Không Có Kết Quả

Kiểm tra:

```vim
:echo executable('rg')
:echo executable('fzf')
```

FzfLua ưu tiên `fd` để tìm file, dùng `rg --files` khi thiếu `fd`, và
dùng `rg` cho live grep. Hãy đảm bảo `rg` có trong môi trường khởi động Neovim.

### Clipboard Linux Không Hoạt Động

Chạy:

```vim
:checkhealth provider
```

Cài `wl-clipboard` trên Wayland hoặc `xclip`/`xsel` trên X11, rồi restart
terminal và Neovim.

### Dashboard Bị Cắt Hoặc Lệch Lên

Dashboard tự ẩn `laststatus` và `showtabline`. Nếu plugin khác bật lại chúng,
kiểm tra:

```vim
:set laststatus?
:set showtabline?
:set filetype?
```

Dashboard buffer nên có `filetype=snacks_dashboard`; event mở và đóng của nó
sẽ ẩn/khôi phục Lualine và Bufferline.

## Tham Khảo

- [Neovim installation](https://github.com/neovim/neovim/blob/master/INSTALL.md)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [Mason](https://github.com/mason-org/mason.nvim)
- [Blink completion](https://github.com/Saghen/blink.cmp)
- [CodeCompanion](https://github.com/olimorris/codecompanion.nvim)
- [Tài liệu CodeCompanion](https://codecompanion.olimorris.dev/)
- [codex-acp](https://github.com/agentclientprotocol/codex-acp)
- [Snacks dashboard](https://github.com/folke/snacks.nvim)
- [Dial](https://github.com/monaqa/dial.nvim)
- [IncRename](https://github.com/smjonas/inc-rename.nvim)
- [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)
- [neotest-java](https://github.com/rcasia/neotest-java)


### Hiệu năng và auto-import

- LSP tải theo loại mã nguồn; file văn bản thường không tải bộ LSP.
- Plugin UI tải trễ đợi Normal mode và khoảng nghỉ gõ 300 ms. Completion vẫn tải khi cần trong Insert mode.
- Tìm root không vượt lên thư mục home của người dùng để tránh nhận nhầm `package.json` dùng chung là dự án.
- File trên 10.000 dòng hoặc dòng dài trên 2.000 ký tự dùng chế độ `bigfile`. Có thể chỉnh `vim.g.sungp_bigfile_lines` và `vim.g.sungp_bigfile_line_length` trong `lua/config/local.lua`; cơ chế giới hạn dung lượng vẫn hoạt động riêng.
- Chọn gợi ý LSP bằng Tab/Ctrl-y để thêm import; server cần hoàn tất lập chỉ mục và thư viện phải có trong môi trường dự án. Với tên đã gõ, dùng `<leader>ca` để chọn code action mà server cung cấp.
- Kiểm tra tích hợp: `nvim --headless -u NONE -i NONE -l tests/startup.lua`; auto-import TypeScript thật: cùng lệnh với `tests/autoimport.lua` (cần server đã cài).


### Rà soát toàn bộ cấu hình

`Tab` ưu tiên menu completion, rồi snippet, rồi gợi ý AI; `Ctrl-y` luôn dùng để chấp nhận completion.
Go dùng gopls cho auto-import completion và goimports khi lưu, không sửa import bằng timer InsertLeave.
`:LspRestart` giữ nội dung chưa lưu và khởi động lại các buffer vốn gắn vào client.
`:ConfigHealth` báo project root, trạng thái format, LSP và số plugin đã tải.
