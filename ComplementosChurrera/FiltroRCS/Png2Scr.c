#include "lodepng.c"
#include <stdio.h>
#include <stdlib.h>
unsigned char *image, *pixel, output[0x5b00];
unsigned error, width, height, i, j, k, l, m, fondo, tinta;
long long atr, celda;
FILE *fo;

int check(int value){
  return value==0 || value==192 || value==255;
}

int tospec(int r, int g, int b){
  return ((r|g|b)==255 ? 8 : 0) | g>>7<<2 | r>>7<<1 | b>>7;
}

int main(int argc, char *argv[]){
  if( argc==1 )
    printf("\nPng2Scr v1.11. Image to ZX Spectrum SCR screen by AntonioVillena, 13 Apr 2014\n\n"
           "  Png2Scr <input_png> <output_scr> [output_attr]\n\n"
           "  <input_png>     256x64, 256x128 or 256x192 png file\n"
           "  <output_scr>    ZX spectrum output in SCR format\n"
           "  <output_attr>   If specified, attributes here\n\n"
           "Example: Png2Scr loading.png loading.scr\n"),
    exit(0);
  if( argc!=3 && argc!=4 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  error= lodepng_decode32_file(&image, &width, &height, argv[1]);
  if( error )
    printf("\nError %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  if( width!=256 || height>192 || height&63 )
    printf("\nError. Incorrect size on %s, must be 256x64, 256x128 or 256x192", argv[1]);
  fo= fopen(argv[2], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[2]),
    exit(-1);
  for ( i= 0; i < height>>6; i++ )
    for ( j= 0; j < 0x100; j++ ){
      celda= 0;
      pixel= &image[(i<<14 | j<<6&0x3800 | j<<3&0xf8)<<2];
      fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
      for ( k= 0; k < 8; k++ )
        for ( l= 0; l < 8; l++ ){
          pixel= &image[(i<<14 | j<<6&0x3800 | k<<8 | j<<3&0xf8 | l)<<2];
          if( !(check(pixel[0]) && check(pixel[1]) && check(pixel[2]))
            || ((char)pixel[0]*-1 | (char)pixel[1]*-1 | (char)pixel[2]*-1)==65 )
            printf( "\nThe pixel (%d, %d) has an incorrect color\n",
                    l | j<<3&0xf8, k | j>>2&0x38 | i<<6 ),
            exit(-1);
          if( tinta != tospec(pixel[0], pixel[1], pixel[2]) )
            if( fondo != tospec(pixel[0], pixel[1], pixel[2]) ){
              if( tinta != fondo )
                printf( "\nThe pixel (%d, %d) has a third color in the cell\n",
                        l | j<<3&0xf8, k | j>>2&0x38 | i<<6 ),
                exit(-1);
              tinta= tospec(pixel[0], pixel[1], pixel[2]);
            }
          celda<<= 1;
          celda|= fondo != tospec(pixel[0], pixel[1], pixel[2]);
        }
      if( fondo==tinta ){
        if( tinta )
          celda= 0xffffffffffffffff,
          atr= tinta&7 | tinta<<3&64;
        else
          celda= 0,
          atr= 7;
      }
      else if( fondo<tinta )
        atr= fondo<<3 | tinta&7 | tinta<<3&64;
      else
        celda^= 0xffffffffffffffff,
        atr= tinta<<3 | fondo&7 | fondo<<3&64;
      for ( k= 0; k < 8; k++ )
        output[i<<11 | k<<8&0x700 | j]= celda>>(56-k*8);
      output[height<<5 | i<<8 | j]= atr;
    }
  if( argc==3 )
    fwrite(output, 1, height*36, fo),
    printf("\nFile %s filtered from %s\n", argv[2], argv[1]);
  else{
    fwrite(output, 1, height<<5, fo);
    fclose(fo);
    fo= fopen(argv[3], "wb+");
    if( !fo )
      printf("\nCannot create output file: %s\n", argv[3]),
      exit(-1);
    fwrite(output+height*32, 1, height<<2, fo);
    printf("\nFiles %s and %s generated from %s\n", argv[2], argv[3], argv[1]);
  }
  fclose(fo);
  free(image);
}