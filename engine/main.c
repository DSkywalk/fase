#include  <stdlib.h>
#include  "fase.h"

#define gconst  20
#define maxvx   600
#define maxvy   600

extern unsigned char *ending;
const unsigned char data[20]= {
  0x00, 0x42, 0x11, 0,
  0x08, 0x60, 0x60, 2,
  0x09, 0x58, 0x48, 3,
  0x0a, 0x22, 0x02, 1,
  0x0b, 0x50, 0x6e, 2};

char i, j, killed, mapx, mapy, spacepressed, dirbul[4], num_bullets;
unsigned char tmpx, tmpy;
short x, vx, ax, y, vy, ay;
void remove_bullet( char k );
void update_screen();
void update_scoreboard();

main(){

start:
  killed= mapx= mapy= spacepressed= num_bullets= *shadow= 0;
  x= 0x3000;
  y= 0x1000;
  update_scoreboard();

  // inicializar engine
  INIT;

  // pasar datos a sprites y balas
  for ( i = 0; i < 5; i++ )
    sprites[i].n= data[0 | i<<2],
    sprites[i].x= data[1 | i<<2],
    sprites[i].y= data[2 | i<<2],
    sprites[i].f= data[3 | i<<2];
  for ( i = 0; i < 4; i++ )
    bullets[i].y= 255;

  // mostrar la primera pantalla al comienzo y marcador
  *screen= 0;

  while(1){

    // esto hace que el engine procese un frame generando el escenario
    M_OUTP(0xfe, 0);
    FRAME;
    M_OUTP(0xfe, 2);

    // movimiento de los enemigos
    for ( i = 1; i < 5; i++ )
      if( sprites[i].n<0x80 ){
        for ( j= 0; j < num_bullets; j++ )
          if( abs(bullets[j].x-sprites[i].x) + abs(bullets[j].y-sprites[i].y) < 10 ){
            sprites[i].n+= 0x80;
            remove_bullet( j );
            tmpx= sprites[i].x>>4;
            tmpy= sprites[i].y>>4;
            tiles[tmpy*scrw+tmpx]= 68;
            tilepaint(tmpx, tmpy, tmpx, tmpy);
            killed++;
            if( killed==10 ){
              EXIT;
              Dzx7b((unsigned int) (&ending-1), 0x5aff);
              Pause(100);
              goto start;
            }
            *drwout= (unsigned int)update_scoreboard;
          }
        if( sprites[i].f&1 )
          if( sprites[i].y>0 )
            sprites[i].y--;
          else
            sprites[i].f^= 1;
        else
          if( sprites[i].y<scrh*16 )
            sprites[i].y++;
          else
            sprites[i].f^= 1;
        if( sprites[i].f&2 )
          if( sprites[i].x>0 )
            sprites[i].x--;
          else
            sprites[i].f^= 2;
        else
          if( sprites[i].x<scrw*16 )
            sprites[i].x++;
          else
            sprites[i].f^= 2;
      }

    // movimiento de las balas
    for ( i = 0; i < num_bullets; i++ ){
      if( dirbul[i]&3 ){
        if( dirbul[i]&1 ){
          if( bullets[i].x<scrw*16 )
            bullets[i].x+= 2;
          else
            remove_bullet( i );
        }
        else{
          if( bullets[i].x>2 )
            bullets[i].x-= 2;
          else
            remove_bullet( i );
        }
      }
      if( dirbul[i]&12 ){
        if( dirbul[i]&4 ){
          if( bullets[i].y<scrh*16 )
            bullets[i].y+= 2;
          else
            remove_bullet( i );
        }
        else{
          if( bullets[i].y>2 )
            bullets[i].y-= 2;
          else
            remove_bullet( i );
        }
      }
    }



    vx+= ax;
    x+= vx;
    if( vx+8>>3 )
      ax= -vx>>3;
    else
      ax= vx= 0;
    if( (unsigned int)x > scrw<<12 )
      if( vx>0 )
        if( mapx < mapw-1 )
          x= 0,
          mapx++,
          update_screen();
        else
          x= scrw<<12,
          vx= 0;
      else if( mapx )
        x= scrw<<12,
        mapx--,
        update_screen();
      else
        vx= x= 0;
    sprites[0].x= x>>8;

    if( vy>maxvy )
      vy= maxvy;
    else
      vy+= ay+gconst;
    if( (unsigned int)y <= 15<<11 )
      y+= vy;
    else
      vy= 0,
      y= 15<<11;
    sprites[0].y= y>>8;


    // movimiento del protagonista
    if( inKey(KeybYUIOP) & 0x01 ) // P
      ax= vx<maxvx ? 40 : 0;
    else if( inKey(KeybYUIOP) & 0x02 ) // O
      ax= vx>-maxvx ? -40 : 0;
    if( inKey(KeybGFDSA) & 0x01 ){ // A
/*    if( sprites[0].y<scrh*16 )
        sprites[0].y++;
      else if( mapy < maph-1 )
        sprites[0].y= 0,
        mapy++,
        update_screen();*/
    }
    else if( inKey(KeybTREWQ) & 0x01 ){ // Q
      if( (unsigned int)y == 15<<11 )
        vy= -800;
    }
    if( inKey(KeybBNMs_) & 0x01 && !spacepressed && num_bullets<4 ){ // Space
      bullets[num_bullets].x= sprites[0].x;
      bullets[num_bullets].y= sprites[0].y;
      i= inKey(KeybTREWQ)<<3&8 | inKey(KeybGFDSA)<<2&4 | inKey(KeybYUIOP)&3;
      dirbul[num_bullets]= i ? i : 1;
      num_bullets++;
    }
    spacepressed= inKey(KeybBNMs_) & 0x01;
  }
}

void remove_bullet( char k ){
  if( num_bullets ){
    num_bullets--;
    while ( k<num_bullets )
      dirbul[k]= dirbul[k+1],
      bullets[k].x= bullets[k+1].x,
      bullets[k].y= bullets[++k].y;
    bullets[k].y= 255;
  }
}

void update_screen(){
  *screen= mapy*mapw + mapx;
  for ( j= 1; j < 5; j++ )
    if( sprites[j].n>0x7f )
      sprites[j].n-= 0x80;
}

void update_scoreboard(){
  unsigned int scr, dst;
  char count;
  scr= 0x3d80+killed*8;
  dst= 0x50de|*shadow<<8;
  for ( count= 0; count<8; count++ )
    zxmem[dst]= zxmem[scr++]^0xff,
    dst+= 0x100;
}

    #asm
        BINARY  "ending.rcs.zx7b"
._ending
    #endasm

