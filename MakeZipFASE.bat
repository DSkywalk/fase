rem en el archivo setvars pongo las variables con las rutas necesarias
call setvars.bat
%dmc% ComplementosChurrera\CompresorMapas\TmxCompress.c -oengine\lib\bin\TmxCompress.exe
%dmc% ComplementosChurrera\FiltroRCS\Png2Rcs.c          -oengine\lib\bin\Png2Rcs.exe
%dmc% engine\lib\src\step1.c           -oengine\lib\bin\step1.exe
%dmc% engine\lib\src\step2.c           -oengine\lib\bin\step2.exe
%dmc% engine\lib\src\zx7b.c            -oengine\lib\bin\zx7b.exe
%dmc% engine\lib\src\numbers4map.c
%dmc% engine\lib\src\generate_table.c

numbers4map.exe
generate_table.exe
move file1.bin engine\asm
move numbers4map.h engine\lib\src
%dmc% engine\lib\src\GenTmx.c          -oengine\lib\bin\GenTmx.exe
del numbers4map.exe generate_table.exe
del *.map *.obj
cd engine
call fase gfx
rem del /q build\*.*
%z7z% a ..\FASE.1.03.zip  ^
  .htaccess               ^
  config.def              ^
  ending.rcs.zx7b         ^
  fase.h                  ^
  fase.bas                ^
  fase.bat                ^
  faseb.bat               ^
  game.html               ^
  game.js                 ^
  game.tzx                ^
  main.c                  ^
  main.bas                ^
  build                   ^
  doc\help1.png           ^
  doc\help2.png           ^
  doc\readme.html         ^
  asm\file1.bin           ^
  asm\dzx7b_rcs.asm       ^
  asm\engine.asm          ^
  asm\engine0.asm         ^
  asm\engine1.asm         ^
  asm\engine2.asm         ^
  asm\loader.asm          ^
  gfx\bullet.png          ^
  gfx\digits.png          ^
  gfx\ending.jpg          ^
  gfx\loading.png         ^
  gfx\map.tmx             ^
  gfx\sprites.png         ^
  gfx\tiles.png           ^
  lib\bin\GenTape.exe     ^
  lib\bin\GenTmx.exe      ^
  lib\bin\Png2Rcs.exe     ^
  lib\bin\SjAsmPlus.exe   ^
  lib\bin\step1.exe       ^
  lib\bin\step2.exe       ^
  lib\bin\TmxCompress.exe ^
  lib\bin\zx7b.exe
cd ..