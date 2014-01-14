#include "numbers4map.h"
#include <stdio.h>
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char* argv[]){
  char tmpstr[100];
  FILE *fo;
  int size, scrw, scrh, mapw, maph, i, j, k, l, m, n, ofs;
  if( argc==1 )
    printf("\nGenTmx v1.11, MAP file (Mappy) to TMX (Tiled) by Antonio Villena, 11 Nov 2013\n\n"
           "  Map2Tmx  <map_width> <map_height> <screen_width> <screen_height> <output_tmx>\n\n"
           "  <map_width>       Map width\n"
           "  <map_height>      Map height\n"
           "  <screen_width>    Screen width\n"
           "  <screen_height>   Screen height\n"
           "  <output_tmx>      Generated output file\n\n"
           "Example: GenTmx 5 4 15 10 map.tmx\n"),
    exit(0);
  if( argc!=6 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fo= fopen(argv[5], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[6]),
    exit(-1);
  mapw= atoi(argv[1]);
  maph= atoi(argv[2]);
  scrw= atoi(argv[3]);
  scrh= atoi(argv[4]);
  size= mapw*maph*scrw*scrh;
  unsigned char *mem= (unsigned char *) calloc (0x10000, 1);
  if( scrw<7 || scrh<5 || scrw>8 && scrh>6 )
    for ( i= 0; i<maph; i++ )
      for ( j= 0; j<mapw; j++ ){
        for ( k= 0; k<scrw; k++ )
          mem[i*mapw*scrh*scrw+j*scrw+k]=
          mem[i*mapw*scrh*scrw+j*scrw+k+(scrh-1)*scrw*mapw]= 1;
        for ( k= 1; k<scrh-1; k++ )
          mem[i*mapw*scrh*scrw+j*scrw+k*mapw*scrw]=
          mem[i*mapw*scrh*scrw+j*scrw+k*mapw*scrw+scrw-1]= 1;
      }
  if( scrw>6 && scrh>4 )
    for ( i= 0; i<maph; i++ )
      for ( j= 0; j<mapw; j++ ){
        m= n4m[i%30];
        n= n4m[j%30];
        ofs= (scrw-7>>1)+(scrh-5>>1)*mapw*scrw;
        for ( k= 0; k<5; k++ )
          for ( l= 0; l<3; l++ )
            m<<= 1,
            n<<= 1,
            mem[ofs+i*mapw*scrh*scrw+j*scrw+k*mapw*scrw+l]= m>>14&2,
            mem[ofs+4+i*mapw*scrh*scrw+j*scrw+k*mapw*scrw+l]= n>>14&2;
      }
  sprintf(tmpstr, "width=\"%d\" height=\"%d\"", scrw*mapw+mapw-1, scrh*maph+maph-1);
  fprintf(fo, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
              "<map version=\"1.0\" orientation=\"orthogonal\" %s tilewidth=\"16\" tileheight=\"16\">\n"
              " <tileset firstgid=\"1\" name=\"tiles\" tilewidth=\"16\" tileheight=\"16\">\n"
              "  <image source=\"tiles.png\"/></tileset>\n"
              " <tileset firstgid=\"49\" name=\"sprites\" tilewidth=\"16\" tileheight=\"16\">\n"
              "  <image source=\"sprites.png\"/></tileset>\n"
              " <layer name=\"map\" %s>\n"
              "  <data encoding=\"csv\">\n", tmpstr, tmpstr);
  for ( int i= 0; i<size; i++ ){
    if( !(i%scrw) && i%(mapw*scrw) )
      fprintf(fo, "0,");
    if( i && !(i%(mapw*scrw*scrh)) ){
      for ( int j= 0; j<mapw*scrw+mapw-1; j++ )
        fprintf(fo, "0,");
      fprintf(fo, "\n");
    }
    if( i==size-1 )
      fprintf(fo, "%d\n", mem[i]+1);
    else if( (i+1)%(scrw*mapw) )
      fprintf(fo, "%d,", mem[i]+1);
    else
      fprintf(fo, "%d,\n", mem[i]+1);
  }
  fprintf(fo, "</data></layer>\n <objectgroup name=\"enems\" %s>\n", tmpstr);
  fprintf(fo, "</objectgroup></map>\n");
  fclose(fo);
  printf("\nFile generated successfully\n");
}