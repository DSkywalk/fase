@echo off
if not exist zxb\zxb.exe (
  echo.
  echo Error: You need ZX Basic installed into the zxb folder.
  exit /b 1
)
if "%1"=="gfx" (
  lib\bin\Png2Rcs gfx\loading.png build\loading.rcs build\loading.atr
  lib\bin\zx7b build\loading.rcs build\loading.rcs.zx7b
  lib\bin\zx7b build\loading.atr build\loading.atr.zx7b
rem  lib\bin\GenTmx 3 3 10 10 gfx\map.tmx
  lib\bin\TmxCompress gfx\map.tmx build\map_compressed.bin > build\defmap.asm
  lib\bin\sjasmplus asm\player.asm > nul
  lib\bin\zx7b build\player.bin build\player.zx7b
  lib\bin\xm2tritone mus\music.xm build\music.asm
  lib\bin\step1
  lib\bin\sjasmplus asm\music.asm > nul
  lib\bin\zx7b build\music.bin build\music.zx7b
  goto cont
)
if "%1"=="config" (
:cont
  lib\bin\sjasmplus asm\engine0.asm > nul
  lib\bin\sjasmplus asm\engine1.asm > nul
  lib\bin\sjasmplus asm\engine2.asm > nul
  lib\bin\step2
  lib\bin\zx7b build\block1.bin build\block1.zx7b
  lib\bin\zx7b build\block2.bin build\block2.zx7b
)
echo.
zxb\zxb main.bas -S 32772 -o build\main.bin
echo File main.bin compiled from main.bas
lib\bin\zx7b build\main.bin build\main.zx7b
lib\bin\step3
lib\bin\sjasmplus asm\loader.asm
if exist build\player.zx7b (
  lib\bin\gentape game.tzx                    ^
            basic 'game' 0  build\loader.bin  ^
             data           build\engine.zx7b ^
           stop48                             ^
             data           build\player.zx7b
) else (
  lib\bin\gentape game.tzx                    ^
            basic 'game' 0  build\loader.bin  ^
             data           build\engine.zx7b
)
