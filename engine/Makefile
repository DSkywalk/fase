# zxb-> Boriel ZX Basic Compiler. zcc-> z88dk C compiler
COMPILER = zxb
ZCCPATH = /c/z88dk

ifneq ("$(wildcard asm/player.asm)","")
	PLAYER_EXISTS = 1
else
	PLAYER_EXISTS = 0
endif
export Z80_OZFILES=${ZCCPATH}/lib/
export ZCCCFG     =${ZCCPATH}/lib/config/
export PATH=$PATH:${ZCCPATH}/bin
export TEMP=build

all: game.tzx

clean:
	/bin/rm -f build/*

build/loading.rcs:
	bin/Png2Rcs gfx/loading.png build/loading.rcs build/loading.atr
  
build/loading.rcs.zx7b: build/loading.rcs
	bin/zx7b build/loading.atr build/loading.atr.zx7b
	bin/zx7b build/loading.rcs build/loading.rcs.zx7b

build/map_compressed.bin: gfx/map.tmx
	bin/TmxCompress gfx/map.tmx build/map_compressed.bin > build/defmap.asm
  
build/player.bin: asm/player.asm mus/list.asm
	bin/sjasmplus asm/player.asm
	bin/zx7b build/player.bin build/player.zx7b

build/music.asm: mus/music.xm
	bin/xm2tritone mus/music.xm build/music.asm

build/define.asm: config.def gfx/screen.def build/player.bin #gfx/tiles.atr 
	bin/step1

build/music.zx7b: build/music.asm build/define.asm
	bin/sjasmplus asm/music.asm > nul
	bin/zx7b build/music.bin build/music.zx7b

build/defload.asm: config.def build/player.bin build/music.bin build/tiles.bin build/bullet.bin build/map_compressed.bin build/screen.bin build/sprites.bin
	bin/sjasmplus asm/engine0.asm > nul
	bin/sjasmplus asm/engine1.asm > nul
	bin/sjasmplus asm/engine2.asm > nul
	bin/step2

build/ndefload.asm: build/defload.asm
	bin/zx7b build/block1.bin build/block1.zx7b
	bin/zx7b build/block2.bin build/block2.zx7b

build/main.bin: main.bas build/defload.asm
ifeq ($(COMPILER),zxb)
	zxb/zxb main.bas -S 32772 -o build/main.bin
else
	zcc +zx -zorg=32772 -O3 -vn main.c -o build\main.bin -lndos
endif
	bin/zx7b build/main.bin build/main.zx7b

build/loader.bin: build/music.zx7b build/screen.bin build/main.bin build/map_compressed.bin build/defload.asm asm/loader.asm asm/engine.asm build/ndefload.asm build/define.asm build/loading.rcs.zx7b asm/dzx7b_rcs.asm
	bin/step3
	bin/sjasmplus asm/loader.asm

game.tzx: build/loader.bin build/engine.zx7b
ifeq ($(PLAYER_EXISTS),1)
	bin/gentape game.tzx                  \
        basic game 0  build/loader.bin  \
         data         build/engine.zx7b \
       stop48                           \
         data         build/player.zx7b
else
	bin/gentape game.tzx                  \
        basic game 0  build/loader.bin  \
         data         build/engine.zx7b
endif
