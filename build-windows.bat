@echo off
rem ==========================================================================
rem  Where - build the Windows release files
rem
rem    build-windows.bat          build engine + app, package into dist\
rem    build-windows.bat --help   show this help
rem
rem  Produces in dist\v<version>\:
rem    Where-<version>-windows-x64-portable.zip
rem    Where-Setup-<version>-windows-x64.exe   (if Inno Setup is installed)
rem
rem  Requires tools already installed:
rem    Rust (cargo), Flutter, Visual Studio C++ Build Tools.
rem  Missing tools?  Run start-where.bat once — it installs everything.
rem ==========================================================================
setlocal EnableExtensions
cd /d "%~dp0"

if /i "%~1"=="--help" goto :help
if /i "%~1"=="-h"     goto :help
if /i "%~1"=="/?"     goto :help

rem ---- colours (Windows 10+) -----------------------------------------------
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
set "OK=%ESC%[92m"
set "WK=%ESC%[96m"
set "WN=%ESC%[93m"
set "ER=%ESC%[91m"
set "HD=%ESC%[1;97m"
set "DM=%ESC%[90m"
set "EN=%ESC%[0m"

rem ---- paths ---------------------------------------------------------------
set "ROOT=%~dp0"
set "APP=%ROOT%apps\where_flutter"
set "CARGO_TARGET_DIR=%ROOT%target"
set "SCRIPTS=%ROOT%scripts"

rem Read version from workspace Cargo.toml
for /f "tokens=3 delims= " %%V in ('findstr /r "^version = " "%ROOT%Cargo.toml"') do set "_VER=%%V"
set "VERSION=%_VER:"=%"
set "TAG=v%VERSION%"
set "DIST=%ROOT%dist\%TAG%"

rem Detect architecture
set "ARCH=x64"
if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "ARCH=arm64"
set "EXE_DIR=%APP%\build\windows\%ARCH%\runner\Release"

echo.
echo   %HD%W H E R E%EN%   build %VERSION% — Windows %ARCH%
echo   %DM%---------------------------------------------------%EN%
echo.

rem ---- [1/4] engine --------------------------------------------------------
echo   %HD%[1/4]%EN% Building the search engine
cargo build --release -p where_ffi -p where_cli
if errorlevel 1 (
  echo   %ER%XX  Engine build failed.%EN%
  goto :fail
)
if not exist "%ROOT%target\release\where_ffi.dll" (
  echo   %ER%XX  where_ffi.dll not found in target\release\.%EN%
  echo   %DM%      Check .cargo\config.toml for a custom build target.%EN%
  goto :fail
)
echo   %OK%OK%EN%  Engine ready

rem ---- [2/4] app -----------------------------------------------------------
echo   %HD%[2/4]%EN% Building the app
pushd "%APP%"
if not exist "windows\runner" (
  echo   %WK%..%EN%  Creating Windows project files...
  call flutter create --platforms=windows --project-name where_flutter --org com.crowncorestudios . >nul
)
call flutter pub get
if errorlevel 1 (popd & echo   %ER%XX  flutter pub get failed.%EN% & goto :fail)
call flutter build windows --release
if errorlevel 1 (
  popd
  echo   %ER%XX  App build failed.%EN%
  goto :fail
)
popd
if not exist "%EXE_DIR%\Where.exe" (
  echo   %ER%XX  Where.exe not found at: %EXE_DIR%%EN%
  goto :fail
)
echo   %OK%OK%EN%  App ready

rem ---- [3/4] assemble ------------------------------------------------------
echo   %HD%[3/4]%EN% Assembling the package

rem Engine and CLI
for %%F in (where_ffi.dll where-cli.exe) do (
  if exist "%ROOT%target\release\%%F" copy /y "%ROOT%target\release\%%F" "%EXE_DIR%\" >nul
)

rem Microsoft C++ runtime (so Where starts on PCs without the Redistributable)
for %%D in (msvcp140.dll vcruntime140.dll vcruntime140_1.dll) do (
  if exist "%WINDIR%\System32\%%D" copy /y "%WINDIR%\System32\%%D" "%EXE_DIR%\" >nul
)

rem Browser extension
if exist "%ROOT%browser-extension\manifest.json" (
  if exist "%EXE_DIR%\browser-extension" rmdir /s /q "%EXE_DIR%\browser-extension" >nul 2>&1
  xcopy "%ROOT%browser-extension" "%EXE_DIR%\browser-extension\" /e /i /y /q >nul
)

rem Legal files
for %%F in (LICENSE NOTICE) do (
  if exist "%ROOT%%%F" copy /y "%ROOT%%%F" "%EXE_DIR%\" >nul
)

rem Make dist folder
if not exist "%DIST%" mkdir "%DIST%"

rem Stage into a temp folder, then zip
set "STAGE=%TEMP%\where-stage-%VERSION%-%ARCH%"
if exist "%STAGE%" rmdir /s /q "%STAGE%"
mkdir "%STAGE%\Where"
xcopy "%EXE_DIR%" "%STAGE%\Where\" /e /i /y /q >nul

rem Portable zip
set "ZIP=%DIST%\Where-%VERSION%-windows-%ARCH%-portable.zip"
powershell -NoProfile -Command "Compress-Archive -Path '%STAGE%\Where' -DestinationPath '%ZIP%' -Force"
if errorlevel 1 (echo   %WN%!!  Portable zip failed.%EN%) else (echo   %OK%OK%EN%  Where-%VERSION%-windows-%ARCH%-portable.zip)

rem Installer (Inno Setup 6)
set "ISCC="
for %%P in (
  "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
  "%ProgramFiles%\Inno Setup 6\ISCC.exe"
  "%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe"
) do if exist %%P set "ISCC=%%~P"

if defined ISCC (
  echo   %WK%..%EN%  Building installer...
  "%ISCC%" /Qp "/DAppVersion=%VERSION%" "/DSourceDir=%STAGE%\Where" "/DOutDir=%DIST%" "/DIconFile=%APP%\windows\runner\resources\app_icon.ico" "%ROOT%installer\windows\where.iss"
  if errorlevel 1 (
    echo   %WN%!!  Installer build failed — portable zip is still available.%EN%
  ) else (
    echo   %OK%OK%EN%  Where-Setup-%VERSION%-windows-%ARCH%.exe
  )
) else (
  echo   %WN%!!%EN%  Inno Setup not found — skipping installer.
  echo   %DM%      Install from https://jrsoftware.org/isinfo.php%EN%
)

if exist "%STAGE%" rmdir /s /q "%STAGE%" >nul 2>&1

rem ---- [4/4] done ----------------------------------------------------------
echo   %HD%[4/4]%EN% Done
echo.
echo   Files in  dist\%TAG%\
echo.
dir /b "%DIST%"
echo.
goto :end

:help
echo   %HD%build-windows.bat%EN%   build the Windows release files into dist\
echo   Requires: Rust (cargo), Flutter, Visual Studio C++ Build Tools.
echo   Missing tools?  Run start-where.bat once to install them.
goto :end

:fail
echo.
echo   %ER%Build stopped.%EN%  Fix the error above and run again.
echo.
endlocal
exit /b 1

:end
endlocal
exit /b 0
