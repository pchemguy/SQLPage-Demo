@echo off


:: ================================ BEGIN MAIN ================================
:MAIN
SetLocal EnableExtensions EnableDelayedExpansion

set ERROR_STATUS=0

set BASEDIR=%~dp0
set BASEDIR=%BASEDIR:~0,-1%
set DISTRODIR=%BASEDIR%\sqlite

call :DOWNLOAD_SQLITE
if %ERROR_STATUS% NEQ 0 exit /b 1
call :EXTRACT_SQLITE
if %ERROR_STATUS% NEQ 0 exit /b 1
if not exist "%DISTRODIR%" (
  echo Distro directory does not exists. Exiting
  exit /b 1
)
call :BUILD_SQLITE
if %ERROR_STATUS% NEQ 0 exit /b 1

EndLocal
exit /b 0
:: ================================= END MAIN =================================


:: ============================================================================
:DOWNLOAD_SQLITE
set YEAR=2024
set VERSION=3460000
set DISTROFILE=sqlite.zip
set URL=https://sqlite.org/%YEAR%/sqlite-amalgamation-%VERSION%.zip

if not exist "%DISTROFILE%" (
  echo ===== Downloading current SQLite release =====
  curl %URL% --output "%DISTROFILE%"
  if %ErrorLevel% EQU 0 (
    echo ----- Downloaded  current SQLite release -----
  ) else (
    set ERROR_STATUS=%ErrorLevel%
    echo Error downloading SQLite distro.
    echo Errod code: !ERROR_STATUS!
  )
) else (
  echo ===== Using previously downloaded SQLite distro =====
)

exit /b %ERROR_STATUS%


:: ============================================================================
:EXTRACT_SQLITE
if not exist "%DISTRODIR%\sqlite3.c" (
  echo ===== Extracting SQLite distro =====
  tar -xf "%DISTROFILE%"
  if %ErrorLevel% EQU 0 (
    move "sqlite-amalgamation-%VERSION%" "%DISTRODIR%"
    echo ----- Extracted  SQLite distro -----
  ) else (
    set ERROR_STATUS=%ErrorLevel%
    echo Error extracting SQLite distro.
    echo Errod code: !ERROR_STATUS!
  )
) else (
  echo ===== Using previously extracted SQLite distro =====
)

exit /b %ERROR_STATUS%


:: ============================================================================
:BUILD_SQLITE
cd /d "%DISTRODIR%"

if not exist sqlite3.lo     (cl -O2 -c sqlite3.c -Fosqlite3.lo)
if not exist libsqlite3.lib (lib sqlite3.lo /OUT:libsqlite3.lib)
if not exist libsqlite3.dmp (dumpbin /ALL libsqlite3.lib /OUT:libsqlite3.dmp)

echo EXPORTS > sqlite3.def
set Command=findstr /XRB /C:"^ *1 sqlite[^ ]* *$" libsqlite3.dmp
for /f "Usebackq tokens=2 delims= " %%I in (`%Command%`) do (
    echo %%I
) 1>>sqlite3.def

lib  /MACHINE:x64 /DEF:sqlite3.def
link /MACHINE:x64 /DEF:sqlite3.def sqlite3.lo /DLL /OUT:sqlite3.dll

exit /b 0
