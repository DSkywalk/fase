const offsex= 1;
const offsey= 0;
const bulmax= 4;
const sprmax= 5;

const gconst= 20;
const maxvx= 600;
const maxvy= 600;

function remove_bullet( k ){
  if( num_bullets ){
    num_bullets--;
    while ( k<num_bullets )
      dirbul[k]= dirbul[k+1],
      bullets[k].x= bullets[k+1].x,
      bullets[k].y= bullets[++k].y;
    bullets[k].y= 255;
  }
}

function update_scoreboard(){
  ct2.fillRect(240, 176, 8, 8);
  ct2.drawImage(digits, killed<<3, 0, 8, 8, 240, 176, 8, 8);
}

function show_ending(frames){
  nframes= frames;
  ending.width= width;
  ending.height= height;
  ending.style.left= marginLeft+8+'px';
  ending.style.top= marginTop+8+'px';
  document.body.appendChild(ending);
  clearInterval(interval);
  interval= setInterval(delay, 20);
}

function delay(){
  if( --nframes==0 )
    clearInterval(interval),
    document.body.removeChild(ending),
    start();
}

function update_screen(){
  scrn= mapy*mapw + mapx;
  for ( j= 1; j < 5; j++ )
    if( sprites[j].n>0x7f )
      sprites[j].n-= 0x80;
}

function init(){
  data= [
  0x00, 0x42, 0x11, 0,
  0x08, 0x60, 0x60, 2,
  0x09, 0x58, 0x48, 3,
  0x0a, 0x22, 0x02, 1,
  0x0b, 0x50, 0x6e, 2];
  dirbul= [];
  digits= new Image();
  digits.src= 'gfx/digits.png';
  ending= document.createElement('img');
  ending.src= 'gfx/ending.jpg';
  ending.style.position= 'absolute';
  start();
}

function start(){

  salto= vx= ax= vy= ay= killed= mapx= mapy= spacepressed= num_bullets= 0;
  x= 0x3000;
  y= 0x1000;

  update_scoreboard();

  // pasar datos a sprites y balas
  for ( i = 0; i < sprmax; i++ )
    sprites[i].n= data[0 | i<<2],
    sprites[i].x= data[1 | i<<2],
    sprites[i].y= data[2 | i<<2],
    sprites[i].f= data[3 | i<<2];
  for ( i = 0; i < bulmax; i++ )
    bullets[i].y= 255;

  // mostrar la primera pantalla al comienzo
  scrn= 0;

  interval= setInterval(frame, 20);
}

function frame(){
  FRAME();

  // movimiento de los enemigos
  for ( i = 1; i < 5; i++ )
    if( sprites[i].n<0x80 ){
      for ( j= 0; j < num_bullets; j++ )
        if( Math.abs(bullets[j].x-sprites[i].x) + Math.abs(bullets[j].y-sprites[i].y) < 10 ){
          sprites[i].n+= 0x80;
          remove_bullet( j );
          tmpx= sprites[i].x>>4;
          tmpy= sprites[i].y>>4;
          tiles[tmpy*scrw+tmpx]= 68;
          tilepaint(tmpx, tmpy, tmpx, tmpy);
          killed++;
          if( killed==10 )
            show_ending(100);
          update_scoreboard();
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
  if( (x&0xffff) > scrw<<12 )
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
  if( y <= 15<<11 )
    y+= vy;
  else
    vy= 0,
    y= 15<<11;
  sprites[0].y= y>>8;


  // movimiento del protagonista
  if( kb[4] & 0x01 ) // P
    ax= vx<maxvx ? 40 : 0;
  else if( kb[4] & 0x04 ) // O
    ax= vx>-maxvx ? -40 : 0;
//  if( kb[5] & 0x80 ){ // A
//  }
  if( kb[4] & 0x02 ){ // Q
    salto++;
    if( y == 15<<11 )
      vy= -800;
  }
  else{
    salto= 0;
  }
  if( kb[1] & 0x40 && !spacepressed && num_bullets<4 ){ // Space
    bullets[num_bullets].x= sprites[0].x;
    bullets[num_bullets].y= sprites[0].y;
    i= kb[4]<<2&8 | kb[5]>>5&4 | kb[4]>>1&2 | kb[4]&1;
    dirbul[num_bullets]= i ? i : 1;
    num_bullets++;
  }
  spacepressed= kb[1] & 0x40;

}