" Compatibility shim for environments that still set VIMINIT to init.vim.
lua vim.opt.runtimepath:prepend(vim.fn.expand('<sfile>:p:h'))
lua dofile(vim.fn.expand('<sfile>:p:h') .. '/init.lua')
