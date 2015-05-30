ISMINGW := $(shell uname | grep MINGW)
ifneq ($(ISMINGW),)
	EXT = .exe
else
	EXT = 
endif

CC = gcc -pedantic -Os -std=c99

all:  directories                 ../bin/TmxCompress$(EXT)  ../bin/Png2Rcs$(EXT)      \
      ../bin/step1$(EXT)          ../bin/step2$(EXT)        ../bin/step3$(EXT)        \
      ../bin/xm2tritone$(EXT)     ../bin/zx7b$(EXT)         ../bin/numbers4map$(EXT)  \
      ../bin/generate_table$(EXT) ../bin/GenTmx$(EXT)       ../bin/GenTape$(EXT)

directories:
	mkdir -p ../bin ../build

../bin/TmxCompress$(EXT): ../../ComplementosChurrera/CompresorMapas/TmxCompress.c
	$(CC) -o $@ $<
../bin/Png2Rcs$(EXT): ../../ComplementosChurrera/FiltroRCS/Png2Rcs.c
	$(CC) -o $@ $<
../bin/numbers4map$(EXT): numbers4map.c
	$(CC) -o $@ $<
	$@
../bin/generate_table$(EXT): generate_table.c
	$(CC) -o $@ $<
	$@
../bin/GenTape$(EXT): GenTape.c
	wget -O $< http://sourceforge.net/p/emuscriptoria/code/HEAD/tree/desprot/GenTape.c?format=raw
	$(CC) -o $@ $<
../bin/%$(EXT): %.c
	$(CC) -o $@ $<

clean:
	rm -f ../bin/*
