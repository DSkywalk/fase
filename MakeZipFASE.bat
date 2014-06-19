rem en el archivo setvars pongo las variables con las rutas necesarias
call setvars.bat
%dmc% ComplementosChurrera\CompresorMapas\TmxCompress.c -olib\bin\TmxCompress.exe
%dmc% ComplementosChurrera\FiltroRCS\Png2Rcs.c          -olib\bin\Png2Rcs.exe
%dmc% lib\src\step1.c           -olib\bin\step1.exe
%dmc% lib\src\step2.c           -olib\bin\step2.exe
%dmc% lib\src\zx7b.c            -olib\bin\zx7b.exe
%dmc% lib\src\numbers4map.c
%dmc% lib\src\generate_table.c
numbers4map.exe
generate_table.exe
move file1.bin engine\src
move numbers4map.h lib\src
%dmc% lib\src\GenTmx.c          -olib\bin\GenTmx.exe
del numbers4map.exe generate_table.exe
del *.map *.obj
cd engine
call fase gfx
rem %z7z% a ..\FASE.1.01.zip ^
rem   fase.bat config.def readme.html help1.png help2.png file1.bin ^
rem   util\GenTape.exe util\GenTmx.exe util\hex2bin.exe util\Png2Rcs.exe ^
rem   util\SjAsmPlus.exe util\step1.exe util\step2.exe util\TmxCompress.exe util\zx7b.exe ^
rem   engine0.asm engine1.asm engine2.asm engine.asm loader.asm dzx7b_rcs.asm ^
rem   loading.png sprites.png tiles.png bullet.png map.tmx ^
rem   main.c main.bas fase.h fase.bas ending.h ending.rcs.zx7b ^
rem   zxb
cd ..