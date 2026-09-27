@echo off
rem ==========================================================================
rem  Where - make a GitHub Release from files you've already built
rem
rem    make-release.bat              version from Cargo.toml
rem    make-release.bat 0.7.0        a specific version
rem    make-release.bat -Fetch       also pull the Mac/Linux files GitHub built
rem    make-release.bat -Draft       publish as a draft you can review first
rem
rem  Build the files first, then run this:
rem    Windows:  build-windows.bat          (or start-where.bat)
rem    Mac:      bash build-macos.sh        (on a Mac)
rem    Linux:    bash build-linux.sh        (on a Linux machine)
rem
rem  Drop Mac/Linux files built elsewhere into the release-files\ folder —
rem  they get attached automatically (or use -Fetch to pull GitHub's CI build).
rem  Notes come from docs\releases\v<version>.md (first "# line" = title).
rem ==========================================================================
setlocal
cd /d "%~dp0"
title Where - release
rem A first argument like 0.4.0 or v0.4.0 is the version.
set "ARGS=%*"
echo(%~1| findstr /r "^v*[0-9][0-9.]*$" >nul && set "ARGS=-Version %*"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\make-release.ps1" %ARGS%
echo.
pause
