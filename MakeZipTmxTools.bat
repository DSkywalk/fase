rem en el archivo setvars pongo las variables con las rutas necesarias
call setvars.bat
copy ComplementosChurrera\CompresorMapas\TmxCompress.c .
%dmc% ComplementosChurrera\CompresorMapas\TmxCompress.c
copy ComplementosChurrera\Conversores\GfxCnv.c .
%dmc% ComplementosChurrera\Conversores\GfxCnv.c
copy ComplementosChurrera\Conversores\Map2Tmx.c .
%dmc% ComplementosChurrera\Conversores\Map2Tmx.c
copy ComplementosChurrera\Conversores\TmxCnv.c .
%dmc% ComplementosChurrera\Conversores\TmxCnv.c
copy ComplementosChurrera\FiltroRCS\Png2Rcs.c .
copy ComplementosChurrera\FiltroRCS\Png2Scr.bat .
%dmc% ComplementosChurrera\FiltroRCS\Png2Rcs.c
copy ComplementosChurrera\FiltroRCS\rcs.c .
%dmc% ComplementosChurrera\FiltroRCS\rcs.c
copy ComplementosChurrera\IngenieriaInversa\Bin2Map.c .
%dmc% ComplementosChurrera\IngenieriaInversa\Bin2Map.c
copy ComplementosChurrera\IngenieriaInversa\GfxInv.c .
%dmc% ComplementosChurrera\IngenieriaInversa\GfxInv.c
copy ComplementosChurrera\LimitaColores\PosterizeZX.c .
%dmc% ComplementosChurrera\LimitaColores\PosterizeZX.c
copy ComplementosChurrera\makefile .
%z7z% a TmxTools.1.13.zip  makefile ^
Bin2Map.c Bin2Map.exe ^
GfxCnv.c GfxCnv.exe ^
GfxInv.c GfxInv.exe ^
Map2Tmx.c Map2Tmx.exe ^
Png2Rcs.c Png2Rcs.exe Png2Scr.bat ^
PosterizeZX.c PosterizeZX.exe ^
rcs.c rcs.exe ^
TmxCnv.c TmxCnv.exe ^
TmxCompress.c TmxCompress.exe
del *.map *.obj *.exe *.c Png2Scr.bat makefile
