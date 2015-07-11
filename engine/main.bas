#include <keys.bas>
#include "fase.bas"

#define   gconst  20
#define   maxvx   600
#define   maxvy   600

dim dirbul(3) as ubyte
dim datos(19) as ubyte = { _
    $00, $42, $11, 0, _
    $08, $60, $60, 2, _
    $09, $a8, $48, 3, _
    $0a, $22, $02, 1, _
    $0c, $d0, $6e, 2}

dim i, j, mapx, mapy, spacepressed, killed, numbullets as byte
dim x, vx, ax, y, vy, ay as integer
dim tmpx, tmpy as ubyte
dim points as uinteger

function abso( a as ubyte, b as ubyte ) as uinteger
  if b<a then
    return a-b
  else
    return b-a
  end if
end function

sub FASTCALL updatescreen()
  scr= mapy*mapw + mapx
  for j = 1 to 4
    if GetSpriteV(j) > $7f then
      SetSpriteV(j, GetSpriteV(j)-$80)
    end if
  next j
end sub

sub FASTCALL updatescoreboard()
  points= $30 | killed
  PrintStr(@points, $1e01)
end sub

sub removebullet( k as ubyte )
  if numbullets then
    numbullets= numbullets-1
    while k < numbullets
      dirbul(k)= dirbul(k+1)
      SetBulletX(k, GetBulletX(k+1))
      SetBulletY(k, GetBulletY(k+1))
      k= k+1
    end while
    SetBulletY(k, 255)
  end if
end sub

  DisableInt

start:
  Sound(LOAD, 0)
  if is128 then
    EnableInt
    intadr= @IsrSound
  end if
  while 1
    i= in($f7fe) & $1f
    if i=$1e then
      poke uinteger @Inputs+1, @Joystick
      exit while
    elseif i=$1d then
      poke uinteger @Inputs+1, @Cursors
      exit while
    elseif i=$1b then
      poke uinteger @Inputs+1, @Keyboard
      exit while
    elseif i=$17 then
      Redefine()
    end if
  end while
  DisableInt
  killed= 0
  mapx= 0
  mapy= 0
  x= $3000
  y= $1000
  spacepressed= 0
  numbullets= 0
  shadow= 0

  updatescoreboard()

  Init
  Sound(LOAD, 1)

  for i = 0 to 4
    SetSpriteV(i, datos(i*4))
    SetSpriteX(i, datos(i*4+1))
    SetSpriteY(i, datos(i*4+2))
    SetSpriteZ(i, datos(i*4+3))
  next i
  for i = 0 to 3
    SetBulletY(i, 255)
  next i

  scr= 0

  while 1
'    border 0
    Frame
'    border 2

    for i = 1 to 4
      if GetSpriteV(i) < $80 then
        for j = 0 to numbullets-1
          if abso(GetSpriteX(i), GetBulletX(j))+abso(GetSpriteY(i), GetBulletY(j)) < 10 then
            SetSpriteV(i, GetSpriteV(i)-$80)
            removebullet(j)
            tmpx= GetSpriteX(i)>>4
            tmpy= GetSpriteY(i)>>4
            SetTile(tmpy*scrw+tmpx, 68)
            TilePaint(tmpx, tmpy, tmpx, tmpy)
            Sound(EFFX, 1+(killed Mod 5))
            killed= killed+1
            if killed=10 then
              Sound(STOP, 0)
              Exit
              Bitmap(1, 0)
              pausa(50)
              Bitmap(3, 1)
              pausa(50)
              Bitmap(2, 1)
              pausa(50)
              Bitmap(0, 0)
              goto start
            end if
            drwout= @updatescoreboard
          end if
        next j
        if GetSpriteZ(i) & 1 then
          if GetSpriteY(i) > 0 then
            SetSpriteY(i, GetSpriteY(i)-1)
          else
            SetSpriteZ(i, GetSpriteZ(i) ~ 1)
          end if
        else
          if GetSpriteY(i) < scrh*16 then
            SetSpriteY(i, GetSpriteY(i)+1)
          else
            SetSpriteZ(i, GetSpriteZ(i) ~ 1)
          end if
        end if
        if GetSpriteZ(i) & 2 then
          if GetSpriteX(i) > 0 then
            SetSpriteX(i, GetSpriteX(i)-1)
          else
            SetSpriteZ(i, GetSpriteZ(i) ~ 2)
          end if
        else
          if GetSpriteX(i) < scrw*16 then
            SetSpriteX(i, GetSpriteX(i)+1)
          else
            SetSpriteZ(i, GetSpriteZ(i) ~ 2)
          end if
        end if
      end if
    next i

    for i = 0 to numbullets-1
      if dirbul(i) & 3 then
        if dirbul(i) & 1 then
          if GetBulletX(i) < scrw*16 then
            SetBulletX(i, GetBulletX(i)+4)
          else
            removebullet(i)
          end if
        else
          if GetBulletX(i) > 4 then
            SetBulletX(i, GetBulletX(i)-4)
          else
            removebullet(i)
          end if
        end if
      end if
      if dirbul(i) & 12 then
        if dirbul(i) & 4 then
          if GetBulletY(i) < scrh*16 then
            SetBulletY(i, GetBulletY(i)+4)
          else
            removebullet(i)
          end if
        else
          if GetBulletY(i) > 4 then
            SetBulletY(i, GetBulletY(i)-4)
          else
            removebullet(i)
          end if
        end if
      end if
    next i

    vx= vx + ax
    x= x + vx
    if vx + 8 >> 3 then
      ax = -vx >> 3
    else
      vx = 0
      ax = 0
    end if
    if CAST(uinteger, x) > scrw << 12 then
      if vx > 0 then
        if mapx < mapw - 1 then
          x = 0
          mapx = mapx + 1
          updatescreen()
        else
          x = scrw << 12
          vx = 0
        end if
      else
        if mapx then
          x = scrw << 12
          mapx = mapx - 1
          updatescreen()
        else
          vx = 0
          x = 0
        end if
      end if
    end if
    SetSpriteX(0, x >> 8)

    if vy > maxvy then
      vy = maxvy
    else
      vy = vy + ay + gconst
    end if
    if CAST(uinteger, y) <= 15 << 11 then
      y = y + vy
    else
      vy = 0
      y = 15 << 11
    end if
    SetSpriteY(0, y >> 8)

    if Inputs() & RIGHT then
      if vx<maxvx then
        ax = 40
      else
        ax = 0
      end if
    end if
    if Inputs() & LEFT then
      if vx>-maxvx then
        ax = -40
      else
        ax = 0
      end if
    end if
    if Inputs() & UP then
      if y = 15<<11 then
        vy = -800
      end if
    end if
    if Inputs() & FIRE and (not spacepressed) and numbullets<4 then
      Sound(EFFX, 0)
      SetBulletX(numbullets, GetSpriteX(0))
      SetBulletY(numbullets, GetSpriteY(0))
      i= Inputs() & (RIGHT | LEFT | UP | DOWN)
      if i then
        dirbul(numbullets)= i
      else
        dirbul(numbullets)= 1
      end if
      numbullets= numbullets+1
    end if
    spacepressed= Inputs() & FIRE
  end while
