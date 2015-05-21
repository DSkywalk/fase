#include <stdio.h>
#include <stdlib.h>
FILE *fi, *fo;
unsigned char mem[0x10000];
int i, blo1cm, blo2cm, maincm, engicm, mainrw;
int main(void){
  fo= fopen("build/engine.zx7b", "wb");
  blo1cm= fread(mem, 1, 0x10000, fi= fopen("build/block1.zx7b", "rb"));   fclose(fi);
  fwrite(mem, 1, blo1cm, fo);
  i= fread(mem, 1, 0x10000, fi= fopen("build/music.zx7b", "rb"));         fclose(fi);
  fwrite(mem, 1, i, fo);
  i= fread(mem, 1, 0x10000, fi= fopen("build/screen.bin", "rb"));         fclose(fi);
  fwrite(mem, 1, i, fo);
  maincm= fread(mem, 1, 0x10000, fi= fopen("build/main.zx7b", "rb"));     fclose(fi);
  fwrite(mem, 1, maincm, fo);
  blo2cm= fread(mem, 1, 0x10000, fi= fopen("build/block2.zx7b", "rb"));   fclose(fi);
  fwrite(mem, 1, blo2cm, fo);
  i= fread(mem, 1, 0x10000, fi= fopen("build/map_compressed.bin", "rb")); fclose(fi);
  fwrite(mem, 1, i, fo);
  engicm= ftell(fo);
  fclose(fo);
  fo= fopen("build/ndefload.asm", "wb");
  i= fread(mem, 1, 0x10000, fi= fopen("build/defload.asm", "rb"));        fclose(fi);
  fwrite(mem, 1, i, fo);
  mainrw= fread(mem, 1, 0x10000, fi= fopen("build/main.bin", "rb"));      fclose(fi);
  fprintf(fo, "        DEFINE  engicm  %d\n"
              "        DEFINE  maincm  %d\n"
              "        DEFINE  mainrw  %d\n"
              "        DEFINE  blo1cm  %d\n"
              "        DEFINE  blo2cm  %d\n", engicm, maincm, mainrw, blo1cm, blo2cm);
  fclose(fo);
  printf("\nFile build\\engine.zx7b generated in STEP 3\n");
}
