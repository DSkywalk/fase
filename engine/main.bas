#include <keys.bas>
#include "fase.bas"

dim dirbul(3) as ubyte
dim datos(19) as ubyte = { _
    $00, $42, $11, 0, _
    $08, $60, $60, 2, _
    $09, $a8, $48, 3, _
    $0a, $22, $02, 1, _
    $0c, $d0, $6e, 2}
dim i, j, x, y, spacepressed, killed, numbullets as byte
dim tmpx, tmpy as ubyte

function abso( a as ubyte, b as ubyte ) as uinteger
  if b<a then
    return a-b
  else
    return b-a
  end if
end function

sub updatescreen()
  scr= y*mapw + x
  for j = 1 to 4
    if GetSpriteV(j) > $7f then
      SetSpriteV(j, GetSpriteV(j)-$80)
    end if
  next j
end sub

sub updatescoreboard()
  dim scr, dst as uinteger
  dim count as ubyte
  scr= $3d80+CAST(uinteger, killed)*8
  dst= $403e|CAST(uinteger, shadow)<<8
  for count = 0 to 7
    poke dst, (peek scr ~ $ff)
    scr= scr+1
    dst= dst+$100
  next count
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
  killed= 0
  x= 0
  y= 0
  spacepressed= 0
  numbullets= 0
  shadow= 0

  updatescoreboard()

  Init
  Sound(LOAD, 0)

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

    Frame

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
              dzx7b(@image-1, $5aff)
              pausa(100)
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

    if multikeys(KEYP) then
      if GetSpriteX(0) < scrw*16 then
        SetSpriteX(0, GetSpriteX(0)+1)
      elseif x < mapw-1 then
        SetSpriteX(0, 0)
        x= x + 1
        updatescreen()
      end if
    end if
    if multikeys(KEYO) then
      if GetSpriteX(0) > 0 then
        SetSpriteX(0, GetSpriteX(0)-1)
      elseif x then
        SetSpriteX(0, scrw*16)
        x= x - 1
        updatescreen()
      end if
    end if
    if multikeys(KEYA) then
      if GetSpriteY(0) < scrh*16 then
        SetSpriteY(0, GetSpriteY(0)+1)
      elseif y < maph-1 then
        SetSpriteY(0, 0)
        y= y + 1
        updatescreen()
      end if
    end if
    if multikeys(KEYQ) then
      if GetSpriteY(0) > 0 then
        SetSpriteY(0, GetSpriteY(0)-1)
      elseif y then
        SetSpriteY(0, scrh*16)
        y= y - 1
        updatescreen()
      end if
    end if
    if multikeys(KEYSPACE) and (not spacepressed) and numbullets<4 then
      Sound(EFFX, 0)
      SetBulletX(numbullets, GetSpriteX(0))
      SetBulletY(numbullets, GetSpriteY(0))
      i= (multikeys(KEYQ)<<3&8 | multikeys(KEYA)<<2&4 | multikeys(KEYO|KEYP)&3) & 15
      if i then
        dirbul(numbullets)= i
      else
        dirbul(numbullets)= 1
      end if
      numbullets= numbullets+1
    end if
    spacepressed= multikeys(KEYSPACE)
  end while

  asm
        incbin  "ending.rcs.zx7b"
  end asm
image:
