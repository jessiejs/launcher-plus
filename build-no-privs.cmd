rmdir %PLAYDATE_SDK_PATH%\Disk\System\Launcher.pdx /s /q
%PLAYDATE_SDK_PATH%/bin/pdc ./src %PLAYDATE_SDK_PATH%/Disk/Games/Launcher.pdx
taskkill /f /im PlaydateSimulator.exe
%PLAYDATE_SDK_PATH%/bin/PlaydateSimulator %PLAYDATE_SDK_PATH%/Disk/Games/Launcher.pdx
