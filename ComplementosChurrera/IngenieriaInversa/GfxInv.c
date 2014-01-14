#include "lodepng.h"
#include <stdio.h>
#include <stdlib.h>
unsigned char *pixel, image[0xc000], input[0x900];
unsigned error, width, height, i, j, k, l, fondo, tinta, brillo, color;
FILE *fi;

int main(int argc, char *argv[]){
  if( argc==1 )
    printf("\nGfxInv v1.11. Chars, tiles and sprites dumper by Antonio Villena, 11 Nov 2013\n\n"
           "  GfxInv <in_tileset> <in_sprites> <out_chars> <out_tiles> <out_sprites>\n\n"
           "  <input_tileset>  Input binary char+tiles\n"
           "  <input_sprites>  Input binary sprites.h\n"
           "  <output_chars>   Normally chars.png\n"
           "  <output_tiles>   Normally tiles.png\n"
           "  <output_sprites> Normally sprites.png\n\n"
           "Example: GfxInv tileset.bin sprites.bin chars.png tiles.png sprites.png\n"),
    exit(0);
  if( argc!=6 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fi= fopen(argv[1], "rb");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[1]),
    exit(-1);
  fread(input, 1, 0x200, fi);
  fseek(fi, 0x800, SEEK_SET);
  fread(input+0x200, 1, 0x40, fi);
  for ( i= 0; i < 2; i++ )
    for ( j= 0; j < 32; j++ ){
      fondo= input[0x200 | i<<5 | j];
      tinta= fondo&7 | fondo>>3&8;
      fondo>>= 3;
      for ( k= 0; k < 8; k++ )
        for ( l= 0; l < 8; l++ )
          pixel= &image[(((j|i<<8)<<3) | k<<8 | l)<<2],
          brillo= tinta&8 ? 255 : 192,
          color= input[i<<8 | j<<3 | k]<<l & 128 ? tinta : fondo,
          pixel[0]= brillo*(color>>1&1),
          pixel[1]= brillo*(color>>2&1),
          pixel[2]= brillo*(color   &1),
          pixel[3]= 255;
    }
  if( error= lodepng_encode32_file(argv[3], image, 256, 16) )
    printf("Error %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  fseek(fi, 0x200, SEEK_SET);
  fread(input, 1, 0x600, fi);
  fseek(fi, 0x840, SEEK_SET);
  fread(input+0x600, 1, 0xc0, fi);
  for ( i= 0; i < 3; i++ )
    for ( j= 0; j < 16; j++ )
      for ( k= 0; k < 16; k++ )
        for ( l= 0; l < 16; l++ )
          fondo= input[0x600 | i<<6 | j<<2 | k>>2&2 | l>>3],
          tinta= fondo&7 | fondo>>3&8,
          fondo>>= 3,
          pixel= &image[i<<14 | k<<10 | j<<6 | l<<2],
          brillo= tinta&8 ? 255 : 192,
          color= input[i<<9 | j<<5 | k<<1&16 | l&8 | k&7 ]<<(l&7) & 128 ? tinta : fondo,
          pixel[0]= brillo*(color>>1&1),
          pixel[1]= brillo*(color>>2&1),
          pixel[2]= brillo*(color   &1),
          pixel[3]= 255;
  if( error= lodepng_encode32_file(argv[4], image, 256, 48) )
    printf("Error %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  fclose(fi);
  fi= fopen(argv[2], "rb");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[2]),
    exit(-1);
  fseek(fi, 0x10, SEEK_SET);
  fread(input, 1, 0x900, fi);
  fclose(fi);
  for ( tinta= i= 0; i < 16; i++, tinta+= 48 )
    for ( j= 0; j < 2; j++, tinta+= 16 )
      for ( k= 0; k < 16; k++, tinta+= 2 )
        for ( l= 0; l < 8; l++ )
          pixel= &image[(i>>3<<12 | (i&7)<<5 | k<<8 | j<<3 | l)<<2],
          color= input[tinta]<<l & 128 ? 255 : 0,
          pixel[0]= color,
          pixel[1]= color,
          pixel[2]= color,
          pixel[64]= input[tinta+1]<<l & 128 ? 255 : 0,
          pixel[65]= pixel[66]= 0,
          pixel[67]= pixel[3]= 255;
  if( error= lodepng_encode32_file(argv[5], image, 256, 32) )
    printf("Error %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  free(image);
  printf("\nFiles generated successfully\n");
}
