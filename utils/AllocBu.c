#include <stdio.h>
#include <stdlib.h>
FILE *fi, *fi2;
unsigned char mem[0x10000], sprites[0x8000], sblocks[0x81], sorder[0x81], subset[0x1200][0x81],
  snaheader[0x1b]= {0x3f, 0x58, 0x27, 0x9b, 0x36, 0x96, 0xb9, 0x1e, 0xd5, 0x02, 0xf0, 0x44, 0xd5,
                    0x00, 0x00, 0x3a, 0x5c, 0x00, 0xf0, 0x00, 0x73, 0x45, 0x01, 0x00, 0x40, 0x01, 0};
unsigned  saccum[0x81], stiles, ssprites, scode, scode1, scode2, smooth, nblocks, nsprites,
          nnsprites, sum, tmp, init0, init1, frame0, frame1, point, stasp;
int longl[4], i, j, k, l;
struct blockentry {
  int len;
  unsigned addr;
} blocks[4]=  { { 99>>1, 0x5b97}
              , {     0,      0}
              , {     0,      0}
              , {     0,      0}};

int main(int argc, char *argv[]){
  if( argc==1 )
    printf("\nAllocBu v0.01. Bu space allocator by AntonioVillena, 20 Nov 2013\n\n"
           "  AllocBu\n\n"
           "Example: AllocBu tiles sprites engine game\n"),
    exit(0);
  if( argc!=2 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fi= fopen("sprites.bin", "rb");
  ssprites= fread(sprites, 1, 0x8000, fi);
  fclose(fi);
  fi= fopen("main.bin", "rb");
  fread(mem+0x8000, 1, 0x8000, fi);
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
  smooth= mem[0xfdff]&1;
  fi= fopen("tiles.bin", "rb");
  stiles= fread(mem+0x5c50, 1, 0x2400, fi);
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
    blocks[1].len= (239-sprites[nsprites])>>1;
    blocks[1].addr= 0xff01+sprites[nsprites];
    mem[0xfefe]= 0x01;
    mem[0xfeff]= 0xff;
    for ( l= 0; l<sprites[nsprites]; l++ )
      mem[0xff01+l]= sprites[saccum[nsprites]+64+smooth*64+l];
  }
  else
    blocks[1].len= 239>>1,
    blocks[1].addr= 0xff01;
  blocks[2].len= (0x23b0-stiles)>>1;
  blocks[2].addr= 0x5c50+stiles;
  blocks[3].len= (ssprites>>1)-blocks[0].len-blocks[1].len-blocks[2].len;
  stasp= blocks[3].len>0 ? stasp+(blocks[3].len<<1): stasp;
  blocks[3].addr= 0x10000-stasp;
  mem[0xffff-stasp]= 0xff;
  mem[0xfffe-stasp]= 0xff;
  mem[point]= 0xfffe-stasp&0xff;
  mem[point+1]= 0xfffe-stasp>>8;
  nblocks= blocks[3].len>0 ? 4 : 3;
  while ( !sprites[--i] );
  nsprites= ++i;

    printf(" %x %x \n", blocks[3].addr, blocks[3].len<<1);

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
//            printf("[%d,%d]--->%x\n", j, k, sblocks[k]*2);
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
/*    for ( l= 0; l<64; l++ )
      printf("%x,", sblocks[l]*2);
    printf(" %d\n", nblocks);*/

  }
  mem[0x4000]= 0x00;
  mem[0x4001]= 0x80;
  fclose(fi);
  fi= fopen("dump48.sna", "wb+");
  fwrite(snaheader, 1, 0x1b, fi);
  fwrite(mem+0x4000, 1, 0xc000, fi);
  fclose(fi);
  fi= fopen("map_compressed.bin", "rb");
  fseek(fi, 0, SEEK_END);
  tmp= ftell(fi);
  fclose(fi);
  fi2= fopen("engine2.bin", "rb");
  fseek(fi2, -14, SEEK_END);
  fread(mem+0xfff2, 1, 13, fi2);
  fclose(fi2);
  fi= fopen("block1.bin", "wb+");
  fwrite(mem+0x5b97, 1, 0x2469, fi);
  if( smooth ){
    fwrite(mem+0xfca0, 1, 0x360, fi);
    if( blocks[3].len>0 )
      fwrite(mem+0x10000-stasp, 1, blocks[3].len<<1, fi);
    fwrite(mem+0x10002-scode, 1, scode-2-0x3df-tmp, fi);
  }
  else{
    fwrite(mem+0xfd50, 1, 0x130, fi);
    fwrite(mem+0xfeff, 1, 0x101, fi);
    if( blocks[3].len>0 )
      fwrite(mem+blocks[3].addr, 1, blocks[3].len<<1, fi);
    fwrite(mem+0x10002-scode, 1, scode-2-0x2b0-tmp, fi);
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
    fwrite(mem+0x10002-scode1, 1, scode1-2-0x3df-tmp, fi);
  else
    fwrite(mem+0x10002-scode1, 1, scode1-2-0x2b0-tmp, fi);
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
    fwrite(mem+0x10002-scode2, 1, scode2-2-0x3df-tmp, fi),
    scode-= 0x3df+tmp,
    scode1-= 0x3df+tmp,
    scode2-= 0x3df+tmp;
  else
    fwrite(mem+0x10002-scode2, 1, scode2-2-0x2b0-tmp, fi),
    scode-= 0x2b0+tmp,
    scode1-= 0x2b0+tmp,
    scode2-= 0x2b0+tmp;
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
              "        DEFINE  bl3len  %d\n"
              "        DEFINE  stasp   %d\n", smooth, tmp, scode-2, scode1-2,
              scode2-2, init0, init1, frame0, frame1, blocks[3].len>0?blocks[3].len<<1:0, stasp);
  fclose(fi);
  fi= fopen("defs.h", "wb+");
  fprintf(fi, "#define smooth %d\n"
              "#define stack  %d\n", smooth, 0xfe50-stasp);
  fclose(fi);

/*  fi= fopen("dump128.sna", "wb+");
  fwrite(snaheader, 1, 0x1b, fi);
  fwrite(mem+0x4000, 1, 0xc000, fi);
  snaheader[0]= 0x00;
  snaheader[1]= 0x80;
  snaheader[2]= 0x10;
  snaheader[3]= 0x00;
  fwrite(snaheader, 1, 4, fi);
  fwrite(mem+0x4000, 1, 0xc000, fi);
  fwrite(mem+0x4000, 1, 0x8000, fi);
  fclose(fi);*/

/*  for ( i= 0; i<0x40; i++ )
    printf("%4x,", saccum[i]);

  printf("%x\n", nsprites);
  for ( i= 0; i<nsprites; i++ )
    printf("%x,", sblocks[i]);
  printf("\n%d, %d, %d, %d ", longl[0], longl[1], longl[2], longl[3]);
  printf("%x ", 0x10000-scode);*/


}
