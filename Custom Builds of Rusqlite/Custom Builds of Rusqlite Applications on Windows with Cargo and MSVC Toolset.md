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




Because the official SQLite amalgamation release can be built relatively straightforwardly using the same Visual Studio C++ Build Tools toolchain, it makes a good starting point. The first part of the overall build process is to obtain a copy of 



 
## Standalone SQLite

To use a standalone SQLite library, execute

```cmd
{repo-root}> cargo build --example persons
or
{repo-root}> cargo build --example persons --features modern-full
```

Both should normally fail, with LINK complaining about not being able to open sqlite3.lib. To fix the issue, download, for example, the x64 "Precompiled Binaries for Windows"  current [release](https://sqlite.org/download.html) archive, containing sqlite3.dll and sqlite3.def files. The latter needs to be converted to sqlite3.lib using the MSBuild lib tool via the command:

```cmd
lib /DEF:sqlite3.def
```

The SQLITE3_LIB_DIR environment variable can be used to indicate the location of the generated file:

```cmd
(set SQLITE3_LIB_DIR={path-to-directory-with-sqlite3.lib}}) && cargo build --example persons
```

The attempt to run persons.exe should fail initially. Copy the SQLite3.dll file from the downloaded archive into the directory containing the compiled example and it should work fine afterwards.

