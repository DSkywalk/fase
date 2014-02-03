@echo off
SETLOCAL
set _lang=c
if "%1"=="gfx" (
  util\Png2Rcs loading.png loading.rcs
  util\zx7b loading.rcs loading.zx7b
rem  util\GenTmx 3 3 10 10 map.tmx
  util\TmxCompress map.tmx map_compressed.bin > defmap.asm
  util\step1
  goto cont
)
if "%1"=="config" (
:cont
  util\sjasmplus engine0.asm > nul
  util\sjasmplus engine1.asm > nul
  util\sjasmplus engine2.asm > nul
  util\step2
  util\zx7b block.bin block.zx7b
  sdasz80 -o lib.s
)
if %_lang%==c (
  echo.
  sdcc -mz80 --no-std-crt0 --code-loc 0x8000 --data-loc 0xa000 main.c lib.rel
  echo File main.bin compiled from main.c
  util\hex2bin -p 00 main.ihx > nul
) else (
  echo.
  zxb\zxb main.bas
  echo File main.bin compiled from main.bas
)
util\zx7b main.bin main.zx7b
echo.
copy /b map_compressed.bin+main.zx7b+block.zx7b engine.zx7b > nul
echo File engine.zx7b joined from map_compressed.bin, main.zx7b and block.zx7b
echo.
copy defload.asm ndefload.asm > nul
for /f %%i in ("engine.zx7b") do echo         DEFINE  engicm  %%~zi >> ndefload.asm
for /f %%i in ("main.zx7b") do echo         DEFINE  maincm  %%~zi >> ndefload.asm
for /f %%i in ("main.bin") do echo         DEFINE  mainrw  %%~zi >> ndefload.asm
util\sjasmplus loader.asm
util\gentape game.tap           ^
    basic 'game' 0  loader.bin  ^
     data           engine.zx7b
ENDLOCAL