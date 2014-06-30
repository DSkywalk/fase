#ifndef __LIBRARY_FASE__
#include "build/define.h"
#define __LIBRARY_FASE__

#define Init        \
    asm             \
        call $fffc  \
    end asm

#define Frame       \
    asm             \
        call $fff9  \
    end asm

#define Exit        \
    asm             \
        call $fff6  \
    end asm

#define DisableInt  \
    asm             \
        di          \
    end asm

#define SetSpriteV(number, value)   poke $5b00+(number)*4, (value)
#define GetSpriteV(number)          peek ($5b00+(number)*4)
#define SetSpriteX(number, value)   poke $5b01+(number)*4, (value)
#define GetSpriteX(number)          peek ($5b01+(number)*4)
#define SetSpriteY(number, value)   poke $5b02+(number)*4, (value)
#define GetSpriteY(number)          peek ($5b02+(number)*4)
#define SetSpriteZ(number, value)   poke $5b03+(number)*4, (value)
#define GetSpriteZ(number)          peek ($5b03+(number)*4)
  
#define SetBulletX(number, value)   poke $5b30+(number)*2, (value)
#define GetBulletX(number)          peek ($5b30+(number)*2)
#define SetBulletY(number, value)   poke $5b31+(number)*2, (value)
#define GetBulletY(number)          peek ($5b31+(number)*2)
#define SetTile(number, value)      poke $5b40+(number), (value)
#define GetTile(number)             peek ($5b40+(number))
#define TilePaint(from_x, from_y, to_x, to_y) repaint= CAST(uinteger, from_x|from_y<<4)|CAST(uinteger, to_x|to_y<<4)<<8

#define EFFX  4
#define STOP  7
#define LOAD  10

#if player
  #define Sound(func, param) callsound(func|CAST(uinteger, param)<<8)
#else
  #define Sound(func, param)
#endif

dim scr     as ubyte    at $5c00
dim shadow  as ubyte    at $5c01
dim repaint as uinteger at $5c02
dim drwout  as uinteger at $5c06

sub FASTCALL pausa( time as uinteger )
  asm
loop1:  ld      bc, 21
loop2:  djnz    loop2
        dec     c
        jr      nz, loop2
        dec     hl
        ld      a, l
        or      h
        jr      nz, loop1
  end asm
end sub

sub FASTCALL dzx7b( source as uinteger, addr as uinteger )
  asm
        pop     af
        pop     de
        push    af
        jp      dzx7a
  end asm
end sub

#if player
sub FASTCALL callsound( source as uinteger )
  asm
        ld      a, ($fff6)
        cp      $c3
        jr      nz, beep
        ld      bc, $7ffd
        ld      a, $11
        out     (c), a
        ld      a, h
        ld      h, $c0
        call    $162c
        ld      bc, $7ffd
        ld      a, $10
        out     (c), a
        ret
beep:   ld      a, l
        sub     EFFX+1
        ret     nc
        ld      d, a
        sub     h
        add     a, a
        ld      e, a
        ld      hl, ($fffa)
        ex      de, hl
        add     hl, de
        inc     de
        ldi
        ld      a, (hl)
        ld      (de), a
  end asm
end sub
#endif

#endif