#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include "../../ComplementosChurrera/lodepng.c"

unsigned char *image, *pixel, output[0x10000], input[0x400];
char  tmpstr[50], command[50], *fou, tmode, clipup, clipdn, cliphr, safevr, safehr,
      offsex, offsey, notabl, bullet, bulmax, sprmax, forceatr= 0;
unsigned error, width, height, i, j, l, min, max, nmin, nmax, amin, amax,
          pics, apics, inipos, iniposback, reppos, smooth, outpos, fondo, tinta;
int k, mask, amask;
long long atr, celdas[4];
FILE *fi, *fo, *ft;

int check(int value){
  return value==0 || value==192 || value==255;
}

int tospec(int r, int g, int b){
  return ((r|g|b)==255 ? 8 : 0) | g>>7<<2 | r>>7<<1 | b>>7;
}

void celdagen(void){
  pixel= &image[(((j|i<<8)<<4) | k<<8 | l)<<2];
  if( !(check(pixel[0]) && check(pixel[1]) && check(pixel[2]))
    || ((char)pixel[0]*-1 | (char)pixel[1]*-1 | (char)pixel[2]*-1)==65 )
    printf("\nThe pixel (%d, %d) has an incorrect color\n" , j*16+l, i*16+k),
    exit(-1);
  if( forceatr ){
    if( (tinta|8) != (tospec(pixel[0], pixel[1], pixel[2])|8)
     && (fondo|8) != (tospec(pixel[0], pixel[1], pixel[2])|8) )
      printf("\nThe pixel (%d, %d) has a third color in the cell\n", j*16+l, i*16+k),
      exit(-1);
    celdas[k>>3<<1 | l>>3]<<= 1;
    celdas[k>>3<<1 | l>>3]|= (fondo|8) != (tospec(pixel[0], pixel[1], pixel[2])|8);
  }
  else{
    if( tinta != tospec(pixel[0], pixel[1], pixel[2]) )
      if( fondo != tospec(pixel[0], pixel[1], pixel[2]) ){
        if( tinta != fondo )
          printf("\nThe pixel (%d, %d) has a third color in the cell\n", j*16+l, i*16+k),
          exit(-1);
        tinta= tospec(pixel[0], pixel[1], pixel[2]);
      }
    celdas[k>>3<<1 | l>>3]<<= 1;
    celdas[k>>3<<1 | l>>3]|= fondo != tospec(pixel[0], pixel[1], pixel[2]);
  }
}

void atrgen(void){
  atr<<= 8;
  if( forceatr )
    atr|= fondo<<3&120 | tinta&7 | tinta<<3&64;
  else if( fondo==tinta ){
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

int exist(char *name){
  struct stat   buffer;
  return (stat (name, &buffer) == 0);
}

int main(int argc, char *argv[]){

// screens

  ft= fopen("gfx/screen.def", "r");
  fo= fopen("build/screen.bin", "wb+");
  k= j= 0;
  while ( fgets(tmpstr, 50, ft) ){
    if( tmpstr[8]=='"' ){
      strchr(tmpstr+9, '"')[1]= 0;
      sprintf(command, "bin\\Png2Rcs \"gfx\\%s build\\tmp.rcs build\\tmp.atr", tmpstr+9);
      fou= (char *) strchr(tmpstr+9, '.');
      fou[1]= 'a', fou[2]= 't', fou[3]= 'r', fou[4]= 0;
      sprintf(tmpstr, " -a \"gfx\\%s", tmpstr+9);
      if( exist(tmpstr+5) )
        strcat(command, tmpstr),
        strcat(command, "\"");
    }
    else{
      strchr(tmpstr+8, '\n')[0]= 0,
      sprintf(command, "bin\\Png2Rcs gfx\\%s build\\tmp.rcs build\\tmp.atr", tmpstr+8);
      fou= (char *) strchr(tmpstr+8, '.');
      fou[1]= 'a', fou[2]= 't', fou[3]= 'r';
      if( exist(tmpstr+8) )
        strcat(command, " -a gfx\\"),
        strcat(command, tmpstr+8);
    }
    if( system(command) )
      printf("\nError: plug error with command: %s\n", command),
      exit(-1);
    system("bin\\zx7b build\\tmp.rcs build\\tmp.rcs.zx7b");
    system("bin\\zx7b build\\tmp.atr build\\tmp.atr.zx7b");
    fi= fopen("build/tmp.atr.zx7b", "rb");
    j+= i= fread(output, 1, 0x300, fi);
    fwrite(output, 1, i, fo);
    fclose(fi);
    fi= fopen("build/tmp.rcs.zx7b", "rb");
    j+= i= fread(output, 1, 0x1800, fi);
    fwrite(output, 1, i, fo);
    fclose(fi);
    fi= fopen("build/tmp.atr", "rb");
    fseek(fi, 0, SEEK_END);
    i= ftell(fi),
    fclose(fi);
    output[0]= atoi(tmpstr+4)<<2&28 | atoi(tmpstr+4)<<5&224 | i-1>>8;
    fwrite(output, 1, 1, fo);
    j++;
    k+= 2;
    *(short*)(output-k+0x1900)= j;
  }
  for ( i= k; i; i-= 2 )
    *(short*)(output-i+0x1900)-= j+(k-i)+2;
  fclose(ft);
  fwrite(output-k+0x1900, 1, k, fo);
  fclose(fo);

// config

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
    else if( fou= (char *) strstr(tmpstr, "notabl") )
      notabl= atoi(fou+6);
    else if( fou= (char *) strstr(tmpstr, "bullet") )
      bullet= atoi(fou+6);
    else if( fou= (char *) strstr(tmpstr, "bulmax") )
      bulmax= atoi(fou+6);
    else if( fou= (char *) strstr(tmpstr, "sprmax") )
      sprmax= atoi(fou+6);
  }
  fclose(ft);

// tiles

  error= lodepng_decode32_file(&image, &width, &height, "gfx/tiles.png");
  if( error )
    printf("Error %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  if( width!= 256 )
    printf("Error. The width of tiles.png must be 256");
  if( exist("gfx/tiles.atr") )
    fi= fopen("gfx/tiles.atr", "rb"),
    fread(input, 1, 0x400, fi),
    fclose(fi),
    forceatr= 1;
  for ( i= 0; i < height>>4; i++ )
    for ( j= 0; j < 16; j++ ){
      celdas[0]= celdas[1]= celdas[2]= celdas[3]= atr= 0;
      pixel= &image[((j|i<<8)<<4)<<2];
      if( forceatr )
        tinta= input[i<<6 | j<<1]&7 | input[i<<6 | j<<1]>>3&8,
        fondo= input[i<<6 | j<<1]>>3&15;
      else
        fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
      for ( k= 0; k < 8; k++ )
        for ( l= 0; l < 8; l++ )
          celdagen();
      atrgen();
      pixel= &image[(((j|i<<8)<<4)|8)<<2];
      if( forceatr )
        tinta= input[i<<6 | j<<1 | 1]&7 | input[i<<6 | j<<1 | 1]>>3&8,
        fondo= input[i<<6 | j<<1 | 1]>>3&15;
      else
        fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
      for ( k= 0; k < 8; k++ )
        for ( l= 8; l < 16; l++ )
          celdagen();
      atrgen();
      pixel= &image[(((j|i<<8)<<4)|2048)<<2];
      if( forceatr )
        tinta= input[i<<6 | j<<1 | 32]&7 | input[i<<6 | j<<1 | 32]>>3&8,
        fondo= input[i<<6 | j<<1 | 32]>>3&15;
      else
        fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
      for ( k= 8; k < 16; k++ )
        for ( l= 0; l < 8; l++ )
          celdagen();
      atrgen();
      pixel= &image[(((j|i<<8)<<4)|2056)<<2];
      if( forceatr )
        tinta= input[i<<6 | j<<1 | 33]&7 | input[i<<6 | j<<1 | 33]>>3&8,
        fondo= input[i<<6 | j<<1 | 33]>>3&15;
      else
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
  ft= fopen("build/player.zx7b", "rb");
  i= 0;
  if( ft )
    fseek(ft, 0, SEEK_END),
    i= ftell(ft),
    fclose(ft);
  ft= fopen("build/define.asm", "wb+");
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
              "        DEFINE  offsey %d\n"
              "        DEFINE  notabl %d\n"
              "        DEFINE  bullet %d\n"
              "        DEFINE  bulmax %d\n"
              "        DEFINE  sprmax %d\n"
              "        DEFINE  player %d\n",
          tmode, pics, reppos, apics, smooth, clipup, clipdn, cliphr,
          safevr, safehr, offsex, offsey, notabl<<8, bullet, bulmax, sprmax, i);
  fclose(ft);
  printf("\nno index     %d bytes\n", pics*36);
  printf("index bitmap %d bytes\n", pics*5+reppos*32);
  printf("index attr   %d bytes\n", pics*33+apics*4);
  printf("full index   %d bytes\n", pics*2+reppos*32+apics*4);
  fo= fopen("build/tiles.bin", "wb+");
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
  error= lodepng_decode32_file(&image, &width, &height, "gfx/sprites.png");
  if( error )
    printf("\nError %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  fo= fopen("build/sprites.bin", "wb+");
  if( !fo )
    printf("\nCannot create sprites.bin\n"),
    exit(-1);
  for ( i= 0; i < 16; i++ )
    for ( j= 0; j < 8; j+= 2-smooth ){
      output[inipos= outpos]= 0;
      output[inipos+1]= 0xf8+offsey*8;
      outpos+= 2;
      nmin= nmax= 4;
      for ( k= 0; k < 16; k++ ){
        pics= mask= 0;
        if( height==32 )
          for ( l= 0; l < 16; l++ )
            pics|= image[(i>>3<<12 | (i&7)<<5 | k<<8 | l)<<2] ? 0x800000>>l+j : 0,
            mask|= image[(i>>3<<12 | (i&7)<<5 | k<<8 | 16 | l)<<2] ? 0 : 0x800000>>l+j;
        else
          for ( l= 0; l < 16; l++ )
            pics|= image[(i<<4 | k<<8 | l)<<2 ] ? 0x800000>>l+j : 0,
            mask|= image[(i<<4 | k<<8 | l)*4+3] ? 0x800000>>l+j : 0;
        for ( min= 0; min < 3 && !(mask&0xff<<(2-min<<3)); min++ );
        for ( max= 3; max && !(mask&0xff<<(3-max<<3)); max-- );
        if( k&1 ){
          if( min>amin ) min= amin;
          if( max<amax ) max= amax;
          if( min<max ){
            if( (nmin!=min) || (nmax!=max) )
              output[reppos= outpos]= min+1-(nmin>2?0:nmin)&3 | (max-min==2?0:max-min)<<2,
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
          amask= mask,
          amin= min,
          amax= max;
      }
      if( smooth ){
        iniposback= inipos;
        output[inipos= outpos]= 0;
        output[inipos+1]= 0xf8+offsey*8-1;
        outpos+= 2;
        nmin= nmax= 4;
        for ( k= -1; k < 17; k++ ){
          pics= mask= 0;
          if( k>-1 && k<16 )
            if( height==32 )
              for ( l= 0; l < 16; l++ )
                pics|= image[(i>>3<<12 | (i&7)<<5 | k<<8 | l)<<2] ? 0x800000>>l+j : 0,
                mask|= image[(i>>3<<12 | (i&7)<<5 | k<<8 | 16 | l)<<2] ? 0 : 0x800000>>l+j;
            else
              for ( l= 0; l < 16; l++ )
                pics|= image[(i<<4 | k<<8 | l)<<2 ] ? 0x800000>>l+j : 0,
                mask|= image[(i<<4 | k<<8 | l)*4+3] ? 0x800000>>l+j : 0;
          for ( min= 0; min < 3 && !(mask&0xff<<(2-min<<3)); min++ );
          for ( max= 3; max && !(mask&0xff<<(3-max<<3)); max-- );
          if( ~k&1 ){
            if( min>amin ) min= amin;
            if( max<amax ) max= amax;
            if( min<max ){
              if( (nmin!=min) || (nmax!=max) )
                output[reppos= outpos]= min+1-(nmin>2?0:nmin)&3 | (max-min==2?0:max-min)<<2,
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
            amask= mask,
            amin= min,
            amax= max;
        }
        if( inipos-iniposback<=outpos-inipos )
          output[(j|i<<3)>>1-smooth]= inipos-iniposback,
          outpos= inipos;
        else{
          output[(j|i<<3)>>1-smooth]= outpos-inipos;
          for ( l= iniposback; l<inipos; l++ )
            output[l]= output[l+inipos-iniposback];
          outpos-= inipos-iniposback;
        }
      }
      else
        output[(j|i<<3)>>1-smooth]= outpos-inipos;
    }
  fwrite(output, 1, outpos, fo);
  fclose(fo);
  free(image);

// bullet

  if( !bullet )
    printf("Files tiles.bin and sprites.bin generated in STEP 1\n"),
    exit(0);
  inipos= 0;
  outpos= 4<<smooth;
  error= lodepng_decode32_file(&image, &width, &height, "gfx/bullet.png");
  if( error )
    printf("\nError %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  fo= fopen("build/bullet.bin", "wb+");
  if( !fo )
    printf("\nCannot create bullet.bin\n"),
    exit(-1);
  for ( i= 0; i < 8; i+= 2-smooth ){
    output[inipos= outpos]= 0;
    output[inipos+1]= 0xfc+offsey*8;
    outpos+= 2;
    nmin= nmax= 4;
    for ( mask= k= 0; k < 8; k++ ){
      pics= 0;
      for ( l= 0; l < 8; l++ )
        pics|= image[(k<<3 | l)*4+3] ? 0x800000>>l+i : 0;
      for ( min= 0; min < 3 && !(pics&0xff<<(2-min<<3)); min++ );
      for ( max= 3; max && !(pics&0xff<<(3-max<<3)); max-- );
      if( k&1 ){
        if( min>amin ) min= amin;
        if( max<amax ) max= amax;
        if( min<max ){
          if( (nmin!=min) || (nmax!=max) )
            output[reppos= outpos]= min+1-(nmin>2?0:nmin)<<1&6 | max-min-1,
            outpos+= 2,
            output[inipos]++,
            output[reppos+1]= 0;
          mask+= 2;
          output[reppos+1]++;
          for ( l= min; l < max; l++ )
            output[outpos++]= apics>>(2-l<<3);
          for ( l= max; l > min; l-- )
            output[outpos++]= pics>>(3-l<<3);
        }
        else if( nmin==4 )
          output[inipos+1]+= 2;
        nmin= min;
        nmax= max;
      }
      else
        apics= pics,
        amin= min,
        amax= max;
    }
    if( smooth ){
      iniposback= inipos;
      output[inipos= outpos]= 0;
      output[inipos+1]= 0xfc+offsey*8;
      outpos+= 2;
      nmin= nmax= 4;
      for ( amask= k= -1; k < 9; k++ ){
        pics= 0;
        if( k>-1 && k<8 )
          for ( l= 0; l < 8; l++ )
            pics|= image[(k<<3 | l)*4+3] ? 0x800000>>l+i : 0;
        for ( min= 0; min < 3 && !(pics&0xff<<(2-min<<3)); min++ );
        for ( max= 3; max && !(pics&0xff<<(3-max<<3)); max-- );
        if( ~k&1 ){
          if( min>amin ) min= amin;
          if( max<amax ) max= amax;
          if( min<max ){
            if( (nmin!=min) || (nmax!=max) )
              output[reppos= outpos]= min+1-(nmin>2?0:nmin)<<1&6 | max-min-1,
              outpos+= 2,
              output[inipos]++,
              output[reppos+1]= 0;
            amask+= 2;
            output[reppos+1]++;
            for ( l= min; l < max; l++ )
              output[outpos++]= apics>>(2-l<<3);
            for ( l= max; l > min; l-- )
              output[outpos++]= pics>>(3-l<<3);
          }
          else if( nmin==4 )
            output[inipos+1]+= 2;
          nmin= min;
          nmax= max;
        }
        else
          apics= pics,
          amin= min,
          amax= max;
      }
      if( inipos-iniposback<=outpos-inipos )
        output[i>>1-smooth]= inipos-iniposback,
        outpos= inipos;
      else{
        mask= amask;
        output[i>>1-smooth]= outpos-inipos;
        for ( l= iniposback; l<inipos; l++ )
          output[l]= output[l+inipos-iniposback];
        outpos-= inipos-iniposback;
      }
    }
    else
      output[i>>1-smooth]= outpos-inipos;
  }
  ft= fopen("build/define.asm", "a");
  fseek(ft, 0, SEEK_END);
  fprintf(ft, "        DEFINE  bulmiy %d\n"
              "        DEFINE  bulmay %d\n",  0x100+offsey*8-output[inipos+1],
                                              output[inipos+1]-0xfc-offsey*8+mask);
  fclose(ft);
  fwrite(output, 1, outpos, fo);
  fclose(fo);
  free(image);
  printf("Files tiles.bin, sprites.bin and bullet.bin generated in STEP 1\n");
}
