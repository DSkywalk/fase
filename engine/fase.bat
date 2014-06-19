@echo off
SETLOCAL
if "%1"=="gfx" (
  ..\lib\bin\Png2Rcs gfx\loading.png build\loading.rcs
  ..\lib\bin\zx7b build\loading.rcs build\loading.rcs.zx7b
rem  ..\lib\bin\GenTmx 3 3 10 10 gfx\map.tmx
  ..\lib\bin\TmxCompress gfx\map.tmx build\map_compressed.bin > build\defmap.asm
  ..\lib\bin\step1
  goto cont
)
if "%1"=="config" (
:cont
  ..\lib\bin\sjasmplus src\engine0.asm > nul
  ..\lib\bin\sjasmplus src\engine1.asm > nul
  ..\lib\bin\sjasmplus src\engine2.asm > nul
  ..\lib\bin\step2
  ..\lib\bin\zx7b build\block.bin build\block.zx7b
)
echo.
call z88dkenv.bat
zcc +zx -O3 -vn main.c -o build\main.bin -lndos
echo File main.bin compiled from main.c
..\lib\bin\zx7b build\main.bin build\main.zx7b
echo.
copy /b build\map_compressed.bin+build\main.zx7b+build\block.zx7b build\engine.zx7b > nul
echo File engine.zx7b joined from map_compressed.bin, main.zx7b and block.zx7b
echo.
copy build\defload.asm build\ndefload.asm > nul
for /f %%i in ("build\engine.zx7b") do echo         DEFINE  engicm  %%~zi >> build\ndefload.asm
for /f %%i in ("build\main.zx7b")   do echo         DEFINE  maincm  %%~zi >> build\ndefload.asm
for /f %%i in ("build\main.bin")    do echo         DEFINE  mainrw  %%~zi >> build\ndefload.asm
..\lib\bin\sjasmplus src\loader.asm
..\lib\bin\gentape game.tap           ^
    basic 'game' 0  build\loader.bin  ^
     data           build\engine.zx7b
ENDLOCAL