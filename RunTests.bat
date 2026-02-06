@echo off
setlocal

if not defined LUA_DIR set LUA_DIR=C:\Tools\Dev\lua

set LUA_PATH=Tests\?.lua;Tests\Unit\?.lua;Tests\Integration\?.lua;Tests\Support\?.lua;Tests\Support\Mocks\?.lua;%LUA_DIR%\?.lua;%LUA_DIR%\luacov\src\?.lua;;
set PATH=%LUA_DIR%\lua51;%PATH%

if exist luacov.stats.out del /q luacov.stats.out
if exist luacov.report.out del /q luacov.report.out

echo Running tests...
lua5.1.exe Tests\RunTests.lua
if %errorlevel% neq 0 exit /b %errorlevel%

echo Generating coverage report...
lua5.1.exe %LUA_DIR%\luacov\src\bin\luacov >nul 2>&1

echo Checking coverage...
lua5.1.exe Tests\Support\CheckCoverage.lua
if %errorlevel% neq 0 exit /b %errorlevel%

exit /b 0
