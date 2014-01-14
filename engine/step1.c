#include "lodepng.h"
#include <stdio.h>
#include <stdlib.h>
unsigned char *image, *pixel, output[0x10000];
char tmpstr[20], *fou, tmode, clipup, clipdn, cliphr, safevr, safehr, offsex, offsey;
unsigned error, width, height, i, j, k, l, min, max, nmin, nmax, amin, amax,
          mask, pics, amask, apics, inipos, reppos, smooth, outpos, fondo, tinta;
long long atr, celdas[4];
FILE *fo, *ft;

int check(int value){
  return value==0 || value==192 || value==255;
}

int tospec(int r, int g, int b){
  return ((r|g|b)==255 ? 8 : 0) | g>>7<<2 | r>>7<<1 | b>>7;
}

celdagen(){
  pixel= &image[(((j|i<<8)<<4) | k<<8 | l)<<2];
  if( !(check(pixel[0]) && check(pixel[1]) && check(pixel[2]))
    || ((char)pixel[0]*-1 | (char)pixel[1]*-1 | (char)pixel[2]*-1)==65 )
    printf("El pixel (%d, %d) tiene un color incorrecto\n" , j*16+l, i*16+k),
    exit(-1);
  if( tinta != tospec(pixel[0], pixel[1], pixel[2]) )
    if( fondo != tospec(pixel[0], pixel[1], pixel[2]) ){
      if( tinta != fondo )
        printf("El pixel (%d, %d) tiene un tercer color de celda\n", j*16+l, i*16+k),
        exit(-1);
      tinta= tospec(pixel[0], pixel[1], pixel[2]);
    }
  celdas[k>>3<<1 | l>>3]<<= 1;
  celdas[k>>3<<1 | l>>3]|= fondo != tospec(pixel[0], pixel[1], pixel[2]);
}

atrgen(){
  atr<<= 8;
  if( fondo==tinta ){
    if( tinta )
      celdas[k>>4<<1 | l>>4]= 0xffffffffffffffff,
      atr|= tinta&7 | tinta<<3&64;
    else
      celdas[k>>4<<1 | l>>4]= 0,
      atr|= 7;
  }
  else if( fondo<tinta )
    atr|= fondo<<3 | tinta&7 | tinta<<3&64;
  else
    celdas[k>>4<<1 | l>>4]^= 0xffffffffffffffff,
    atr|= tinta<<3 | fondo&7 | fondo<<3&64;
}

int main(int argc, char *argv[]){
  ft= fopen("config.def", "r");
  while ( !feof(ft) ){
    fgets(tmpstr, 20, ft);
    if( fou= (char *) strstr(tmpstr, "tmode") )
      tmode= atoi(fou+5);
    else if( fou= (char *) strstr(tmpstr, "smooth") )
      smooth= atoi(fou+6);
    else if( fou= (char *) strstr(tmpstr, "clipup") )
      clipup= atoi(fou+6);
    else if( fou= (char *) strstr(tmpstr, "clipdn") )
      clipdn= atoi(fou+6);
    else if( fou= (char *) strstr(tmpstr, "cliphr") )
      cliphr= atoi(fou+6);
    else if( fou= (char *) strstr(tmpstr, "safevr") )
      safevr= atoi(fou+6);
    else if( fou= (char *) strstr(tmpstr, "safehr") )
      safehr= atoi(fou+6);
    else if( fou= (char *) strstr(tmpstr, "offsex") )
      offsex= atoi(fou+6);
    else if( fou= (char *) strstr(tmpstr, "offsey") )
      offsey= atoi(fou+6);
  }
  fclose(ft);

// tiles

  error= lodepng_decode32_file(&image, &width, &height, "tiles.png");
  if( error )
    printf("Error %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  if( width!= 256 )
    printf("Error. The width of tiles.png must be 256");
  for ( i= 0; i < height>>4; i++ )
    for ( j= 0; j < 16; j++ ){
      celdas[0]= celdas[1]= celdas[2]= celdas[3]= atr= 0;
      pixel= &image[((j|i<<8)<<4)<<2];
      fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
      for ( k= 0; k < 8; k++ )
        for ( l= 0; l < 8; l++ )
          celdagen();
      atrgen();
      pixel= &image[(((j|i<<8)<<4)|8)<<2];
      fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
      for ( k= 0; k < 8; k++ )
        for ( l= 8; l < 16; l++ )
          celdagen();
      atrgen();
      pixel= &image[(((j|i<<8)<<4)|2048)<<2];
      fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
      for ( k= 8; k < 16; k++ )
        for ( l= 0; l < 8; l++ )
          celdagen();
      atrgen();
      pixel= &image[(((j|i<<8)<<4)|2056)<<2];
      fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
      for ( k= 8; k < 16; k++ )
        for ( l= 8; l < 16; l++ )
          celdagen();
      atrgen();
      for ( k= 0; k < 4; k++ )
        for ( l= 0; l < 8; l++ )
          output[outpos++]= celdas[k]>>(56-l*8);
      for ( l= 0; l < 4; l++ )
        output[outpos++]= atr>>(24-l*8);
    }
  pics= outpos/36;
  inipos= 0x3000;
  for ( reppos= i= 0; i < pics; i++ ){
    for ( j= 0; j < i; j++ ){
      for ( k= l= 0; k < 32; k++ )
        l+= output[i*36+k]!=output[j*36+k];
      if( !l )
        break;
    }
    if( j==i )
      for ( k= 0; k < 32; k++ )
        output[0x6000+reppos*32+k]= output[i*36+k];
    output[inipos++]= j<i ? output[0x3000|j] : reppos++;
  }
  inipos= 0x4000;
  for ( apics= i= 0; i < pics; i++ ){
    for ( j= 0; j < i; j++ ){
      for ( k= l= 0; k < 4; k++ )
        l+= output[i*36+32+k]!=output[j*36+32+k];
      if( !l )
        break;
    }
    if( j==i )
      for ( k= 0; k < 4; k++ )
        output[0x5000+apics*4+k]= output[i*36+32+k];
    output[inipos++]= j<i ? output[0x4000|j] : apics++;
  }
  ft= fopen("define.asm", "wb+");
  fprintf(ft, "        DEFINE  tmode  %d\n"
              "        DEFINE  tiles  %d\n"
              "        DEFINE  bmaps  %d\n"
              "        DEFINE  attrs  %d\n"
              "        DEFINE  smooth %d\n"
              "        DEFINE  clipup %d\n"
              "        DEFINE  clipdn %d\n"
              "        DEFINE  cliphr %d\n"
              "        DEFINE  safevr %d\n"
              "        DEFINE  safehr %d\n"
              "        DEFINE  offsex %d\n"
              "        DEFINE  offsey %d\n",  tmode, pics, reppos, apics, smooth, clipup,
                                              clipdn, cliphr, safevr, safehr, offsex, offsey);
  fclose(ft);
  printf("no index     %d bytes\n", pics*36);
  printf("index bitmap %d bytes\n", pics*5+reppos*32);
  printf("index attr   %d bytes\n", pics*33+apics*4);
  printf("full index   %d bytes\n", pics*2+reppos*32+apics*4);
  fo= fopen("tiles.bin", "wb+");
  if( !fo )
    printf("\nCannot create tiles.bin\n"),
    exit(-1);
  switch( tmode ){
    case 0: fwrite(output, 1, outpos, fo);
            break;
    case 1: for ( i= 0; i < pics; i++ )
              fwrite(output+36*i+32,  1, 4, fo),
              fwrite(output+0x3000+i, 1, 1, fo);
            fwrite(output+0x6000, 1, reppos*32, fo);
            break;
    case 2: for ( i= 0; i < pics; i++ )
              fwrite(output+0x4000+i, 1, 1, fo),
              fwrite(output+36*i, 1, 32, fo);
            fwrite(output+0x5000, 1, apics*4, fo);
            break;
    case 3: for ( i= 0; i < pics; i++ )
              fwrite(output+0x3000+i, 1, 1, fo),
              fwrite(output+0x4000+i, 1, 1, fo);
            fwrite(output+0x6000, 1, reppos*32, fo);
            fwrite(output+0x5000, 1, apics*4, fo);
  }
  fclose(fo);
  free(image);

// sprites

  inipos= 0;
  outpos= 64<<smooth;
  error= lodepng_decode32_file(&image, &width, &height, "sprites.png");
  if( error )
    printf("\nError %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  fo= fopen("sprites.bin", "wb+");
  if( !fo )
    printf("\nCannot create sprites.bin\n"),
    exit(-1);
  for ( i= 0; i < 16; i++ )
    for ( j= 0; j < 8; j+= 2-smooth ){
      if( inipos )
        output[((j|i<<3)>>(1-smooth))-1]= outpos-inipos;
      output[inipos= outpos]= 0;
      output[inipos+1]= 0xf8+offsey*8;//0x50;
      outpos+= 2;
      nmin= nmax= 4;
      for ( k= 0; k < 16; k++ ){
        pics= mask= 0;
        for ( l= 0; l < 16; l++ )
          pics|= image[(i>>3<<12 | (i&7)<<5 | k<<8 | l)<<2] ? 0x800000>>l+j : 0,
          mask|= image[(i>>3<<12 | (i&7)<<5 | k<<8 | 16 | l)<<2] ? 0 : 0x800000>>l+j;
        for ( min= 0; min < 3 && !(mask&0xff<<(2-min<<3)); min++ );
        for ( max= 3; max && !(mask&0xff<<(3-max<<3)); max-- );
        if( k&1 ){
          if( min>amin ) min= amin;
          if( max<amax ) max= amax;
          if( min<max ){
            if( (nmin!=min) || (nmax!=max) )
              output[reppos= outpos]= min+1-(nmin>2?0:nmin)&3 | (max-min==3?3:max-min-1)<<2,
              outpos+= 2,
              output[inipos]++,
              output[reppos+1]= 0;
            output[reppos+1]++;
            for ( l= min; l < max; l++ )
              output[outpos++]= apics>>(2-l<<3),
              output[outpos++]= amask>>(2-l<<3)^0xff;
            for ( l= max; l > min; l-- )
              output[outpos++]= pics>>(3-l<<3),
              output[outpos++]= mask>>(3-l<<3)^0xff;
          }
          else if( nmin==4 )
            output[inipos+1]+= 2;
          nmin= min;
          nmax= max;
        }
        else
          apics= pics,
          amask= mask;
          amin= min,
          amax= max;
      }
      if( (inipos+2)==outpos ){
        outpos-= 2;
        goto salir;
      }
    }
salir:
  output[(64<<smooth)-1]= outpos-inipos;
  fwrite(output, 1, outpos, fo);
  fclose(fo);
//  printf("Generating      table.bin...Done\n");
  printf("Files generated successfully\n");
  free(image);

// table

  unsigned char table[0x100];
  fo= fopen("file1.bin", "wb+");
  for ( int i= 0; i<0x100; i++ )
    table[i]=  i&0x07 | i>>3&0x18 | i<<2&0xe0;
  fwrite(table, 1, 0x100, fo);

/*  fo= fopen("file2.bin", "wb+");
  for ( int i= 0x38; i<0xe8; i++ )
    table[i-0x38]=  0x3800 + (i<<8&0x700) + (((offsey<<3)+i)<<2&0xe0) + (((offsey<<3)+i)<<5&0x1800);
  fwrite(table, 1, 0x160, fo);*/
  fclose(fo);
}
