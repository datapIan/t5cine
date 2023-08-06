@echo off
set gamepath=G:\SteamLibrary\steamapps\common\Call of Duty Black Ops
cd /D %LOCALAPPDATA%\Plutonium
start /wait /abovenormal bin\plutonium-bootstrapper-win32.exe t5mp "%gamepath%" -lan +set developer 1 +name "name" +set fs_game "mods/mp_t5cine" 