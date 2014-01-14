SETLOCAL
set _lang=c
if "%1"=="gfx" (
  util\Png2Rcs loading.png loading.rcs
  util\zx7b loading.rcs loading.zx7
  util\GenTmx 3 3 10 10 map.tmx
  util\TmxCompress map.tmx map_compressed.bin > defmap.asm
  util\step1
  goto cont
)
if "%1"=="config" (
:cont
  util\sjasmplus engine0.asm
  util\sjasmplus engine1.asm
  util\sjasmplus engine2.asm
  util\step2
  util\zx7b block.bin block.zx7
)
if %_lang%==c (
  sdcc -mz80 --no-std-crt0 --code-loc 0x8000 main.c
  util\hex2bin -p 00 main.ihx
) else (
  zxb main.bas
)
util\zx7b main.bin main.zx7
copy /b map_compressed.bin+main.zx7+block.zx7 engine.zx7
copy defload.asm ndefload.asm
for /f %%i in ("engine.zx7") do echo  define engcomp_size %%~zi >> ndefload.asm
for /f %%i in ("main.zx7") do echo  define maincomp_size %%~zi >> ndefload.asm
for /f %%i in ("main.bin") do echo  define main_size %%~zi >> ndefload.asm
util\sjasmplus loader.asm
util\gentape game.tap           ^
    basic 'game' 0  loader.bin  ^
     data           engine.zx7
ENDLOCAL