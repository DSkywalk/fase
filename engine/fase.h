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

#define INIT  asm("call 0xfffc")
#define FRAME asm("call 0xfff9")
#define EXIT  asm("call 0xfff6")

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

void __CALLEE__ Dzx7b ( unsigned int source, unsigned int addr ){
    #asm
        pop     af
        pop     de
        pop     hl
        push    af
        jp      dzx7a
    #endasm
}
