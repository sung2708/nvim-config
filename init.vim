" Compatibility shim for environments that still set VIMINIT to init.vim.
execute 'luafile ' . fnameescape(expand('<sfile>:p:h') . '/init.lua')
