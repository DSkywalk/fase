#include "lodepng.h"
#include <stdio.h>
#include <stdlib.h>
unsigned char *image, *pixel, output[0x600];
unsigned error, width, height, i, j, k, l, fondo, tinta, outpos= 0;
long long atr, celdas[4];
FILE *fo;

int check(int value){
  return value==0 || value==192 || value==255;
}

int tospec(int r, int g, int b){
  return ((r|g|b)==255 ? 8 : 0) | g>>7<<2 | r>>7<<1 | b>>7;
}

void celdagen(int n){
  pixel= &image[(((j|i<<8)<<n) | k<<8 | l)<<2];
  if( !(check(pixel[0]) && check(pixel[1]) && check(pixel[2]))
    || ((char)pixel[0]*-1 | (char)pixel[1]*-1 | (char)pixel[2]*-1)==65 )
    printf("\nThe pixel (%d, %d) has an incorrect color\n" , j*16+l, i*16+k),
    exit(-1);
  if( tinta != tospec(pixel[0], pixel[1], pixel[2]) )
    if( fondo != tospec(pixel[0], pixel[1], pixel[2]) ){
      if( tinta != fondo )
        printf("\nThe pixel (%d, %d) has a third color in the cell\n", j*16+l, i*16+k),
        exit(-1);
      tinta= tospec(pixel[0], pixel[1], pixel[2]);
    }
  celdas[k>>3<<1 | l>>3]<<= 1;
  celdas[k>>3<<1 | l>>3]|= fondo != tospec(pixel[0], pixel[1], pixel[2]);
}

void atrgen(){
  atr<<= 8;
  if( fondo==tinta ){
    if( tinta )
      celdas[k>>4<<1 | l>>4]= 0xffffffffffffffff,
      atr|= tinta&7 | tinta<<3&64;
    else
      celdas[k>>4<<1 | l>>4]= 0,
      atr|= 7;
  }
  else if( fondo<tinta )
    atr|= fondo<<3 | tinta&7 | tinta<<3&64;
  else
    celdas[k>>4<<1 | l>>4]^= 0xffffffffffffffff,
    atr|= tinta<<3 | fondo&7 | fondo<<3&64;
}

void ciclocel(int n){
  pixel= &image[((j|i<<8)<<n)<<2];
  fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
  for ( k= 0; k < 8; k++ )
    for ( l= 0; l < 8; l++ )
      celdagen(n);
  atrgen();
  if( n==3 )
    return;
  pixel= &image[(((j|i<<8)<<n)|8)<<2];
  fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
  for ( k= 0; k < 8; k++ )
    for ( l= 8; l < 16; l++ )
      celdagen(4);
  atrgen();
  pixel= &image[(((j|i<<8)<<n)|2048)<<2];
  fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
  for ( k= 8; k < 16; k++ )
    for ( l= 0; l < 8; l++ )
      celdagen(4);
  atrgen();
  pixel= &image[(((j|i<<8)<<n)|2056)<<2];
  fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
  for ( k= 8; k < 16; k++ )
    for ( l= 8; l < 16; l++ )
      celdagen(4);
  atrgen();
}

void salida(int n){
  for ( i= 0; i<n; i++ ){
    fprintf(fo, "\n");
    for ( j= 0; j<8; j++ )
      fprintf(fo, "%3d,", output[j|i<<3]);
  }
  outpos= 0;
}

int main(int argc, char *argv[]){
  if( argc==1 )
    printf("\nGfxCnv v1.11. Chars, tiles and sprites generator by AntonioVillena,11 Nov 2013\n\n"
           "  GfxCnv <in_chars> <in_tiles> <in_sprites> <out_tileset> <out_sprites>\n\n"
           "  <input_chars>     Normally chars.png\n"
           "  <input_tiles>     Normally tiles.png\n"
           "  <input_sprites>   Normally sprites.png\n"
           "  <output_tileset>  Normally tileset.h\n"
           "  <output_sprites>  Normally sprites.h\n\n"
           "Example: GfxCnv chars.png tiles.png sprites.png tileset.h sprites.h\n"),
    exit(0);
  if( argc!=6 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  error= lodepng_decode32_file(&image, &width, &height, argv[1]);
  printf("Processing %15s...", argv[1]);
  if( error )
    printf("\nError %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  if( width!= 256 || height!= 16 )
    printf("\nError. Incorrect size on %s, must be 256x16", argv[1]);
  fo= fopen(argv[4], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[4]),
    exit(-1);
  fprintf(fo, "// Generado por GfxCnv de la churrera\n"
              "// Copyleft 2013 The Mojon Twins/Antonio Villena\n\n"
              "unsigned char tileset [] = {");
  for ( i= 0; i < 2; i++ )
    for ( j= 0; j < 32; j++ ){
      celdas[0]= 0;
      ciclocel(3);
      for ( l= 0; l < 8; l++ )
        output[outpos++]= celdas[0]>>(56-l*8);
    }
  salida(64);
  error= lodepng_decode32_file(&image, &width, &height, argv[2]);
  printf("Done\nProcessing %15s...", argv[2]);
  if( error )
    printf("\nError %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  if( width!= 256 || height!= 48 )
    printf("\nError. Incorrect size on %s, must be 256x48", argv[2]);
  for ( i= 0; i < 3; i++ )
    for ( j= 0; j < 16; j++ ){
      celdas[0]= celdas[1]= celdas[2]= celdas[3]= 0;
      ciclocel(4);
      for ( k= 0; k < 4; k++ )
        for ( l= 0; l < 8; l++ )
          output[outpos++]= celdas[k]>>(56-l*8);
    }
  salida(192);
  error= lodepng_decode32_file(&image, &width, &height, argv[1]);
  for ( i= 0; i < 2; i++ )
    for ( j= 0; j < 32; j++ )
      atr= 0,
      ciclocel(3),
      output[outpos++]= atr;
  salida(8);
  error= lodepng_decode32_file(&image, &width, &height, argv[2]);
  for ( i= 0; i < 3; i++ )
    for ( j= 0; j < 16; j++ ){
      atr= 0;
      ciclocel(4);
      for ( l= 0; l < 4; l++ )
        output[outpos++]= atr>>(24-l*8);
    }
  salida(23);
  fprintf(fo, "\n");
  for ( j= 0; j<7; j++ )
    fprintf(fo, "%3d,", output[j|i<<3]);
  fprintf(fo, "%3d};\n", output[j|i<<3]);
  error= lodepng_decode32_file(&image, &width, &height, argv[3]);
  printf("Done\nProcessing %15s...", argv[3]);
  if( error )
    printf("\nError %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  fclose(fo);
  fo= fopen(argv[5], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[5]),
    exit(-1);
  fprintf(fo, "// Generado por GfxCnv de la churrera\n"
              "// Copyleft 2013 The Mojon Twins/Antonio Villena\n\n");
  for ( i= 1; i < 17; i++ )
    for ( j= 0; j < 3; j++ )
      fprintf(fo, "extern unsigned char sprite_%d_%c [];\n", i, j+97);
  fprintf(fo, "\n#asm\n");
  for ( i= 0; i < 8; i++ )
    fprintf(fo, "        defb 0, 255\n");
  for ( i= 0; i < 16; i++ ){
    for ( j= 0; j < 2; j++ ){
      fprintf(fo, "\n    ._sprite_%d_%c\n", i+1, j+97);
      for ( k= 0; k < 16; k++ ){
        tinta= fondo= 0;
        for ( l= 0; l < 8; l++ )
          tinta|= image[(i>>3<<12 | (i&7)<<5 | k<<8 | j<<3 | l)<<2] ? 128>>l : 0,
          fondo|= image[(i>>3<<12 | (i&7)<<5 | k<<8 | j<<3 | 16 | l)<<2] ? 128>>l : 0;
        fprintf(fo, "        defb %d, %d\n", tinta, fondo);
      }
      for ( k= 0; k < 8; k++ )
        fprintf(fo, "        defb 0, 255\n");
    }
    fprintf(fo, "\n    ._sprite_%d_c\n", i+1);
    for ( j= 0; j < 24; j++ )
      fprintf(fo, "        defb 0, 255\n");
  }
  fprintf(fo, "\n#endasm\n");
  fclose(fo);
  printf("Done\nGenerating %15s...Done\nGenerating %15s...Done\n"
         "Files generated successfully\n", argv[4], argv[5]);
  free(image);
}
