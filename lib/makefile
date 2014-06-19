CC = gcc
TARGETS = lib/bin/numbers4map lib/bin/generate_table
TARGETS_INSTALL = lib/bin/tmxcompress lib/bin/png2rcs lib/bin/step1 lib/bin/step2 lib/bin/zx7b lib/bin/gentmx
CFLAGS = -std=c99 -static

all: prepare $(TARGETS) $(TARGETS_INSTALL)

lib/bin/tmxcompress: ComplementosChurrera/CompresorMapas/TmxCompress.c
	@ echo "compile: tmxcompress"
	@ $(CC) -o lib/bin/tmxcompress ComplementosChurrera/CompresorMapas/TmxCompress.c $(CFLAGS)
lib/bin/png2rcs: ComplementosChurrera/FiltroRCS/Png2Rcs.c
	@ echo "compile: png2rcs"
	@ $(CC) -o lib/bin/png2rcs ComplementosChurrera/FiltroRCS/Png2Rcs.c $(CFLAGS)
lib/bin/step1: lib/src/step1.c
	@ echo "compile: step1"
	@ $(CC) -o lib/bin/step1 lib/src/step1.c $(CFLAGS)
lib/bin/step2: lib/src/step2.c
	@ echo "compile: step2"
	@ $(CC) -o lib/bin/step2 lib/src/step2.c $(CFLAGS)
lib/bin/zx7b: lib/src/zx7b.c
	@ echo "compile: zx7b"
	@ $(CC) -o lib/bin/zx7b lib/src/zx7b.c $(CFLAGS)
lib/bin/numbers4map: lib/src/numbers4map.c
	@ echo "compile: numbers4map"
	@ $(CC) -o lib/bin/numbers4map lib/src/numbers4map.c $(CFLAGS)
	@ cp lib/numbers4map.png .
	@ lib/bin/numbers4map
	@ mv numbers4map.h lib/src/
	@ rm numbers4map.png
lib/bin/generate_table: lib/src/generate_table.c
	@ echo "compile: generate_table"
	@ $(CC) -o lib/bin/generate_table lib/src/generate_table.c $(CFLAGS)
	@ lib/bin/generate_table
	@ mv file1.bin lib/src/
lib/bin/gentmx: lib/src/GenTmx.c
	@ echo "compile: gentmx"
	@ $(CC) -o lib/bin/gentmx lib/src/GenTmx.c $(CFLAGS)

prepare:
	@ mkdir -p lib/bin/

install:
	@ cp $(TARGETS_INSTALL) lib/bin/ && echo "install: $(TARGETS_INSTALL)"

clean:
	@ rm $(TARGETS) $(TARGETS_INSTALL) lib/src/numbers4map.h && rm -rf lib/bin/* && echo "remove: $(TARGETS) $(TARGETS_INSTALL)"

