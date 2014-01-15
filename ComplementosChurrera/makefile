CC = gcc
TARGETS = bin2map gfxcnv gfxinv map2tmx png2rcs posterizezx tmxcnv tmxcompress
CFLAGS = -std=c99 -static

all: $(TARGETS)

bin2map: Bin2Map.c
  @ echo "compile: bin2map"
  @ $(CC) -o bin2map Bin2Map.c $(CFLAGS)
gfxcnv: GfxCnv.c
  @ echo "compile: gfxcnv"
  @ $(CC) -o gfxcnv GfxCnv.c lodepng.c $(CFLAGS)
gfxinv: GfxInv.c
  @ echo "compile: gfxinv"
  @ $(CC) -o gfxinv GfxInv.c lodepng.c $(CFLAGS)
map2tmx: Map2Tmx.c
  @ echo "compile: map2tmx"
  @ $(CC) -o map2tmx Map2Tmx.c $(CFLAGS)
png2rcs: Png2Rcs.c
  @ echo "compile: png2rcs"
  @ $(CC) -o png2rcs Png2Rcs.c lodepng.c $(CFLAGS)
posterizezx: PosterizeZX.c
  @ echo "compile: posterizezx"
  @ $(CC) -o posterizezx PosterizeZX.c lodepng.c $(CFLAGS)
tmxcnv: TmxCnv.c
  @ echo "compile: tmxcnv"
  @ $(CC) -o tmxcnv TmxCnv.c $(CFLAGS)
tmxcompress: TmxCompress.c
  @ echo "compile: tmxcompress"
  @ $(CC) -o tmxcompress TmxCompress.c lodepng.c $(CFLAGS)

clean:
  @ rm $(TARGETS) && echo "remove: $(TARGETS)"

