@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

title LCP STARTER ASM Compiler

echo ==========================================
echo    LCP STARTER ASM - COMPILER v1.0
echo    (c) LCP CORPORATION
echo ==========================================
echo.

set NASM=C:\NASM\nasm.exe

if not exist "%NASM%" (
    echo [ERROR] NASM not found at %NASM%
    echo Please install NASM to C:\NASM
    goto END
)

if "%~1"=="" goto AUTO

if "%~1"=="-p" goto MANUAL

goto AUTO

:MANUAL
if "%~2"=="" goto USAGE
if "%~3"=="" goto USAGE
if "%~4"=="" goto USAGE

set MODE=%~2
set INPUT=%~3
set FLAG=%~4

if not "%FLAG%"=="-alm" if not "%FLAG%"=="-hjd_alm" goto USAGE
goto CHECKFILE

:AUTO
echo Auto mode: searching .ASM file...
set INPUT=
for %%f in (*.asm *.ASM) do (
    if /i not "%%f"=="LCP_STARTER.ASM" (
        if "!INPUT!"=="" set INPUT=%%f
    )
)

if "%INPUT%"=="" (
    echo [ERROR] No .ASM file found!
    dir /b *.asm *.ASM 2>nul
    goto END
)

echo Found: %INPUT%
set MODE=bin
set FLAG=-alm
echo.

:CHECKFILE
if not exist "%INPUT%" (
    echo [ERROR] File not found: %INPUT%
    goto END
)

for %%f in ("%INPUT%") do set NAME=%%~nf

echo File: %INPUT%
echo Output: %NAME%.bin
echo.

if not exist "LCP_STARTER.ASM" (
    echo [WARNING] LCP_STARTER.ASM not found!
)

if "%MODE%"=="bin" if "%FLAG%"=="-alm" call :BIN
if "%MODE%"=="consoleMODE" if "%FLAG%"=="-hjd_alm" call :CONSOLE
goto END

:BIN
echo Compiling...
"%NASM%" -f bin "%INPUT%" -o "%NAME%.bin" 2>_err.txt
if errorlevel 1 (
    echo [ERROR] Compilation failed!
    type _err.txt
    del _err.txt 2>nul
    goto :eof
)
del _err.txt 2>nul

for %%A in ("%NAME%.bin") do set BS=%%~zA
echo Done: %NAME%.bin - %BS% bytes

> "%NAME%.lst" (
    echo ==========================================
    echo   LCP STARTER ASM - LISTING
    echo   File: %INPUT% - %BS% bytes
    echo ==========================================
    echo.
    type "%INPUT%"
)

echo.
echo ==========================================
echo   SUCCESS!
echo   - %NAME%.bin (%BS% bytes)
echo   - %NAME%.lst
echo ==========================================
goto :eof

:CONSOLE
echo Compiling...
"%NASM%" -f bin "%INPUT%" -o "%NAME%.bin" 2>_err.txt
if errorlevel 1 (
    echo [ERROR] Compilation failed!
    type _err.txt
    del _err.txt 2>nul
    goto :eof
)
del _err.txt 2>nul

for %%A in ("%NAME%.bin") do set BS=%%~zA
echo Done: %NAME%.bin - %BS% bytes

> "%NAME%.hjd" (
    echo ==========================================
    echo   LCP STARTER ASM - CONSOLE LISTING
    echo   File: %INPUT% - %BS% bytes
    echo ==========================================
    echo.
    type "%INPUT%"
)

start "LCP" cmd.exe /k "echo ========================================== && echo   LCP STARTER ASM - %NAME% && echo   %BS% bytes && echo ========================================== && echo. && certutil -dump %NAME%.bin && echo. && pause"

echo.
echo ==========================================
echo   SUCCESS!
echo   - %NAME%.bin (%BS% bytes)
echo   - %NAME%.hjd
echo ==========================================
goto :eof

:USAGE
echo.
echo USAGE:
echo   lcpstartasm.bat -p bin file.asm -alm
echo   lcpstartasm.bat -p consoleMODE file.asm -hjd_alm
echo.
echo Or just double-click for AUTO mode.
echo.

:END
endlocal

pause