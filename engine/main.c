#include  "fase.h"
#include  "ending.h"

const unsigned char data[20]= {
  0x00, 0x42, 0x11, 0,
  0x08, 0x60, 0x60, 2,
  0x09, 0x58, 0x48, 3,
  0x0a, 0x22, 0x02, 1,
  0x0b, 0x50, 0x6e, 2};

char i, j, killed, x, y, spacepressed, dirbul[4], num_bullets;
unsigned char tmpx, tmpy;
void remove_bullet( char k );
void update_screen();
void update_scoreboard();

main(){

start:
  killed= x= y= spacepressed= num_bullets= shadow= 0;
  update_scoreboard();

  // inicializar engine
  INIT;

  // pasar datos a sprites y balas
  for ( i = 0; i < 20; i++ )
    sprites[i>>2][i&3]= data[i];
  for ( i = 0; i < 4; i++ )
    bullets[i][1]= 255;

  // mostrar la primera pantalla al comienzo y marcador
  screen= 0;
  
  while(1){

    // esto hace que el engine procese un frame generando el escenario
    FRAME;

    // movimiento de los enemigos
    for ( i = 1; i < 5; i++ )
      if( sprites[i][0]<0x80 ){
        for ( j= 0; j < num_bullets; j++ )
          if( ( (sprites[i][1]<bullets[j][0]?bullets[j][0]-sprites[i][1]:sprites[i][1]-bullets[j][0])
              + (sprites[i][2]<bullets[j][1]?bullets[j][1]-sprites[i][2]:sprites[i][2]-bullets[j][1]))<10 ){
            sprites[i][0]-= 0x80;
            remove_bullet( j );
            tmpx= sprites[i][1]>>4;
            tmpy= sprites[i][2]>>4;
            tiles[tmpy*scrw+tmpx]= 68;
            tilepaint(tmpx, tmpy, tmpx, tmpy);
            killed++;
            if( killed==10 ){
              EXIT;
              DZX7B((unsigned int)&ending_zx7[ending_zx7_size-1], 0x5aff);
              PAUSE(100);
              __asm
                  ld      hl, #-6
                  add     hl, sp
                  ld      sp, hl
              __endasm;
              goto start;
            }
            drwout= (unsigned int)update_scoreboard;
          }
        if( sprites[i][3]&1 )
          if( sprites[i][2]>0 )
            sprites[i][2]--;
          else
            sprites[i][3]^= 1;
        else
          if( sprites[i][2]<scrh*16 )
            sprites[i][2]++;
          else
            sprites[i][3]^= 1;
        if( sprites[i][3]&2 )
          if( sprites[i][1]>0 )
            sprites[i][1]--;
          else
            sprites[i][3]^= 2;
        else
          if( sprites[i][1]<scrw*16 )
            sprites[i][1]++;
          else
            sprites[i][3]^= 2;
      }

    // movimiento de las balas
    for ( i = 0; i < num_bullets; i++ ){
      if( dirbul[i]&3 ){
        if( dirbul[i]&1 ){
          if( bullets[i][0]<scrw*16 )
            bullets[i][0]+= 2;
          else
            remove_bullet( i );
        }
        else{
          if( bullets[i][0]>2 )
            bullets[i][0]-= 2;
          else
            remove_bullet( i );
        }
      }
      if( dirbul[i]&12 ){
        if( dirbul[i]&4 ){
          if( bullets[i][1]<scrh*16 )
            bullets[i][1]+= 2;
          else
            remove_bullet( i );
        }
        else{
          if( bullets[i][1]>2 )
            bullets[i][1]-= 2;
          else
            remove_bullet( i );
        }
      }
    }

    // movimiento del protagonista
    if( ~KeybYUIOP & 0x01 ){ // P
      if( sprites[0][1]<scrw*16 )
        sprites[0][1]++;
      else if( x < mapw-1 )
        sprites[0][1]= 0,
        x++,
        update_screen();
    }
    else if( ~KeybYUIOP & 0x02 ){ // O
      if( sprites[0][1]>0 )
        sprites[0][1]--;
      else if( x )
        sprites[0][1]= scrw*16,
        x--,
        update_screen();
    }
    if( ~KeybGFDSA & 0x01 ){ // A
      if( sprites[0][2]<scrh*16 )
        sprites[0][2]++;
      else if( y < maph-1 )
        sprites[0][2]= 0,
        y++,
        update_screen();
    }
    else if( ~KeybTREWQ & 0x01 ){ // Q
      if( sprites[0][2]>0 )
        sprites[0][2]--;
      else if( y )
        sprites[0][2]= scrh*16,
        y--,
        update_screen();
    }
    if( ~KeybBNMs_ & 0x01 && !spacepressed && num_bullets<4 ){ // Space
      bullets[num_bullets][0]= sprites[0][1];
      bullets[num_bullets][1]= sprites[0][2];
      i= ~(KeybTREWQ<<3&8 | KeybGFDSA<<2&4 | KeybYUIOP&3) & 15;
      dirbul[num_bullets]= i ? i : 1;
      num_bullets++;
    }
    spacepressed= ~KeybBNMs_ & 0x01;
  }
}

void remove_bullet( char k ){
  num_bullets--;
  while ( k<num_bullets )
    dirbul[k]= dirbul[k+1],
    bullets[k][0]= bullets[k+1][0],
    bullets[k][1]= bullets[++k][1];
  bullets[k][1]= 255;
}

void update_screen(){
  screen= y*mapw + x;
  for ( j= 1; j < 5; j++ )
    if( sprites[j][0]>0x7f )
      sprites[j][0]-= 0x80;
}

void update_scoreboard(){
  unsigned int scr, dst;
  char count;
  scr= 0x3d80+killed*8;
  dst= 0x50de|shadow<<8;
  for ( count= 0; count<8; count++ )
    zxmem[dst]= zxmem[scr++]^0xff,
    dst+= 0x100;
}
