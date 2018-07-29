GPP=g++
EXE=../../bin/sjasmplus
FLAGS=-O2 -w -DMAX_PATH=PATH_MAX
OBJS=devices.o directives.o io_snapshots.o io_trd.o \
parser.o reader.o sjasm.o sjio.o support.o tables.o z80.o

all: $(OBJS)
	$(GPP) -o $(EXE) -static -static-libgcc -static-libstdc++ $(FLAGS) $(OBJS)

%.o : %.cpp
	$(GPP) $(FLAGS) -o $@ -c $<

clean:
	rm -vf *.o $(EXE)
