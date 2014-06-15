CC = gcc
TARGETS = numbers4map generate_table
TARGETS_INSTALL = tmxcompress png2rcs step1 step2 zx7b gentmx
CFLAGS = -std=c99 -static

all: $(TARGETS) $(TARGETS_INSTALL)

tmxcompress: ComplementosChurrera/CompresorMapas/TmxCompress.c
	@ echo "compile: tmxcompress"
	@ $(CC) -o tmxcompress ComplementosChurrera/CompresorMapas/TmxCompress.c $(CFLAGS)
png2rcs: ComplementosChurrera/FiltroRCS/Png2Rcs.c
	@ echo "compile: png2rcs"
	@ $(CC) -o png2rcs ComplementosChurrera/FiltroRCS/Png2Rcs.c $(CFLAGS)
step1: engine/step1.c
	@ echo "compile: step1"
	@ $(CC) -o step1 engine/step1.c $(CFLAGS)
step2: engine/step2.c
	@ echo "compile: step2"
	@ $(CC) -ggdb -o step2 engine/step2.c $(CFLAGS)
zx7b: engine/zx7b.c
	@ echo "compile: zx7b"
	@ $(CC) -o zx7b engine/zx7b.c $(CFLAGS)
numbers4map: engine/numbers4map.c
	@ echo "compile: numbers4map"
	@ $(CC) -o numbers4map engine/numbers4map.c $(CFLAGS)
	@ cp engine/numbers4map.png .
	@ ./numbers4map
	@ mv numbers4map.h engine/
generate_table: engine/generate_table.c
	@ echo "compile: generate_table"
	@ $(CC) -o generate_table engine/generate_table.c $(CFLAGS)
	@ ./generate_table
	@ mv file1.bin engine/
gentmx: engine/GenTmx.c
	@ echo "compile: gentmx"
	@ $(CC) -o gentmx engine/GenTmx.c $(CFLAGS)

install:
	@ mkdir -p engine/util
	@ cp $(TARGETS_INSTALL) engine/util/ && echo "install: $(TARGETS_INSTALL)"

clean:
	@ rm $(TARGETS) $(TARGETS_INSTALL) engine/numbers4map.h engine/file1.bin numbers4map.png && rm -rf engine/util && echo "remove: $(TARGETS) $(TARGETS_INSTALL)"

