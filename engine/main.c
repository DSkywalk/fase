#include  <stdlib.h>
#include  "fase.h"

#define gconst  20
#define maxvx   600
#define maxvy   600

unsigned char data[20]= {
  0x00, 0x42, 0x11, 0,
  0x08, 0x60, 0x60, 2,
  0x09, 0x58, 0x48, 3,
  0x0a, 0x22, 0x02, 1,
  0x0c, 0x50, 0x6e, 2};

char i, j, killed, mapx, mapy, spacepressed, dirbul[4], num_bullets;
unsigned char tmpx, tmpy;
short x, vx, ax, y, vy, ay;
void remove_bullet( char k );
void update_screen();
void update_scoreboard();

main(){

start:
  Sound(LOAD, 0);
  if( *is128 ){
    EI;
    *intadr= IsrSound;
  }
  while ( 1 ){
    i= inp(0xf7fe) & 0x1f;
    if( i==0x1e ){
      Input= Joystick;
      break;
    }
    else if( i==0x1d ){
      Input= Cursors;
      break;
    }
    else if( i==0x1b ){
      Input= Keyboard;
      break;
    }
    else if( i==0x17 ){
      Redefine();
    }
  }
  DI;
  killed= mapx= mapy= spacepressed= num_bullets= *shadow= 0;
  x= 0x3000;
  y= 0x1000;
  update_scoreboard();

  // inicializar engine
  INIT;
  Sound(LOAD, 1);

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
//    M_OUTP(0xfe, 0);
    FRAME;
//    M_OUTP(0xfe, 2);

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
            Sound(EFFX, 1+killed++%5);
            if( killed==10 ){
              Sound(STOP, 0);
              EXIT;
              Bitmap(1, 0);
              Pause(50);
              Bitmap(3, 1);
              Pause(50);
              Bitmap(2, 1);
              Pause(50);
              Bitmap(0, 0);
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
            bullets[i].x+= 4;
          else
            remove_bullet( i );
        }
        else{
          if( bullets[i].x>4 )
            bullets[i].x-= 4;
          else
            remove_bullet( i );
        }
      }
      if( dirbul[i]&12 ){
        if( dirbul[i]&4 ){
          if( bullets[i].y<scrh*16 )
            bullets[i].y+= 4;
          else
            remove_bullet( i );
        }
        else{
          if( bullets[i].y>4 )
            bullets[i].y-= 4;
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
    if( Input() & 0x01 ) // P
      ax= vx<maxvx ? 40 : 0;
    else if( Input() & 0x02 ) // O
      ax= vx>-maxvx ? -40 : 0;
    if( Input() & 0x08 ){ // Q
      if( (unsigned int)y == 15<<11 )
        vy= -800;
    }
    if( Input() & 0x10 && !spacepressed && num_bullets<4 ){ // Space
      Sound(EFFX, 0);
      bullets[num_bullets].x= sprites[0].x;
      bullets[num_bullets].y= sprites[0].y;
      i= Input() & 0x0f;
      dirbul[num_bullets]= i ? i : 1;
      num_bullets++;
    }
    spacepressed= Input() & 0x10;
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
  dst= 0x403e|*shadow<<8;
  for ( count= 0; count<8; count++ )
    zxmem[dst]= zxmem[scr++]^0xff,
    dst+= 0x100;
}
