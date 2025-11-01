@echo off
color 0B
cls

echo.
echo   +-------------------------------------------+
echo   ^|                                           ^|
echo   ^|        Starting OBS Studio...             ^|
echo   ^|                                           ^|
echo   +-------------------------------------------+
echo.

TIMEOUT 15

start /d "S:\Portable\scoop\apps\obs-studio\current\bin\64bit" obs64.exe --startreplaybuffer --minimize-to-tray --disable-updater

echo  OBS Studio launched successfully
echo.
pause >nul

exit /b