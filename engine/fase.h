#include "build\define.h"

#define tilepaint(from_x, from_y, to_x, to_y) *repaint= from_x|from_y<<4|to_x<<8|to_y<<12
#define Bitmap(func, param) CallBitmap(func|param<<8)

#define sKEY  $427f
#define QKEY  $42fb
#define AKEY  $42fd
#define OKEY  $4adf
#define PKEY  $42df

#define INIT  asm("call 0xfffc")
#define FRAME asm("call 0xfff9")
#define EXIT  asm("call 0xfff6")

#define EI    asm("ei")
#define DI    asm("di")

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
unsigned char  *tiles= 0x5b40;
unsigned char *screen= 0x5c00;
unsigned char *shadow= 0x5c01;
unsigned int *repaint= 0x5c02;
unsigned int  *drwout= 0x5c06;
unsigned int   *is128= 0xfff7;
unsigned int  *intadr= 0xfff5;
unsigned char  *zxmem= 0;

void *Input;

char Joystick ( void ){
    #asm
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
    #endasm
}

char Cursors ( void ){
    #asm
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
    #endasm
}

char Keyboard ( void ){
    #asm
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
        ld      l, e
        ret
tabla:  defw    sKEY, QKEY, AKEY, OKEY, PKEY
        defb    1
    #endasm
}

char Redefine ( void ){
    #asm
redem:  xor     a
        in      a, ($fe)
        or      $e0
        inc     a
        jr      nz, redem
        ld      hl, tabla
        ld      ix, texts
pipi:   ld      de, $0e12
        push    hl
        ld      h, 0
        call    print
        pop     hl
rede0:  ld      bc, $fefe
rede:   ld      a, $42
        in      d, (c)
rede1:  rr      d
        jr      nc, rede2
        add     a, 8
        cp      $6a
        jr      nz, rede1
        rlc     b
        jr      rede
rede2:  ld      (hl), b
        inc     hl
        ld      (hl), a
        dec     hl
        dec     hl
        ld      c, (hl)
        dec     hl
        cp      c
        jr      nz, rede3
        ld      a, (hl)
        cp      b
        jr      z, rede4
rede3:  ld      de, 4
        add     hl, de
        ld      de, tabla+10
        sbc     hl, de
        add     hl, de
        jr      nz, pipi
        ld      de, $0e12
        ld      h, 0
        jp      print
rede4:  inc     hl
        inc     hl
        jr      rede0
texts:  defm    "Fire", 0
        defm    " Up ", 0
        defm    "Down", 0
        defm    "Left", 0
        defm    "Right", 0
        defm    "     ", 0
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
        ex      af, af
        ei
    #endasm
}
#else
void __FASTCALL__ IsrSound ( void );
#endif

void __CALLEE__ PrintStr ( char *string, unsigned int xy ){
    #asm
        pop     af
        pop     de
        pop     ix
        push    af
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
        ld      a, (ix)
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
    #endasm
}
