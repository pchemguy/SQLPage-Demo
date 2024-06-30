# How to build Rust Rusqlite applications linking against custom SQLite builds on Windows?

I am new to Rust and Rusqlite, but I would like to use a custom-built SQLite library with Rusqlite bindings while building a Rust-coded database application. I am interested in both dynamic and static linking options. The Rusqlite README states that linking to SQLite is complicated on Windows and indicates that linking is possible via a vcpkg package, but does not provide any further instructions (and I do not want to use vcpkg or any other "helper" anyway).

The official Rust website [suggests](https://rust-lang.org/tools/install) (when opened from a Windows machine) using Rust toolset together with the  Visual Studio C++ Build Tools, which I have, as the default building environment. Rusqlite includes one example, "persons", which can be built via:

```cmd
{repo-root}> cargo build --example persons --features bundled
or
{repo-root}> cargo build --example persons --features bundled-full
```

I was able to build the "persons" example and run it successfully. I was also able to make and build other simple examples via the same commands. These commands create a statically linked executable "persons.exe" in the "{repo root}\\target\\debug\\examples" directory using the copy of SQLite included with the library.

Commands

```cmd
{repo-root}> cargo build --example persons
and
{repo-root}> cargo build --example persons --features modern-full
```

expectedly fail the linking process due to missing sqlite3.lib. Specific instructions on how to proceed from here and what options are available would be helpful. 

# Answer

Rusqlite repository includes a copy of SQLite [amalgamation file](https://sqlite.org/amalgamation.html) (sqlite3.c) and the associated header file (sqlite3.h) inside the "{repo-root}\\libsqlite3-sys" directory. Perhaps the simplest starting for testing dynamic linking is to download x64 ["Precompiled Binaries for Windows"](https://sqlite.org/download.html#win32) and use it with the Rusqlite project.

### Precompiled SQLite binary

Download the archive and extract it into "sqlite" directory placed next to the "rusqlite" directory, containing a cloned/downloaded copy of the Rusqlite repository. The "sqlite" directory should contain two files, sqlite3.dll and sqlite3.def. The sqlite3.lib file necessary for the linker can be generated from these two files. Open a "cmd" console with building (Rust/MSBuild) environment set, change into the "sqlite" directory and execute command:

```bat
...sqlite> lib /MACHINE:x64 /DEF:sqlite3.def
```

which should create two new files, including sqlite3.lib. Now change into "rusqlite" directory, `cd ..\rusqlite`. The location of "sqlite3.lib" can be passed to the linker via the `SQLITE3_LIB_DIR` environment variable. Executing

```bat
...rusqlite> (set "SQLITE3_LIB_DIR=..\sqlite") && cargo build --example persons
or
...rusqlite> (set "SQLITE3_LIB_DIR=..\sqlite") && cargo build --example persons --features modern-full
```

should complete successfully and generate  "persons.exe" in the "{repo root}\\target\\debug\\examples". There are several possible ways to verify the result before executing it. For example, the [Far Manager](https://farmanager.com/index.php?l=en) has the [ImpEx](https://github.com/Maximus5/FarPlugins/tree/master/ImpEx) plugin (also available from [Far PlugRing](https://plugring.farmanager.com/plugin.php?pid=790)) that provides a convenient access to executable metadata. The list of top-level items seen in ImpEx for "persons.exe" should contain the "64BIT" file-like item and the "Imports Table" directory, among other things. Opening the latter should list several directory-like items named after the imported DLL files, including one for sqlite3.dll.

![](https://raw.github.com/pchemguy/SQLPage-Demo/main/Custom%20Builds%20of%20Rusqlite/img/Far-ImpEx-Top.png)

![](https://raw.github.com/pchemguy/SQLPage-Demo/main/Custom%20Builds%20of%20Rusqlite/img/Far-ImpEx-Imports.png)

Also note that the size of the new persons.exe executable is significantly smaller, as it no longer integrates the SQLite library code. Now copy the sqlite3.dll file inside the directory containing persons.exe, for example:

```bat
...rusqlite> cd target\debug\examples
...examples> copy /Y ..\..\..\..\sqlite\sqlite3.dll .
```

and run persons.exe, which should now produce the output as before.

### Build SQLite from source

One step further would be to build the SQLite library from the official amalgamation release. Remove the previously created "sqlite" directory and instead create the sqlite_MSVC_Cpp_Build_Tools_Demo.bat script with the following content:

```bat
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
```

The script is relatively small and is split into functional blocks, so I will not go over it (follow the code for further details). When executed, the script downloads a copy of SQLite [amalgamation](https://sqlite.org/amalgamation.html) release, expands it, and builds it (MSBuild environment should be activated as before). It creates the "sqlite" directory, which will contain several files, including sqlite3.dll and sqlite3.lib, which can be used as before. This process can be used to link the the application dynamically against custom-built SQLite, which might integrate additional extensions, such as ICU (see, for example, this [project](https://pchemguy.github.io/SQLite-ICU-MinGW/repo-scripts), which focuses on the MinGW toolchain, but also discusses the MSBuild environment and provides custom build scripts).

## Embedding custom SQLite - hacking into the Rusqlite build process

This is, perhaps the most complicated part, and its primary goal is more of exploratory nature, rather than a recipe for routine use. When one of the "bundled" building options is used, the Cargo-controlled Rusqlite build process compiles the sqlite3.c amalgamation file included in the "libsqlite3-sys\\sqlite3" directory of the Rusqlite repository. This amalgamation file may, in principle, be replaced with a custom copy, but that is the easy part. Because SQLite build process is controlled during build time via compiler options, passing these options to the C compiler invoked by Cargo is the essential (unless you want to deal with Rust build script ("libsqlite3-sys\\build.rs") which is beyond this exploratory). The script "libsqlite3-sys\\build.rs" does accept SQLite "-Dxx" configuration parameters via the "LIBSQLITE3_FLAGS" environment variable, but it will reject other kinds of options in this variable, such as include options. More over, there are also linking options, which may need to be passed somehow.

For example, I have another script (or scripts, some available via from the associated [repository](https://pchemguy.github.io/SQLite-ICU-MinGW/) and more recent MSVC script available {here]())

