@echo off
setlocal
cd /d "%~dp0"
where msbuild >nul 2>nul
if errorlevel 1 (
 echo Abra este archivo desde Developer Command Prompt for VS 2022 o 2026.
 exit /b 1
)
msbuild StellaBlu_U3.vcxproj /p:Configuration=Debug /p:Platform=Win32
exit /b %errorlevel%
