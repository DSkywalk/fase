#include "lodepng.h"
#include <stdio.h>
#include <stdlib.h>
unsigned char *image, *pixel, colors[][3]= {
      {  0,   0,   0},
      {  0,   0, 192},
      {192,   0,   0},
      {192,   0, 192},
      {  0, 192,   0},
      {  0, 192, 192},
      {192, 192,   0},
      {192, 192, 192},
      {  0,   0, 255},
      {255,   0,   0},
      {255,   0, 255},
      {  0, 255,   0},
      {  0, 255, 255},
      {255, 255,   0},
      {255, 255, 255}};
unsigned error, width, height, i, calc, min, minind, size;
int main(int argc, char *argv[]){
  if( argc==1 )
    printf("\nPosterizeZX v1.11. Transform an image to ZX Spectrum colors (no color clash)\n"
           "                                                by AntonioVillena, 11 Nov 2013\n\n"
           "  PosterizeZX <input_file> <output_file>\n\n"
           "  <input_file>      PNG input file\n"
           "  <output_file>     PNG output file\n\n"
           "Example: PosterizeZX work.png tiles.png\n"),
    exit(0);
  if( argc!=3 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  if( error= lodepng_decode32_file(&image, &width, &height, argv[1]) )
    printf("\nError %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  size= width*height;
  pixel= image;
  while ( size-- ){
    min= 1e9;
    for ( i= 0; i<15; i++ ){
      calc= (pixel[0]-colors[i][0])*(pixel[0]-colors[i][0])
          + (pixel[1]-colors[i][1])*(pixel[1]-colors[i][1])
          + (pixel[2]-colors[i][2])*(pixel[2]-colors[i][2]);
      if( calc<min )
        min= calc,
        minind= i;
    }
    pixel[0]= colors[minind][0];
    pixel[1]= colors[minind][1];
    pixel[2]= colors[minind][2];
    pixel+= 4;
  }
  if( error= lodepng_encode32_file(argv[2], image, width, height) )
    printf("Error %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  free(image);
  printf("\nFile posterized successfully\n");
}
