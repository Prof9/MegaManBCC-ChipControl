@echo off
setlocal

set "_TEMP=_temp"
set "_ROM_IN_US=_rom\mmbcc-us.gba"
set "_ROM_IN_EU=_rom\mmbcc-eu.gba"
set "_ROM_IN_JP=_rom\exebcgp.gba"
set "_ROM_OUT_US=_rom\MMBCC-ChipControl-US.gba"
set "_ROM_OUT_EU=_rom\MMBCC-ChipControl-EU.gba"
set "_ROM_OUT_JP=_rom\EXEBCGP-ChipControl-JP.gba"

set "_TARGET=%1"
if [%1]==[] (
	set "_TARGET=us"
)
if /I "%_TARGET%"=="us" (
	set "_TARGET=us"
	set "_ROM_IN=%_ROM_IN_US%"
	set "_ROM_OUT=%_ROM_OUT_US%"
	set "_ARMIPS_FLAG=-definelabel VER_EN 1"
) else if /I "%_TARGET%"=="eu" (
	set "_TARGET=eu"
	set "_ROM_IN=%_ROM_IN_EU%"
	set "_ROM_OUT=%_ROM_OUT_EU%"
	set "_ARMIPS_FLAG=-definelabel VER_EN 1"
) else if /I "%_TARGET%"=="jp" (
	set "_TARGET=jp"
	set "_ROM_IN=%_ROM_IN_JP%"
	set "_ROM_OUT=%_ROM_OUT_JP%"
	set "_ARMIPS_FLAG=-definelabel VER_JP 1"
) else if /I "%_TARGET%" neq "clean" (
	echo Unknown target %1
	goto :error
)

for %%f in ("%_ROM_OUT%") do (
	set "_SYM_OUT=%%~dpnf.sym"
	set "_TEMP_OUT=%_TEMP%\%%~nf.temp.txt"
)

mkdir "%_TEMP%" 2> nul
pushd "%_TEMP%"
rmdir /S /Q . 2> nul
popd

if /I "%1"=="clean" (
	for %%f in ("%_ROM_OUT_US%") do (
		del /Q "%%~dpnf.sym" 2> nul
		del /Q "%%~dpnf.gba" 2> nul
	)
	for %%f in ("%_ROM_OUT_EU%") do (
		del /Q "%%~dpnf.sym" 2> nul
		del /Q "%%~dpnf.gba" 2> nul
	)
	for %%f in ("%_ROM_OUT_JP%") do (
		del /Q "%%~dpnf.sym" 2> nul
		del /Q "%%~dpnf.gba" 2> nul
	)
	goto :done
)

if not exist "%_ROM_IN%" (
	echo File not found: "%_ROM_IN%"
	goto :error
)

:start

rem goto :armips

echo Generating graphics...
call "gfx.bat" || goto :error

echo Patching ROM...
"tools\armips.exe" "src.asm" ^
	-strequ ROM_IN "%_ROM_IN%" ^
	-strequ ROM_OUT "%_ROM_OUT%" ^
	-strequ TEMP "%_TEMP%" ^
	-sym2 "%_SYM_OUT%" ^
	-temp "%_TEMP_OUT%" ^
	-erroronwarning ^
	%_ARMIPS_FLAG% ^
	|| goto :error

:done
echo Done
exit /b 0

:error
echo Error
exit /b 1
