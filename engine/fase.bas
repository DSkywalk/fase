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

#define EnableInt   \
    asm             \
        ei          \
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
#define Bitmap(func, param)         CallBitmap(func|param<<8)

#define EFFX  4
#define STOP  7
#define LOAD  10
#define sKEY  $427f
#define QKEY  $42fb
#define AKEY  $42fd
#define OKEY  $4adf
#define PKEY  $42df
#define RIGHT 1
#define LEFT  2
#define DOWN  4
#define UP    8
#define FIRE  16

#if player
  #define Sound(func, param) callsound(func|CAST(uinteger, param)<<8)
#else
  #define Sound(func, param)
#endif

dim scr     as ubyte    at $5c00
dim shadow  as ubyte    at $5c01
dim repaint as uinteger at $5c02
dim drwout  as uinteger at $5c06
dim intadr  as uinteger at $fff5
dim is128   as ubyte    at $fff7

function FASTCALL Joystick () as ubyte
  asm
        ld      bc, $effe
        in      b, (c)
        in      a, ($1f)
        ld      c, a
        xor     a
        rr      b
        adc     a, a
        rr      b
        adc     a, a
        rr      b
        adc     a, a
        rlca
        rlca
        xor     b
        and     $fc
        xor     b
        cpl
        or      c
        and     $1f
        ld      l, a
  end asm
end function

function FASTCALL Cursors () as ubyte
  asm
        ld      a, $ef
        in      a, ($fe)
        ld      b, a
        ld      a, $f7
        in      a, ($fe)
        rlca
        and     b
        ld      c, a            ; 00LDUR0F  
        rrca
        rrca                    ; 0F00LDUR
        xor     c
        and     $68
        xor     c               ; 0F0DLR0F
        rrca                    ; F0F0DLR0
        rrca                    ; 0F0F0DLR
        xor     b
        and     $f7
        xor     b               ; 0F0FUDRL
        cpl
        and     $1f
        ld      l, a
  end asm
end function

function FASTCALL Keyboard () as ubyte
  asm
        ld      hl, tabla
        ld      c, $fe
        ld      e, 0
        jr      keyb2
keyb:   sla     e
keyb1:  bit     0, d
        jr      nz, keyb2
        inc     e
keyb2:  ld      b, (hl)
        in      d, (c)
        inc     hl
        ld      a, (hl)
        inc     hl
        ld      (keyb1+1), a
        djnz    keyb
        ld      a, e
        ret
tabla:  defw    sKEY, QKEY, AKEY, OKEY, PKEY
        defb    1
  end asm
end function

function FASTCALL Inputs () as ubyte
  asm
        defb    $c3, 0
  end asm
end function

sub FASTCALL Redefine ()
  asm
redef:  xor     a
        in      a, ($fe)
        or      $e0
        inc     a
        jr      nz, redef
        ld      hl, tabla
        ld      ix, rede8
rede1:  ld      de, $0e12
        push    hl
        ld      h, 0
        call    print
        pop     hl
rede2:  ld      bc, $fefe
rede3:  ld      a, $42
        in      d, (c)
rede4:  rr      d
        jr      nc, rede5
        add     a, 8
        cp      $6a
        jr      nz, rede4
        rlc     b
        jr      rede3
rede5:  ld      (hl), b
        inc     hl
        ld      (hl), a
        dec     hl
        dec     hl
        ld      c, (hl)
        dec     hl
        cp      c
        jr      nz, rede6
        ld      a, (hl)
        cp      b
        jr      z, rede7
rede6:  ld      de, 4
        add     hl, de
        ld      de, tabla+10
        sbc     hl, de
        add     hl, de
        jr      nz, rede1
        ld      de, $0e12
        ld      h, 0
        jp      print
rede7:  inc     hl
        inc     hl
        jr      rede2
rede8:  defb    "Fire"
        defb    0
        defb    " Up "
        defb    0
        defb    "Down"
        defb    0
        defb    "Left"
        defb    0
        defb    "Right"
        defb    0
        defb    "     "
        defb    0
  end asm
end sub

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

sub FASTCALL CallBitmap ( source as uinteger )
  asm
        ld      c, h
        ld      a, $ff
        ld      d, a
        sub     l
        add     a, a
        ld      e, a
        ld      hl, bitmap+1
        add     hl, de
        ld      e, (hl)
        inc     hl
        ld      d, (hl)
        add     hl, de
        ld      a, (hl)
        and     3
        ld      b, a
        add     a, $58
        add     a, c
        ld      d, a
        ld      a, (hl)
        rra
        rra
        dec     hl
        ld      e, $ff
        push    de
        push    hl
        ld      h, d
        ld      l, e
        dec     e
        ld      (hl), a
        ld      a, d
        rlca
        rlca
        rlca
        xor     $85
        ld      c, l
        lddr
        pop     hl
        ld      d, a
        inc     a
        ld      (dzx7a+117), a
        call    dzx7a
        push    hl
        call    dzx7a+65
        pop     hl
        pop     de
        jp      dzx7a
  end asm
end sub

#if player
sub FASTCALL callsound( source as uinteger )
  asm
        ld      a, ($fff7)
        or      a
        jr      z, beep
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
sub FASTCALL IsrSound ()
  asm
        ex      af, af'
        push    ix
        push    bc
        ld      bc, $7ffd
        ld      a, $11
        out     (c), a
        exx
        call    $c00d
        exx
        ld      a, $10
        out     (c), a
        pop     bc
        pop     ix
        ex      af, af'
        ei
  end asm
end sub
#endif

sub FASTCALL PrintStr( source as uinteger, xy as uinteger )
  asm
        pop     af
        pop     de
        push    af
        push    hl
        pop     ix
        ld      hl, ($5c00)
print:  ld      a, e
        and     $18
        or      $40
        or      h
        ld      h, a
        ld      a, e
        rrca
        rrca
        rrca
        and     $e0
        add     a, d
        ld      l, a
print1: ex      de, hl
        ld      a, (ix+0)
        inc     ix
        add     a, a
        ret     z
        ld      l, a
        ld      h, $0f
        add     hl, hl
        add     hl, hl
        ld      b, 4
print2: ld      a, (hl)
        ld      (de), a
        inc     l
        inc     d
        ld      a, (hl)
        ld      (de), a
        inc     l
        inc     d
        djnz    print2
        ld      hl, $f801
        add     hl, de
        jr      print1
  end asm
end sub

#endif