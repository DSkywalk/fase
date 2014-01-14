@echo off
rem chcp 65001
SETLOCAL
call c:\z88dk10\setenv.bat
set nombre=Dogmole
set pantallas=24
set bordecarga=0
set prod=0
:parse
if "%1"=="" goto endparse
if "%1"=="script" (
  echo ### COMPILANDO SCRIPT ###
  ..\utils\msc ..\script\%nombre%.spt msc.h %pantallas%
)
if "%1"=="post" (
  echo -------------------------------------------------------------------------------
  echo ### AJUSTANDO COLORES ###
  ..\utils\PosterizeZX ..\gfx\title.png ..\gfx\title.png
  ..\utils\PosterizeZX ..\gfx\ending.png ..\gfx\ending.png
  ..\utils\PosterizeZX ..\gfx\loading.png ..\gfx\loading.png
  ..\utils\PosterizeZX ..\gfx\chars.png ..\gfx\chars.png
  ..\utils\PosterizeZX ..\gfx\tiles.png ..\gfx\tiles.png
  ..\utils\PosterizeZX ..\gfx\sprites.png ..\gfx\sprites.png
)
if "%1"=="pant" (
  echo -------------------------------------------------------------------------------
  echo ### COMPRIMIENDO PANTALLAS ###
  ..\utils\Png2Rcs ..\gfx\title.png title.rcs
  ..\utils\Png2Rcs ..\gfx\ending.png ending.rcs
  ..\utils\Png2Rcs ..\gfx\loading.png loading.rcs
  del title.bin ending.bin loading.bin
  ..\utils\zx7 title.rcs title.bin
  ..\utils\zx7 ending.rcs ending.bin
  ..\utils\zx7 loading.rcs loading.bin
  del title.rcs ending.rcs loading.rcs
)
if "%1"=="graf" (
  echo -------------------------------------------------------------------------------
  echo ### GENERANDO MAPA Y GRÁFICOS ###
  ..\utils\TmxCompress ..\map\mapa.tmx mapa_comprimido.bin
  ..\utils\GfxCnv ..\gfx\chars.png ..\gfx\tiles.png ..\gfx\sprites.png tileset.h sprites.h
  ..\utils\TmxCnv ..\map\mapa.tmx mapa.h enems.h
)
if "%1"=="prod" (
  set prod=1
)
shift
goto parse
:endparse
echo -------------------------------------------------------------------------------
echo ### COMPILANDO GÜEGO ###
zcc +zx -vn %nombre%.c -o game.bin -lndos -lsplib2 -zorg=24200
for /f %%i in ("game.bin") do set /a resta= 36454-%%~zi
if %resta% gtr 1000 ( echo Te quedan %resta% bytes, sigue churreando que vas sobrao
) else if %resta% gtr 50 ( echo Te quedan %resta% bytes, churrea más despacio que te quedas sin harina
) else if %resta% gtr 0 ( echo Te quedan %resta% bytes, tus sobacos se están descriogenizando
) else if %resta% equ 0 ( echo Te quedan %resta% bytes, se acabó, game over, tómate un palote de sandía
) else ( echo Te faltan %resta% bytes, te has pasao, retrocede antes de que Vah-ka te maldiga
)
echo -------------------------------------------------------------------------------
if %prod%==1 (
  echo ### CONSTRUYENDO CINTA ###
  ..\utils\zx7 game.bin game.zx7
  for /f %%i in ("game.zx7") do echo  define COMP_SIZE %%~zi > define.asm
  echo  define BORDER_LOADING %bordecarga% >> define.asm
  ..\utils\SjAsmPlus asmloader.asm
  call :generatape tap
  call :generatape tzx
  call :generatape wav
  del game.bin game.zx7 define.asm asmloader.bin
) else (
  echo ### CONSTRUYENDO SNAPSHOT ###
  ..\utils\SjAsmPlus generatesna.asm
  del game.bin
  game.sna
)
echo -------------------------------------------------------------------------------
echo ### DONE ###
goto :eof

:generatape
  ..\utils\GenTape %nombre%.%1          ^
      basic '%nombre%'  0 asmloader.bin ^
      data                game.zx7
goto :eof