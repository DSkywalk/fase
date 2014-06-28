#include <stdio.h>
#include <stdlib.h>
#include <string.h>
FILE *fi, *fi2;
unsigned char mem[0x12000], sprites[0x8000], bullets[8], sblocks[0x89], sorder[0x89], subset[0x1200][0x89];
char tmpstr[30], *fou, scrw, scrh, mapw, maph, bullet, bulmax, sprmax;
unsigned  saccum[0x89], stiles, ssprites, scode, scode1, scode2, smooth, nblocks, nsprites,
          tmpbuf, notabl, nnsprites, sum, tmp, init0, init1, frame0, frame1, point, stasp, blen;
int i, j, k, l, bulimit;
struct {
  int len;
  unsigned addr;
} blocks[3]=  { {     0,      0}
              , {     0,      0}
              , {     0,      0}};

int main(int argc, char *argv[]){
  fi= fopen("build/sprites.bin", "rb");
  ssprites= fread(sprites, 1, 0x8000, fi);
  fclose(fi);
  fi= fopen("build/engine1.bin", "rb");
  fseek(fi, 0, SEEK_END);
  scode1= ftell(fi);
  fclose(fi);
  fi= fopen("build/engine2.bin", "rb");
  fseek(fi, 0, SEEK_END);
  scode2= ftell(fi);
  fclose(fi);
  fi= fopen("build/engine0.bin", "rb");
  fseek(fi, 0, SEEK_END);
  stasp= scode= ftell(fi);
  stasp= stasp<scode1 ? scode1 : stasp;
  stasp= stasp<scode2 ? scode2 : stasp;
  stasp= stasp-2&0xfffe;
  fseek(fi, 0, SEEK_SET);
  fread(&point, 1, 2, fi);
  fseek(fi, (scode&1)+2, SEEK_SET);
  scode&= 0xfffe;
  fread(mem+0x10002-scode, 1, 0x2000, fi);
  fclose(fi);
  init0= mem[0xfffd] | mem[0xfffe]<<8;
  frame0= mem[0xfffa] | mem[0xfffb]<<8;
  fi= fopen("config.def", "r");
  while ( !feof(fi) ){
    fgets(tmpstr, 30, fi);
    if( fou= (char *) strstr(tmpstr, "smooth") )
      smooth= atoi(fou+6);
    else if( fou= (char *) strstr(tmpstr, "notabl") )
      notabl= atoi(fou+6)<<8;
    else if( fou= (char *) strstr(tmpstr, "bullet") )
      bullet= atoi(fou+6);
    else if( fou= (char *) strstr(tmpstr, "bulmax") )
      bulmax= atoi(fou+6);
    else if( fou= (char *) strstr(tmpstr, "sprmax") )
      sprmax= atoi(fou+6);
  }
  fclose(fi);
  fi= fopen("build/defmap.asm", "r");
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
  l= 64<<smooth;
  for ( sum= tmpbuf= i= 0; i < 64<<smooth; i++ ){
    sum= sprites[i]+2;
    k= sprites[l];
    l+= 2;
    for ( j= 0; j<k; j++ )
      sum-= sprites[l+1]*(sprites[l]&12?sprites[l]>>2:2)*2,
      l+= 2+sprites[l+1]*(sprites[l]&12?sprites[l]>>2:2)*4;
    if( tmpbuf<sum )
      tmpbuf= sum;
  }
  tmpbuf= tmpbuf*sprmax+bulmax*4+2;
  fi= fopen("build/tiles.bin", "rb");
  stiles= fread(mem+0x5c08+bullet*(8<<smooth), 1, 0x23f8-bullet*(8<<smooth), fi);
  fclose(fi);
  nsprites= smooth ? 0x80 : 0x40;
  ssprites-= nsprites;
  saccum[0]= 0;
  for ( bulimit= 0; bulimit<nsprites; bulimit++ )
    sorder[bulimit]= bulimit,
    sblocks[bulimit]= sprites[bulimit]>>1,
    saccum[bulimit+1]= saccum[bulimit]+sprites[bulimit];
  if( smooth ){
    ssprites-= sprites[--nsprites];
    --bulimit;
    blocks[0].len= (243-sprites[nsprites])>>1;
    blocks[0].addr= 0xff01+sprites[nsprites];
    mem[0xfefe]= 0x01;
    mem[0xfeff]= 0xff;
    for ( l= 0; l<sprites[nsprites]; l++ )
      mem[0xff01+l]= sprites[saccum[nsprites]+64+smooth*64+l];
  }
  else
    blocks[0].len= 243>>1,
    blocks[0].addr= 0xff01;
  if( bullet ){
    fi= fopen("build/bullet.bin", "rb");
    fread(bullets, 1, smooth ? 8 : 4, fi);
    ssprites+= fread(sprites+(64<<smooth)+ssprites, 1, 0x200, fi);
    fclose(fi);
    nsprites= bulimit+(smooth ? 8 : 4);
    for ( i= bulimit; i<nsprites; i++ )
      sorder[i]= i,
      sblocks[i]= bullets[i-bulimit]>>1,
      saccum[i+1]= saccum[i]+bullets[i-bulimit];
  }
  blocks[1].len= (0x23f8-bullet*(8<<smooth)-stiles)>>1;
  blocks[1].addr= 0x5c08+bullet*(8<<smooth)+stiles;
  blocks[2].len= (ssprites>>1)-blocks[0].len-blocks[1].len;
  stasp= blocks[2].len>0 ? stasp+(blocks[2].len<<1): stasp;
  nblocks= blocks[2].len>0 ? 3 : 2;
  for ( i= 0; i < nblocks; i++ ){
    if( i==nblocks-1 )
      blocks[2].addr= 0x10000-stasp;
    blen= sum= blocks[i].len;
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
            blen-= sblocks[k];
            if( sorder[k]<bulimit )
              mem[0xfe00|sorder[k]<<1]= blocks[i].addr&0xff,
              mem[0xfe01|sorder[k]<<1]= blocks[i].addr>>8;
            else
              mem[0x5c08+(sorder[k]-bulimit<<1)]= blocks[i].addr&0xff,
              mem[0x5c09+(sorder[k]-bulimit<<1)]= blocks[i].addr>>8;
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
    if( blen )
      stasp+= blen<<1,
      blocks[nblocks-1].len+= blen;
  }
  mem[0xffff - stasp]= 0xff;
  mem[0xfffe - stasp]= 0xff;
  mem[point]= 0xfffe - stasp&0xff;
  mem[point+1]= 0xfffe - stasp>>8;
  fi= fopen("build/map_compressed.bin", "rb");
  fseek(fi, 0, SEEK_END);
  tmp= ftell(fi);
  fclose(fi);
  fi2= fopen("build/engine2.bin", "rb");
  fseek(fi2, -10, SEEK_END);
  fread(mem+0xfff6, 1, 9, fi2);
  fclose(fi2);
  fi2= fopen("build/engine1.bin", "rb");
  fseek(fi2, -9, SEEK_END);
  fread(mem+0xfff7, 1, 2, fi2);
  fclose(fi2);
  fi= fopen("build/block.bin", "wb+");
  fwrite(mem+0x5c08, 1, 0x23f8, fi);
  if( smooth ){
    fwrite(mem+0xfd00+notabl, 1, 0x300-notabl, fi);
    if( blocks[2].len>0 )
      fwrite(mem+0x10000-stasp, 1, blocks[2].len<<1, fi);
    fwrite(mem+0x10002-scode, 1, scode-2-0x37f+notabl-tmp, fi);
  }
  else{
    fwrite(mem+0xfd00+notabl, 1, 0x180-notabl, fi);
    fwrite(mem+0xfeff, 1, 0x101, fi);
    if( blocks[2].len>0 )
      fwrite(mem+blocks[2].addr, 1, blocks[2].len<<1, fi);
    fwrite(mem+0x10002-scode, 1, scode-2-0x300+notabl-tmp, fi);
  }
  fi2= fopen("build/engine1.bin", "rb");
  fseek(fi2, 0, SEEK_END);
  scode1= ftell(fi2);
  fseek(fi2, 0, SEEK_SET);
  fread(&point, 1, 2, fi2);
  fseek(fi2, (scode1&1)+2, SEEK_SET);
  scode1&= 0xfffe;
  fread(mem+0x10002-scode1, 1, 0x2000, fi2);
  fclose(fi2);
  init1= mem[0xfffd] | mem[0xfffe]<<8;
  frame1= mem[0xfffa] | mem[0xfffb]<<8;
  mem[point]= 0xfffe - stasp & 0xff;
  mem[point+1]= 0xfffe - stasp >> 8;
  if( smooth )
    fwrite(mem+0x10002-scode1, 1, scode1-2-0x37f+notabl-tmp, fi);
  else
    fwrite(mem+0x10002-scode1, 1, scode1-2-0x300+notabl-tmp, fi);
  fi2= fopen("build/engine2.bin", "rb");
  fseek(fi2, 0, SEEK_END);
  scode2= ftell(fi2);
  fseek(fi2, 0, SEEK_SET);
  fread(&point, 1, 2, fi2);
  fseek(fi2, (scode2&1)+2, SEEK_SET);
  scode2&= 0xfffe;
  fread(mem+0x10002-scode2, 1, 0x2000, fi2);
  fclose(fi2);
  mem[point]= 0xfffe - stasp & 0xff;
  mem[point+1]= 0xfffe - stasp >> 8;
  if( smooth )
    fwrite(mem+0x10002-scode2, 1, scode2-2-0x37f+notabl-tmp, fi),
    scode-= 0x37f-notabl+tmp,
    scode1-= 0x37f-notabl+tmp,
    scode2-= 0x37f-notabl+tmp;
  else
    fwrite(mem+0x10002-scode2, 1, scode2-2-0x300+notabl-tmp, fi),
    scode-= 0x300-notabl+tmp,
    scode1-= 0x300-notabl+tmp,
    scode2-= 0x300-notabl+tmp;
  fclose(fi);
  fi= fopen("build/player.bin.zx7b", "rb");
  i= 0;
  if( fi )
    fseek(fi, 0, SEEK_END),
    i= ftell(fi),
    fclose(fi),
    fi= fopen("build/player.bin", "rb"),
    fseek(fi, 0, SEEK_END),
    j= ftell(fi),
    fclose(fi);
  fi= fopen("build/defload.asm", "wb+");
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
              "        DEFINE  stasp   %d\n"
              "        DEFINE  notabl  %d\n"
              "        DEFINE  bullet  %d\n"
              "        DEFINE  tmpbuf  %d\n"
              "        DEFINE  player  %d\n"
              "        DEFINE  playrw  %d\n",
          smooth, tmp, scode-2, scode1-2, scode2-2, init0, init1, frame0, frame1,
          blocks[2].len>0?blocks[2].len<<1:0, stasp, notabl, bullet, tmpbuf, i, j);
  fclose(fi);
  fi= fopen("build/define.h", "wb+");
  fprintf(fi, "#define smooth %d\n"
              "#define stack  %d\n"
              "#define scrw   %d\n"
              "#define scrh   %d\n"
              "#define mapw   %d\n"
              "#define maph   %d\n"
              "#define dzx7a  %d\n"
              "#define player %d\n",  smooth, 0x10000-tmpbuf-stasp, scrw, scrh,
                                      mapw, maph, smooth ? 0xfc81+notabl : 0xfe80, !!i);
  fclose(fi);
  printf("\nFile block.bin generated in STEP 2\n");
}
