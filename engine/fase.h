#include "build\define.h"

#define Keyb54321 0xf7
#define KeybTREWQ 0xfb
#define KeybGFDSA 0xfd
#define KeybVCXZc 0xfe
#define Keyb67890 0xef
#define KeybYUIOP 0xdf
#define KeybHJKLe 0xbf
#define KeybBNMs_ 0x7f

#define tilepaint(from_x, from_y, to_x, to_y) *repaint= from_x|from_y<<4|to_x<<8|to_y<<12
#define Bitmap(func, param) CallBitmap(func|param<<8)

#define INIT  asm("call 0xfffc")
#define FRAME asm("call 0xfff9")
#define EXIT  asm("call 0xfff6")

#define EFFX  4
#define STOP  7
#define LOAD  10

#if player
  #define Sound(func, param) CallSound(func|param<<8)
#else
  #define Sound(func, param)
#endif

typedef struct {
  unsigned char n;
  unsigned char x;
  unsigned char y;
  unsigned char f;
} SPRITE;

typedef struct {
  unsigned char x;
  unsigned char y;
} BULLET;

SPRITE *sprites= 0x5b00;
BULLET *bullets= 0x5b30;
unsigned char *tiles= 0x5b40;
unsigned char *screen= 0x5c00;
unsigned char *shadow= 0x5c01;
unsigned int *repaint= 0x5c02;
unsigned int *drwout= 0x5c06;
unsigned char *zxmem= 0;

char __FASTCALL__ inKey ( unsigned char row ){
    #asm
        ld      b, l
        ld      c, $fe
        in      a, (c)
        cpl
        and     $1f
        ld      l, a
    #endasm
}

void __FASTCALL__ Pause ( unsigned int msecs ){
    #asm
loop1:  ld      bc, 21
loop2:  djnz    loop2
        dec     c
        jr      nz, loop2
        dec     hl
        ld      a, l
        or      h
        jr      nz, loop1
    #endasm
}

void __FASTCALL__ CallBitmap ( unsigned int source ){
    #asm
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
    #endasm
}

#if player
void __FASTCALL__ CallSound ( unsigned int source ){
    #asm
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
    #endasm
}
void __FASTCALL__ IsrSound ( void ){
    #asm
labsou: ex      af, af
        ld      bc, $7ffd
        ld      a, $11
        out     (c), a
        exx
        call    $c00d
        exx
        ld      a, $10
        out     (c), a
        ex      af, af
        ei
    #endasm
}
#else
void __FASTCALL__ IsrSound ( void );
#endif
