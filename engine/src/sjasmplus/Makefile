# Makefile for sjasmplus created by Tygrys' hands.

GCC=gcc
CC=$(GCC)
GPP=g++
C++=$(GPP)

EXE=../../bin/sjasmplus

CFLAGS=-O2 -w -DMAX_PATH=PATH_MAX
CXXFLAGS=$(CFLAGS)

#for Linux
LDFLAGS=-static-libgcc -static-libstdc++

#sjasmplus object files
OBJS=devices.o directives.o io_snapshots.o io_trd.o \
parser.o reader.o sjasm.o sjio.o support.o tables.o z80.o

all: $(OBJS)
	$(GPP) -o $(EXE) $(LDFLAGS) $(CXXFLAGS) $(OBJS)

.c.o:
	$(GCC) $(CFLAGS) -o $@ -c $< 
.cpp.o:
	$(GPP) $(CFLAGS) -o $@ -c $<

clean:
	rm -vf *.o *~ $(EXE)
