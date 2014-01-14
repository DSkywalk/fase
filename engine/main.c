#include  "bunuelera.h"

const unsigned char data[32]= {
  0x00, 0x42, 0x11, 0,
  0x08, 0x60, 0x60, 2,
  0x09, 0xa8, 0x48, 3,
  0x0a, 0x22, 0x02, 1,
  0x0b, 0xd0, 0x6e, 2,
  0x0c, 0xb6, 0x34, 3,
  0x0d, 0x32, 0x32, 1,
  0x04, 0x52, 0x5e, 0};

int main(){

  // variables
  int i, x= 0, y= 0;

  // pasar personajes a sprites
  for ( i = 0; i < 32; i++ )
    sprites[i>>2][i&3]= data[i];

  // inicializar engine
  INIT;

  // mostrar la primera pantalla al comienzo
  screen= 0;

  while(1){

    // esto hace que el engine procese un frame generando el escenario
    FRAME;

    // movimiento de los enemigos
    for ( i = 1; i < 8; i++ ){
      if( sprites[i][3]&1 )
        if( sprites[i][2] )
          sprites[i][2]--;
        else
          sprites[i][3]^= 1;
      else
        if( sprites[i][2]<0x90 )
          sprites[i][2]++;
        else
          sprites[i][3]^= 1;
      if( sprites[i][3]&2 )
        if( sprites[i][1]>0x08 )
          sprites[i][1]--;
        else
          sprites[i][3]^= 2;
      else
        if( sprites[i][1]<0xe8 )
          sprites[i][1]++;
        else
          sprites[i][3]^= 2;
    }

    // movimiento del protagonista
    if( ~KeybYUIOP & 0x01 ){ // P
      if( sprites[0][1]<0xee )
        sprites[0][1]++;
      else if( x < 11 )
        sprites[0][1]= 0x02,
        screen= y*12 + ++x;
    }
    else if( ~KeybYUIOP & 0x02 ){ // O
      if( sprites[0][1]>0x02 )
        sprites[0][1]--;
      else if( x )
        sprites[0][1]= 0xee,
        screen= y*12 + --x;
    }
    if( ~KeybGFDSA & 0x01 ){ // A
      if( sprites[0][2]<0xa0 )
        sprites[0][2]++;
      else if( y < 1 )
        sprites[0][2]= 0x01,
        screen= (++y)*12 + x;
    }
    else if( ~KeybTREWQ & 0x01 ){ // Q
      if( sprites[0][2]>0x01 )
        sprites[0][2]--;
      else if( y )
        sprites[0][2]= 0xa0,
        screen= (--y)*12 + x;
    }
  }
}