rem en el archivo setvars pongo las variables con las rutas necesarias
call setvars.bat
%dmc% ComplementosChurrera\CompresorMapas\TmxCompress.c
%dmc% ComplementosChurrera\FiltroRCS\Png2Rcs.c
%dmc% engine\step1.c
%dmc% engine\step2.c
%dmc% engine\zx7b.c
%dmc% engine\numbers4map.c
copy engine\numbers4map.png .
numbers4map.exe
move numbers4map.h engine
%dmc% engine\GenTmx.c
del numbers4map.exe numbers4map.png
move /Y TmxCompress.exe engine\util
move /Y Png2Rcs.exe engine\util
move /Y step1.exe engine\util
move /Y step2.exe engine\util
move /Y zx7b.exe engine\util
move /Y GenTmx.exe engine\util
del *.map *.obj
cd engine
util\SjAsmPlus dzx7b_rcs0.asm
util\SjAsmPlus dzx7b_rcs1.asm
call fase gfx
%z7z% a ..\FASE.0.13.zip ^
  fase.bat config.def readme.txt ^
  file1.bin file2.bin file3.bin ^
  util\GenTape.exe util\GenTmx.exe util\hex2bin.exe util\Png2Rcs.exe ^
  util\SjAsmPlus.exe util\step1.exe util\step2.exe util\TmxCompress.exe util\zx7b.exe^
  engine0.asm engine1.asm engine2.asm engine.asm loader.asm ^
  loading.png sprites.png tiles.png map.tmx ^
  main.c fase.h main.bas fase.bas
cd ..