CC = gcc
TARGETS = bin2map gfxcnv gfxinv map2tmx png2rcs rcs png2scr posterizezx tmxcnv tmxcompress
CFLAGS = -std=c99 -static

all: $(TARGETS)

bin2map: IngenieriaInversa/Bin2Map.c
	@ echo "compile: bin2map"
	@ $(CC) -o bin2map IngenieriaInversa/Bin2Map.c $(CFLAGS)
gfxcnv: Conversores/GfxCnv.c
	@ echo "compile: gfxcnv"
	@ $(CC) -o gfxcnv Conversores/GfxCnv.c $(CFLAGS)
gfxinv: IngenieriaInversa/GfxInv.c
	@ echo "compile: gfxinv"
	@ $(CC) -o gfxinv IngenieriaInversa/GfxInv.c $(CFLAGS)
map2tmx: Conversores/Map2Tmx.c
	@ echo "compile: map2tmx"
	@ $(CC) -o map2tmx Conversores/Map2Tmx.c $(CFLAGS)
rcs: FiltroRCS/rcs.c
	@ echo "compile: rcs"
	@ $(CC) -o rcs FiltroRCS/rcs.c $(CFLAGS)
png2rcs: FiltroRCS/Png2Rcs.c
	@ echo "compile: png2rcs"
	@ $(CC) -o png2rcs FiltroRCS/Png2Rcs.c $(CFLAGS)
png2scr: FiltroRCS/Png2Scr.c
	@ echo "compile: png2rcs"
	@ $(CC) -o png2scr FiltroRCS/Png2Scr.c $(CFLAGS)
posterizezx: LimitaColores/PosterizeZX.c
	@ echo "compile: posterizezx"
	@ $(CC) -o posterizezx LimitaColores/PosterizeZX.c $(CFLAGS)
tmxcnv: Conversores/TmxCnv.c
	@ echo "compile: tmxcnv"
	@ $(CC) -o tmxcnv Conversores/TmxCnv.c $(CFLAGS)
tmxcompress: CompresorMapas/TmxCompress.c
	@ echo "compile: tmxcompress"
	@ $(CC) -o tmxcompress CompresorMapas/TmxCompress.c $(CFLAGS)

clean:
	@ rm $(TARGETS) && echo "remove: $(TARGETS)"

