#include <stdio.h>
#include <stdlib.h>
int main(int argc, char* argv[]){
  unsigned char *mem, *out;
  FILE *fi, *fo;
  int size, scrw, scrh, mapw, maph, i, j, k, l, m, packed;
  if( argc==1 )
    printf("\nBin2Map v1.12, BIN file (dump) to MAP (Mappy) by Antonio Villena, 13 Jan 2014\n\n"
           "  Bin2Map       <map_width> <map_height> <screen_width> <screen_height>\n"
           "                <input_map> <output_tmx> [<packed>]\n\n"
           "  <map_width>       Map width\n"
           "  <map_height>      Map height\n"
           "  <screen_width>    Screen width\n"
           "  <screen_height>   Screen height\n"
           "  <input_bin>       Origin binary file\n"
           "  <output_map>      Generated .map output file\n"
           "  <packed>          Optional, only for packed map (16 tiles)\n\n"
           "Example: Bin2Map 5 4 15 10 mapa.bin mapa.map\n"),
    exit(0);
  if( argc!=7 && argc!=8 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  mapw= atoi(argv[1]);
  maph= atoi(argv[2]);
  scrw= atoi(argv[3]);
  scrh= atoi(argv[4]);
  packed= argc+1 & 1;
  mem= malloc (mapw*maph*scrw*scrh);
  fi= fopen(argv[5], "rb");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[5]),
    exit(-1);
  size= fread(mem, 1, mapw*maph*scrw*scrh, fi);
  fclose(fi);
  if( size<<packed != mapw*maph*scrw*scrh )
    printf("\nInvalid length on binary input\n"),
    exit(-1);
  fo= fopen(argv[6], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[6]),
    exit(-1);
  out= malloc (mapw*maph*scrw*scrh);
  m= size= 0;
  if( packed )
    for ( i= 0; i<maph; i++ )
      for ( j= 0; j<mapw; j++ )
        for ( k= 0; k<scrh; k++ )
          for ( l= 0; l<scrw; l++ )
            out[i*mapw*scrh*scrw+j*scrw+k*mapw*scrw+l]= m++&1 ? mem[size++]&15 : mem[size]>>4;
  else
    for ( i= 0; i<maph; i++ )
      for ( j= 0; j<mapw; j++ )
        for ( k= 0; k<scrh; k++ )
          for ( l= 0; l<scrw; l++ )
            out[i*mapw*scrh*scrw+j*scrw+k*mapw*scrw+l]= mem[size++];
  fwrite(out, 1, size<<packed, fo);
  fclose(fo);
  printf("\nFile generated successfully\n");
}