CC = gcc -pedantic -Os -std=c99

all:  bin/TmxCompress bin/Png2Rcs bin/step1 bin/step2 bin/step3 \
      bin/zx7b bin/numbers4map bin/generate_table bin/GenTmx

bin/TmxCompress: ../../ComplementosChurrera/CompresorMapas/TmxCompress.c
	$(CC) -o ../bin/TmxCompress ../../ComplementosChurrera/CompresorMapas/TmxCompress.c
bin/Png2Rcs: ../../ComplementosChurrera/FiltroRCS/Png2Rcs.c
	$(CC) -o ../bin/Png2Rcs ../../ComplementosChurrera/FiltroRCS/Png2Rcs.c
bin/step1: step1.c
	$(CC) -o ../bin/step1 step1.c
bin/step2: step2.c
	$(CC) -o ../bin/step2 step2.c
bin/step3: step3.c
	$(CC) -o ../bin/step3 step3.c
bin/zx7b: zx7b.c
	$(CC) -o ../bin/zx7b zx7b.c
bin/numbers4map: numbers4map.c
	$(CC) -o ../bin/numbers4map numbers4map.c
	../bin/numbers4map
	rm ../bin/numbers4map*
bin/generate_table: generate_table.c
	$(CC) -o ../bin/generate_table generate_table.c
	../bin/generate_table
	rm ../bin/generate_table*
bin/GenTmx: GenTmx.c
	$(CC) -o ../bin/GenTmx GenTmx.c

clean:
	rm -f bin/*

