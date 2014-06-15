#!/bin/bash

GAMENAME=gatete

rm ../$GAMENAME.tap &> /dev/null
rm -rf build &> /dev/null
mkdir -p build

echo "-----------------------------------"
echo "### REGENERANDO MAPA y SPRITES ###"
posterizezx ../gfx/loading.png build/loading.png
util/png2rcs build/loading.png build/loading.rcs
util/zx7b build/loading.rcs loading.rcs.zx7b
#  util/gentmx 3 3 10 10 map.tmx
util/tmxcompress map.tmx map_compressed.bin > defmap.asm
util/step1

echo " "
echo "--------------------------"
echo "### REGENERANDO ENGINE ###"
sjasmplus engine0.asm
sjasmplus engine1.asm
sjasmplus engine2.asm
util/step2
util/zx7b block.bin block.zx7b

echo " "
echo "########################"
echo "### COMPILANDO GUEGO ###"
zcc +zx -O3 -vn main.c -o main.bin -lndos
util/zx7b main.bin main.zx7b
cat map_compressed.bin main.zx7b block.zx7b > engine.zx7b
cp defload.asm ndefload.asm

en7size=$(wc -c "engine.zx7b" | cut -f 1 -d ' ')
ma7size=$(wc -c "main.zx7b"   | cut -f 1 -d ' ')
mansize=$(wc -c "main.bin"    | cut -f 1 -d ' ')
echo "        DEFINE  engicm  $en7size " >> ndefload.asm
echo "        DEFINE  maincm  $ma7size " >> ndefload.asm
echo "        DEFINE  mainrw  $mansize " >> ndefload.asm

sjasmplus loader.asm
gentape ../$GAMENAME.tap           \
    basic "'GAME'" 0  loader.bin  \
     data           engine.zx7b

