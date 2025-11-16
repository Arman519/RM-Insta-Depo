@echo off
REM ============================================================================
REM RM-Insta-Depo Compilation Script
REM ============================================================================
REM This script automatically compiles the AutoHotkey script to a standalone EXE
REM ============================================================================

echo.
echo ========================================
echo   RM-Insta-Depo Compiler
echo ========================================
echo.

REM Set paths (modify if your AutoHotkey is installed elsewhere)
set AHK_COMPILER=C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe
set SCRIPT_NAME=RM-Insta-Depo_S6_v2.ahk
set OUTPUT_NAME=RM-Insta-Depo.exe
set ICON_FILE=RM-Insta-Depo.ico

REM Check if AutoHotkey compiler exists
if not exist "%AHK_COMPILER%" (
    echo ERROR: AutoHotkey compiler not found!
    echo Expected location: %AHK_COMPILER%
    echo.
    echo Please install AutoHotkey from: https://www.autohotkey.com/
    echo Or update the AHK_COMPILER path in this script.
    echo.
    pause
    exit /b 1
)

REM Check if source script exists
if not exist "%SCRIPT_NAME%" (
    echo ERROR: Source script not found: %SCRIPT_NAME%
    echo Please ensure you're running this from the correct directory.
    echo.
    pause
    exit /b 1
)

echo Found AutoHotkey compiler: %AHK_COMPILER%
echo Found source script: %SCRIPT_NAME%
echo.

REM Compile the script
echo Compiling...
echo.

if exist "%ICON_FILE%" (
    echo Using custom icon: %ICON_FILE%
    "%AHK_COMPILER%" /in "%SCRIPT_NAME%" /out "%OUTPUT_NAME%" /icon "%ICON_FILE%" /compress 1 /base "C:\Program Files\AutoHotkey\Compiler\Unicode 64-bit.bin"
) else (
    echo No custom icon found, using default
    "%AHK_COMPILER%" /in "%SCRIPT_NAME%" /out "%OUTPUT_NAME%" /compress 1 /base "C:\Program Files\AutoHotkey\Compiler\Unicode 64-bit.bin"
)

REM Check compilation result
if exist "%OUTPUT_NAME%" (
    echo.
    echo ========================================
    echo   SUCCESS!
    echo ========================================
    echo.
    echo Compiled file: %OUTPUT_NAME%
    for %%A in ("%OUTPUT_NAME%") do echo File size: %%~zA bytes
    echo.
    echo Your standalone executable is ready!
    echo You can now distribute %OUTPUT_NAME% to users.
    echo No AutoHotkey installation required to run it.
    echo.
) else (
    echo.
    echo ========================================
    echo   COMPILATION FAILED
    echo ========================================
    echo.
    echo Please check the error messages above.
    echo.
)

pause
