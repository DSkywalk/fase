#include "lodepng.h"
#include <stdio.h>
#include <stdlib.h>
unsigned char *image;
unsigned error, width, height, i, j, k, l, m;
FILE *fo;

int main(int argc, char *argv[]){
  error= lodepng_decode32_file(&image, &width, &height, "numbers4map.png");
  if( error )
    printf("Error %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  if( width!= 50 && height!= 21 )
    printf("Error. Bad dimmensions");
  fo= fopen("numbers4map.h", "wb+");
  fprintf(fo, "short n4m[]={");
  if( !fo )
    printf("\nCannot create output file: numbers4map.h\n"),
    exit(-1);
  for ( i= 0; i < 3; i++ )
    for ( j= 0; j < 10; j++ ){
      (i || j) && fprintf(fo, "0x%04x,", m);
      for ( m= k= 0; k < 5; k++ )
        for ( l= 0; l < 3; l++ )
          m<<= 1,
          m|= !image[((7*i+k+1)*50+j*5+l+1)*4];
    }
  fprintf(fo, "0x%04x};", m);
  fclose(fo);
  free(image);
}
