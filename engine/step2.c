#include <stdio.h>
#include <stdlib.h>
FILE *fi, *fi2;
unsigned char mem[0x10000], sprites[0x8000], sblocks[0x81], sorder[0x81], subset[0x1200][0x81];
char tmpstr[30], *fou;
unsigned  saccum[0x81], stiles, ssprites, scode, scode1, scode2, smooth, nblocks, nsprites,
          nnsprites, sum, tmp, init0, init1, frame0, frame1, point, stasp, scrw, scrh, mapw, maph;
int i, j, k, l;
struct {
  int len;
  unsigned addr;
} blocks[3]=  { {     0,      0}
              , {     0,      0}
              , {     0,      0}};

int main(int argc, char *argv[]){
  fi= fopen("sprites.bin", "rb");
  ssprites= fread(sprites, 1, 0x8000, fi);
  fclose(fi);
  fi= fopen("engine1.bin", "rb");
  fseek(fi, 0, SEEK_END);
  scode1= ftell(fi);
  fclose(fi);
  fi= fopen("engine2.bin", "rb");
  fseek(fi, 0, SEEK_END);
  scode2= ftell(fi);
  fclose(fi);
  fi= fopen("engine0.bin", "rb");
  fseek(fi, 0, SEEK_END);
  stasp= scode= ftell(fi);
  stasp= stasp<scode1 ? scode1 : stasp;
  stasp= stasp<scode2 ? scode2 : stasp;
  stasp= stasp-2&0xfffe;
  fseek(fi, 0, SEEK_SET);
  fread(&point, 1, 2, fi);
  fseek(fi, (scode&1)+2, SEEK_SET);
  scode&= 0xfffe;
  fread(mem+0x10002-scode, 1, 0x1000, fi);
  fclose(fi);
  init0= mem[0xfffd] | mem[0xfffe]<<8;
  frame0= mem[0xfff2] | mem[0xfff3]<<8;
  fi= fopen("config.def", "r");
  while ( !feof(fi) ){
    fgets(tmpstr, 30, fi);
    if( fou= (char *) strstr(tmpstr, "smooth") )
      smooth= atoi(fou+6);
  }
  fclose(fi);
  fi= fopen("defmap.asm", "r");
  while ( !feof(fi) ){
    fgets(tmpstr, 30, fi);
    if( fou= (char *) strstr(tmpstr, "scrw") )
      scrw= atoi(fou+6);
    else if( fou= (char *) strstr(tmpstr, "scrh") )
      scrh= atoi(fou+6);
    else if( fou= (char *) strstr(tmpstr, "mapw") )
      mapw= atoi(fou+6);
    else if( fou= (char *) strstr(tmpstr, "maph") )
      maph= atoi(fou+6);
  }
  fclose(fi);
  fi= fopen("tiles.bin", "rb");
  stiles= fread(mem+0x5c08, 1, 0x23f8, fi);
  fclose(fi);
  nsprites= smooth ? 0x80 : 0x40;
  ssprites-= nsprites;
  saccum[0]= 0;
  for ( i= 0; i<nsprites; i++ )
    sorder[i]= i,
    sblocks[i]= sprites[i]>>1,
    saccum[i+1]= saccum[i]+sprites[i];
  if( smooth ){
    ssprites-= sprites[--nsprites];
    if( i==0x80)
      --i;
    blocks[0].len= (239-sprites[nsprites])>>1;
    blocks[0].addr= 0xff01+sprites[nsprites];
    mem[0xfefe]= 0x01;
    mem[0xfeff]= 0xff;
    for ( l= 0; l<sprites[nsprites]; l++ )
      mem[0xff01+l]= sprites[saccum[nsprites]+64+smooth*64+l];
  }
  else
    blocks[0].len= 239>>1,
    blocks[0].addr= 0xff01;
  blocks[1].len= (0x23f8-stiles)>>1;
  blocks[1].addr= 0x5c08+stiles;
  blocks[2].len= (ssprites>>1)-blocks[0].len-blocks[1].len;
  stasp= blocks[2].len>0 ? stasp+(blocks[2].len<<1): stasp;
  blocks[2].addr= 0x10000-stasp;
  mem[0xffff-stasp]= 0xff;
  mem[0xfffe-stasp]= 0xff;
  mem[point]= 0xfffe-stasp&0xff;
  mem[point+1]= 0xfffe-stasp>>8;
  nblocks= blocks[2].len>0 ? 3 : 2;
  while ( !sprites[--i] );
  nsprites= ++i;
  for ( i= 0; i < nblocks; i++ ){
    sum= blocks[i].len;
    for ( j= 0; j <= nsprites; j++ )
      subset[0][j] = 1;
    for ( j= 1; j <= sum; j++ )
      subset[j][0] = 0;
    for ( j= 1; j <= sum; j++)
      for ( k= 1; k <= nsprites; k++){
        subset[j][k]= subset[j][k-1];
        if( j >= sblocks[k-1] )
          subset[j][k]= subset[j][k] || subset[j-sblocks[k-1]][k-1];
      }
    if( !subset[sum][nsprites] )
      while( !subset[--sum][nsprites] );
    nnsprites= nsprites;
    for ( j= sum; j > 0; j-- )
      for ( k= nsprites; k > 0; k-- )
        while ( !subset[j][k] ){
          if( j >= sblocks[k] ){
            j-= sblocks[k];
            mem[0xfe00|sorder[k]<<1]= blocks[i].addr&0xff;
            mem[0xfe01|sorder[k]<<1]= blocks[i].addr>>8;
            for ( l= 0; l<sblocks[k]; l++ )
              mem[blocks[i].addr+(l<<1)]= sprites[saccum[sorder[k]]+64+smooth*64+(l<<1)],
              mem[blocks[i].addr+(l<<1)+1]= sprites[saccum[sorder[k]]+65+smooth*64+(l<<1)];
            blocks[i].addr+= sblocks[k]<<1;
            tmp= sblocks[nnsprites-1];
            sblocks[nnsprites-1]= sblocks[k];
            sblocks[k]= tmp;
            tmp= sorder[nnsprites-1];
            sorder[--nnsprites]= sorder[k];
            sorder[k]= tmp;
          }
          while ( j > 0 && k > 0 && subset[j][k] )
            k--;
        }
    nsprites= nnsprites;
  }
  mem[0x4000]= 0x00;
  mem[0x4001]= 0x80;
  fclose(fi);
  fi= fopen("map_compressed.bin", "rb");
  fseek(fi, 0, SEEK_END);
  tmp= ftell(fi);
  fclose(fi);
  fi2= fopen("engine2.bin", "rb");
  fseek(fi2, -14, SEEK_END);
  fread(mem+0xfff2, 1, 13, fi2);
  fclose(fi2);
  fi= fopen("block.bin", "wb+");
  fwrite(mem+0x5c08, 1, 0x23f8, fi);
  if( smooth ){
    fwrite(mem+0xfd00, 1, 0x300, fi);
    if( blocks[2].len>0 )
      fwrite(mem+0x10000-stasp, 1, blocks[2].len<<1, fi);
    fwrite(mem+0x10002-scode, 1, scode-2-0x37f-tmp, fi);
  }
  else{
    fwrite(mem+0xfd00, 1, 0x180, fi);
    fwrite(mem+0xfeff, 1, 0x101, fi);
    if( blocks[2].len>0 )
      fwrite(mem+blocks[2].addr, 1, blocks[2].len<<1, fi);
    fwrite(mem+0x10002-scode, 1, scode-2-0x300-tmp, fi);
  }
  fi2= fopen("engine1.bin", "rb");
  fseek(fi2, 0, SEEK_END);
  scode1= ftell(fi2);
  fseek(fi2, 0, SEEK_SET);
  fread(&point, 1, 2, fi2);
  fseek(fi2, (scode1&1)+2, SEEK_SET);
  scode1&= 0xfffe;
  fread(mem+0x10002-scode1, 1, 0x1000, fi2);
  fclose(fi2);
  init1= mem[0xfffd] | mem[0xfffe]<<8;
  frame1= mem[0xfff2] | mem[0xfff3]<<8;
  mem[point]= 0xfffe-stasp&0xff;
  mem[point+1]= 0xfffe-stasp>>8;
  if( smooth )
    fwrite(mem+0x10002-scode1, 1, scode1-2-0x37f-tmp, fi);
  else
    fwrite(mem+0x10002-scode1, 1, scode1-2-0x300-tmp, fi);
  fi2= fopen("engine2.bin", "rb");
  fseek(fi2, 0, SEEK_END);
  scode2= ftell(fi2);
  fseek(fi2, 0, SEEK_SET);
  fread(&point, 1, 2, fi2);
  fseek(fi2, (scode2&1)+2, SEEK_SET);
  scode2&= 0xfffe;
  fread(mem+0x10002-scode2, 1, 0x1000, fi2);
  fclose(fi2);
  mem[point]= 0xfffe-stasp&0xff;
  mem[point+1]= 0xfffe-stasp>>8;
  if( smooth )
    fwrite(mem+0x10002-scode2, 1, scode2-2-0x37f-tmp, fi),
    scode-= 0x37f+tmp,
    scode1-= 0x37f+tmp,
    scode2-= 0x37f+tmp;
  else
    fwrite(mem+0x10002-scode2, 1, scode2-2-0x300-tmp, fi),
    scode-= 0x300+tmp,
    scode1-= 0x300+tmp,
    scode2-= 0x300+tmp;
  fclose(fi);
  fi= fopen("defload.asm", "wb+");
  fprintf(fi, "        DEFINE  smooth  %d\n"
              "        DEFINE  maplen  %d\n"
              "        DEFINE  codel0  %d\n"
              "        DEFINE  codel1  %d\n"
              "        DEFINE  codel2  %d\n"
              "        DEFINE  init0   %d\n"
              "        DEFINE  init1   %d\n"
              "        DEFINE  frame0  %d\n"
              "        DEFINE  frame1  %d\n"
              "        DEFINE  bl2len  %d\n"
              "        DEFINE  stasp   %d\n", smooth, tmp, scode-2, scode1-2,
              scode2-2, init0, init1, frame0, frame1, blocks[2].len>0?blocks[2].len<<1:0, stasp);
  fclose(fi);
  fi= fopen("defs.h", "wb+");
  fprintf(fi, "#define smooth %d\n"
              "#define stack  %d\n"
              "#define scrw   %d\n"
              "#define scrh   %d\n"
              "#define mapw   %d\n"
              "#define maph   %d\n", smooth, 0xfe50-stasp, scrw, scrh, mapw, maph);
  fclose(fi);
}
