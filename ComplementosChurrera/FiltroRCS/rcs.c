#include <stdio.h>
int scr2rcs( int i ){ return i&0x1800 | i<<8&0x700 | i<<2&0xe0 | i>>6&0x1f;  }
int rcs2scr( int i ){ return i&0x1800 | i>>8&7     | i>>2&0x38 | i<<6&0x7c0; }
int main(int argc, char* argv[]){
  unsigned char *mem= (unsigned char *) malloc (0x1b00);
  int tmp, last, j, k;
  FILE *fi, *fo;
  if( argc==1 )
    printf( "\nrcs v1.03, SCR filter to RCS (and inverse) by Antonio Villena, 18 Jan 2013\n\n"
            "  rcs [-i] <input_file> <output_file>\n\n"
            "  -i             Inverse filter (RCS to SCR), optional\n"
            "  <input_file>   Input file to filter\n"
            "  <output_file>  Genetated output file\n\n"
            "All params are mandatory except -i.\n"),
    exit(0);
  int (*func)(int)= &scr2rcs;
  if( argv[1][0] == '-' )
    func= &rcs2scr, argv++, argc--;
  if( argc==3 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fi= fopen(argv[1], "rb");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[1]),
    exit(-1);
  fo= fopen(argv[2], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[4]),
    exit(-1);
  fread(mem, 1, 0x1b01, fi);
  if( ftell(fi) != 0x1b00 )
    printf("\nInput file size must be 6912 bytes\n"),
    exit(-1);
  for ( int i= 0; i<0x1800; i++ ){
    k= j= i;
    do
      last= j,
      j= func(j),
      k<j && (k= j, j= i);
    while( j != i );
    if( k==i ){
      tmp= mem[j];
      do
        k= func(j),
        mem[j]= mem[k],
        j= k;
      while( j != i );
      mem[last]= tmp;
    }
  }
  fwrite(mem, 1, 0x1b00, fo);
  printf("\nFile generated successfully\n");
}