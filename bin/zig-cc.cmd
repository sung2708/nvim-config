@echo off
setlocal enabledelayedexpansion
set "args="
:next
if "%~1"=="" goto run
set "arg=%~1"
if "!arg!"=="x86_64-pc-windows-msvc" set "arg=x86_64-windows-gnu"
if "!arg!"=="--target=x86_64-pc-windows-msvc" set "arg=--target=x86_64-windows-gnu"
set args=!args! "!arg!"
shift
goto next
:run
zig cc %args%
