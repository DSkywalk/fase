#include <stdio.h>
#include <stdlib.h>
#include "../lodepng.c"
unsigned char image[0x30000], *pixel, input[0x5b01];
unsigned error, size, i, j, k, l, fondo, tinta, brillo, color;
FILE *fi;

int main(int argc, char *argv[]){
  if( argc==1 )
    printf("\nScr2Png v0.99. ZX Spectrum screen to PNG format by AntonioVillena, 13 Apr 2014\n\n"
           "  Png2Rcs <input_scr> <output_png> [input_attr]\n\n"
           "  <input_scr>     ZX spectrum input in SCR format\n"
           "  <output_png>    Output 256x64, 256x128 or 256x192 png file\n"
           "  <input_attr>    If specified, attributes here\n\n"
           "Example: Png2Rcs loading.png loading.rcs\n"),
    exit(0);
  if( argc!=3 && argc!=4 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fi= fopen(argv[1], "rb");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[1]),
    exit(-1);
  size= fread(input, 1, 0x1801, fi);
  if( size==0x1801 && argc==4 )
    printf("\nInput file too long\n"),
    exit(-1);
  else if( argc==3 )
    size+= fread(input+0x1801, 1, 0x300, fi);
  else{
    fclose(fi);
    fi= fopen(argv[3], "rb");
    if( !fi )
      printf("\nInput file not found: %s\n", argv[3]),
      exit(-1);
    size+= fread(input+0x1800, 1, 0x301, fi);
  }
  switch( size ){
    case 0x900:
    case 0x1200:
      if( argc==3 )
        fseek(fi, size*8/9, SEEK_SET);
        fread(input+0x1800, 1, 0x200, fi);
    case 0x1b00:
      break;
    default:
      printf("\nInvalid input size\n");
      exit(-1);
  }
  for ( i= 0; i < size/0x900; i++ )
    for ( j= 0; j < 0x100; j++ ){
      fondo= input[0x1800 | i<<8 | j];
      tinta= fondo&7 | fondo>>3&8;
      fondo>>= 3;
      brillo= tinta&8 ? 255 : 192;
      for ( k= 0; k < 8; k++ )
        for ( l= 0; l < 8; l++ )
          pixel= &image[(i<<14 | j<<6&0x3800 | k<<8 | j<<3&0xf8 | l)<<2],
          color= input[i<<11 | k<<8&0x700 | j]<<l & 128 ? tinta : fondo,
          pixel[0]= brillo*(color>>1&1),
          pixel[1]= brillo*(color>>2&1),
          pixel[2]= brillo*(color   &1),
          pixel[3]= 255;
    }
  if( error= lodepng_encode32_file(argv[2], image, 256, 64*(size/0x900)) )
    printf("Error %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  printf("\nFile generated successfully\n");
}
