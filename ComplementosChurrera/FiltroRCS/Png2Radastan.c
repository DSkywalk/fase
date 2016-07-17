#include <stdio.h>
#include <stdlib.h>
#include "../lodepng.c"
unsigned char *png, *image;
unsigned error, width, height, i;
size_t pngsize;
LodePNGState state;
FILE *fo;

int main(int argc, char *argv[]){
  if( argc==1 )
    printf("\nPng2Radastan v1.20. Image to Radastan mode by AntonioVillena, 17 Jul 2016\n\n"
           "  Png2Radastan <input_png> <output_rad> [<output_pal>]\n\n"
           "  <input_png>     128x32, 128x64 or 128x96 png file\n"
           "  <output_rad>    ZX-Uno Radastan binary output of 6144 bytes\n\n"
           "  <output_pal>    Up to 16 bytes pallete in (G2 G1 G0 R2 R1 R0 B1 B0) format\n\n"
           "Example: Png2Radastan loading.png loading.rad loading.pal\n"),
    exit(0);
  if( argc!=3 && argc!=4 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  error= lodepng_load_file(&png, &pngsize, argv[1]);
  if( !error )
    error= lodepng_decode(&image, &width, &height, &state, png, pngsize);
  if( error )
    printf("\nError %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  if( width!=128 || height>96 || height&31 )
    printf("\nError. Incorrect size on %s, must be 128x32, 128x64 or 128x96", argv[1]);
  if( state.info_png.color.colortype!=LCT_PALETTE || state.info_png.color.palettesize>16 )
    printf("\nError. PNG must be indexed (pallete) with a maximum of 16 colors", argv[1]);
  fo= fopen(argv[2], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[2]),
    exit(-1);
  fwrite(image, 1, height<<6, fo);
  for ( i= 0; i<state.info_png.color.palettesize; i++ )
    image[i]= state.info_png.color.palette[i<<2|1]   &0xe0
            | state.info_png.color.palette[i<<2  ]>>3&0x1c
            | state.info_png.color.palette[i<<2|2]>>6&0x03;
  if( argv[3] ){
    fclose(fo);
    fo= fopen(argv[3], "wb+");
    if( !fo )
      printf("\nCannot create output file: %s\n", argv[3]),
      exit(-1);
    printf("\nFiles %s and %s generated from %s\n", argv[2], argv[3], argv[1]);
  }
  else
    printf("\nFile %s filtered from %s\n", argv[2], argv[1]);
  fwrite(image, 1, i, fo);
  fclose(fo);
  free(image);
}
