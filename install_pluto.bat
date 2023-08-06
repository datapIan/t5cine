@echo off
md "%localappdata%\Plutonium\storage\t5\mods"
xcopy /s "%cd%\mp_t5cine" "%localappdata%\Plutonium\storage\t5\mods\mp_t5cine\"
echo t5cine (pluto) installed successfully.
pause