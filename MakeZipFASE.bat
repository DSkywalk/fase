rem rutas necesarias
set z7z= \zz\7-zip\7z
cd engine
call fase gfx
del /q build\*.*
%z7z% a ..\FASE.1.06.zip  ^
  .htaccess               ^
  config.def              ^
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
  asm\player.asm          ^
  asm\loader.asm          ^
  asm\music.asm           ^
  gfx\bullet.png          ^
  gfx\digits.png          ^
  "gfx\dos ter.png"       ^
  gfx\ending.png          ^
  gfx\ending.jpg          ^
  gfx\loading.png         ^
  gfx\map.tmx             ^
  gfx\screen.def          ^
  gfx\sprites.png         ^
  gfx\tiles.png           ^
  gfx\title.png           ^
  "gfx\un ter.png"        ^
  bin\GenTape.exe     ^
  bin\GenTmx.exe      ^
  bin\Png2Rcs.exe     ^
  bin\SjAsmPlus.exe   ^
  bin\step1.exe       ^
  bin\step2.exe       ^
  bin\step3.exe       ^
  bin\TmxCompress.exe ^
  bin\xm2tritone.exe  ^
  bin\zx7b.exe        ^
  mus\effx.asm            ^
  mus\list.asm            ^
  mus\music.xm            ^
  mus\song.mus.asm        ^
  mus\song0.mus           ^
  mus\song1.mus
cd ..
