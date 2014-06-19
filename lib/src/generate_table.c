#include <stdio.h>
int main(int argc, char *argv[]){
  FILE *fo;
  unsigned char table[0x100];
  fo= fopen("file1.bin", "wb+");
  for ( int i= 0; i<0x100; i++ )
    table[i]=  i&0x07 | i>>3&0x18 | i<<2&0xe0;
  fwrite(table, 1, 0x100, fo);
  fclose(fo);
}
