#include <stdlib.h>
#include <stdio.h>
#include <memory.h>

unsigned char *xm;

#define READ_WORD(off)  (xm[off] | xm[off+1]<<8)
#define READ_DWORD(off) (READ_WORD(off) | xm[off+2]<<16 | xm[off+3]<<24)

int main(int argc, char* argv[]){
  const float notes[12]= {2093.0f,2217.4f,2349.2f,2489.0f,2637.0f,2793.8f,
                          2960.0f,3136.0f,3322.4f,3520.0f,3729.2f,3951.0f};
  const float cputime= 153.0f;
  FILE *file;
  int size, order_len, order_loop, channels, patterns, tempo, bpm, i, j, k, pp,
      patlen, tag, note, ins, vol, fx, param, drum, row[3][2], speed, duty, cnt;
  float freqtable[96], div, step;
  char name[1024];

  if( argc!=3 )
    printf("xm2tritone converter by Shiru (shiru@mail.ru) 03'11\n"
           "Usage: xm2tritone filename.xm filename.asm\n"),
    exit(0);
  file= fopen(argv[1],"rb");
  if( !file )
    printf("Error: Can't open file %s\n", argv[1]),
    exit(-1);
  fseek(file, 0, SEEK_END);
  size= ftell(file);
  fseek(file, 0, SEEK_SET);
  xm= (unsigned char*) malloc(size);
  fread(xm, size, 1, file);
  fclose(file);
  if( memcmp(xm, "Extended Module: ", 17) )
    printf("Error: Not XM module\n"),
    exit(-1);
  order_len=  READ_WORD(60+4);
  order_loop= READ_WORD(60+6);
  channels=   READ_WORD(60+8);
  patterns=   READ_WORD(60+10);
  tempo=      READ_WORD(60+16);
  bpm=        READ_WORD(60+18);
  if( !order_len )
    printf("Error: Module should have at least one order position\n"),
    exit(-1);
  if( channels<3 )
    printf("Error: Module should have at least three channels\n"),
    exit(-1);
  div= 32;
  pp= 0;
  for ( i= 0; i<8; i++, div/=2 )
    for( j= 0; j<12; j++ )
      //step=(3500000.0f/(cputime/8.0f))/(notes[j]/div);
      step= (notes[j]/div)/(3500000.0f/(cputime/8.0f))*65536.0f,
      freqtable[pp]= step,
      pp++;
  file= fopen(argv[2], "wt");
  fprintf(file, "module\n");
  for( j= 0; j<order_len; j++ ){
    if( j==order_loop )
      fprintf(file,".loop\n");
    fprintf(file, "\tdw .p%2.2x\n", xm[60+20+j]);
  }
  fprintf(file, "\tdw 0\n\tdw .loop\n");
  for( i= 0; i<patterns; i++ )
  {
    for( j= 0; j<3; j++ )
      row[j][0]= row[j][1]= 0;
    pp= 60+20+256;
    for( j= 0; j<i; j++ )
      pp= pp+READ_DWORD(pp)+READ_WORD(pp+7);
    patlen= READ_WORD(pp+5);
    pp+= READ_DWORD(pp);
    for ( j= 0; j<patlen; j++ )
      for ( k= 0; k<channels; k++ )
        tag= xm[pp]&128 ? xm[pp++] : 31,
        note=     tag&1 ? xm[pp++] : 0,
        ins=      tag&2 ? xm[pp++] : 0,
        vol=      tag&4 ? xm[pp++] : 0,
        fx=       tag&8 ? xm[pp++] : 0,
        param=   tag&16 ? xm[pp++] : 0,
        fx==0x0f && param<0x20 && (tempo= param),
        fx==0x0f && param>0x1f && (bpm= param);
    speed= (int)(2500.0f*(float)tempo*(3500000.0f/1000.0f/cputime)/(float)bpm)+256;
    if( !(speed&0xff) )
      speed++;
    if( speed<1 || speed>65536 )
      printf("Warning: Tempo or BPM is out of range (ptn:%2.2x row:%2.2x chn:%i)\n", i, j, k);
    fprintf(file, ".p%2.2x\n", i);
    fprintf(file, "\tdw #%4.4x\n", speed);
    pp= 60+20+256;
    for( j= 0; j<i; j++ )
      pp= pp+READ_DWORD(pp)+READ_WORD(pp+7);
    patlen= READ_WORD(pp+5);
    pp+= READ_DWORD(pp);
    for ( j= 0; j<patlen; j++ ){
      drum= 0;
      for( k= 0; k<channels; k++ ){
        tag= xm[pp]&128 ? xm[pp++] : 31;
        note=     tag&1 ? xm[pp++] : 0;
        ins=      tag&2 ? xm[pp++] : 0;
        vol=      tag&4 ? xm[pp++] : 0;
        fx=       tag&8 ? xm[pp++] : 0;
        param=   tag&16 ? xm[pp++] : 0;
        if( k<3 ){
          row[k][0]= 1;
          row[k][1]= 0;
          if( note>0 && note<97 && ins<9 ){
            cnt= (int) freqtable[note-1];
            if( fx==0x0e && (param&0xf0)==0x50 ){
              cnt+= ((param&0x0f)-8);
              if( cnt<0 || cnt>4095 ){
                if(cnt<0)
                  cnt= 0;
                else if(cnt>4095)
                  cnt= 4095;
                printf("Warning: Note out of range (ptn:%2.2x row:%2.2x chn:%i)\n", i, j, k);
              }
            }
            duty= 0x80 | ins-1<<4;
            row[k][0]= cnt>>8&0x0f | duty;
            row[k][1]= cnt&0xff;
          }
          if( note==97 )
            row[k][0]= row[k][1]= 0;
        }
        if( ins==9 && note>=49 && note<49+12 )
          drum=note-47;
        if( ins==10 && note>=49 && note<49+12)
          drum=note-47+12;
      }
      if(drum)
        fprintf(file, "\tdb #%2.2x,",drum);
      else
        fprintf(file,"\tdb     ");
      for ( k= 0; k<3; k++ )
        if( row[k][0]>1 )
          fprintf(file, "#%2.2x,#%2.2x%c", row[k][0], row[k][1], k<2 ? ',' : '\n');
        else
          fprintf(file, "#%2.2x    %c", row[k][0], k<2 ? ',' : '\n');
    }
    fprintf(file, "\tdb #ff\n");
  }
  fclose(file);
  exit(0);
}
