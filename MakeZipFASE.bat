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
del /q build\*.*
cd ..
%z7z% a FASE.1.03.zip       ^
  engine\config.def         ^
  engine\ending.rcs.zx7b    ^
  engine\fase.h             ^
  engine\fase.bas           ^
  engine\fase.bat           ^
  engine\game.tap           ^
  engine\main.c             ^
  engine\main.bas           ^
  engine\build              ^
  engine\doc\help1.png      ^
  engine\doc\help2.png      ^
  engine\doc\readme.html    ^
  engine\src\file1.bin      ^
  engine\src\dzx7b_rcs.asm  ^
  engine\src\engine.asm     ^
  engine\src\engine0.asm    ^
  engine\src\engine1.asm    ^
  engine\src\engine2.asm    ^
  engine\src\loader.asm     ^
  engine\gfx\bullet.png     ^
  engine\gfx\loading.png    ^
  engine\gfx\map.tmx        ^
  engine\gfx\sprites.png    ^
  engine\gfx\tiles.png      ^
  lib\bin\GenTape.exe       ^
  lib\bin\GenTmx.exe        ^
  lib\bin\Png2Rcs.exe       ^
  lib\bin\SjAsmPlus.exe     ^
  lib\bin\step1.exe         ^
  lib\bin\step2.exe         ^
  lib\bin\TmxCompress.exe   ^
  lib\bin\zx7b.exe
