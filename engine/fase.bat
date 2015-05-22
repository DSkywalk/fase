@echo off
if not exist z88dkenv.bat (
  echo.
  echo Error: z88dkenv.bat doesn't exist. Please copy it into this folder.
  exit /b 1
)
if "%1"=="gfx" (
  bin\Png2Rcs gfx\loading.png build\loading.rcs build\loading.atr
  bin\zx7b build\loading.rcs build\loading.rcs.zx7b
  bin\zx7b build\loading.atr build\loading.atr.zx7b
rem  bin\GenTmx 3 3 10 10 gfx\map.tmx
  bin\TmxCompress gfx\map.tmx build\map_compressed.bin > build\defmap.asm
  bin\sjasmplus asm\player.asm > nul
  bin\zx7b build\player.bin build\player.zx7b
  bin\xm2tritone mus\music.xm build\music.asm
  bin\step1
  bin\sjasmplus asm\music.asm > nul
  bin\zx7b build\music.bin build\music.zx7b
  goto cont
)
if "%1"=="config" (
:cont
  bin\sjasmplus asm\engine0.asm > nul
  bin\sjasmplus asm\engine1.asm > nul
  bin\sjasmplus asm\engine2.asm > nul
  bin\step2
  bin\zx7b build\block1.bin build\block1.zx7b
  bin\zx7b build\block2.bin build\block2.zx7b
)
echo.
call z88dkenv.bat
zcc +zx -zorg=32772 -O3 -vn main.c -o build\main.bin -lndos
echo File main.bin compiled from main.c
bin\zx7b build\main.bin build\main.zx7b
bin\step3
bin\sjasmplus asm\loader.asm
if exist build\player.zx7b (
  bin\gentape game.tzx                  ^
        basic game 0  build\loader.bin  ^
         data         build\engine.zx7b ^
       stop48                           ^
         data         build\player.zx7b
) else (
  bin\gentape game.tzx                  ^
        basic game 0  build\loader.bin  ^
         data         build\engine.zx7b
)
