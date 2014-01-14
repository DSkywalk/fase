        DEFINE  mapw  12              ; map width is 12
        DEFINE  maph  2               ; map height is 2, our demo has 12x2 screens
        DEFINE  scrw  12              ; screen width is 12
        DEFINE  scrh  8               ; screen height is 8, our window is 12x8 tiles (exactly half of the screen area)
        DEFINE  DMAP_BITSYMB 5        ; these 3 constants are for the map decompressor
        DEFINE  DMAP_BITHALF 1        ; BITSYMB and BITHALF declares 5.5 bits per symbol (16 tiles with 5 bits and 32 with 6 bits)
        DEFINE  DMAP_BUFFER  $5b01    ; BUFFER points to where is decoded the uncompressed screen

; This macro copies a line from immediate value (data is embed in code) to
; the stack, that correspond with a line (32 bytes) in the screen memory

    MACRO   copy  to
        ld      sp, $401c+to*16
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
    ENDM

; This macro multiplies two 8 bits numbers (second one is a constant)
; Factor 1 is on E register, Factor 2 is the constant data (macro parameter)
; Result is returned on HL (Macro optimized by Metalbrain & Einar Saukas)

  MACRO multsub first, second
    IF  data & first
        add     hl, hl
      IF  data & second
        add     hl, de
      ENDIF
    ENDIF
  ENDM

  MACRO mult8x8 data
    IF  data = 0
        ld      hl, 0
    ELSE
        ld      h, 0
        ld      l, e
      IF (data-1)*(data-2)*(data-4)*(data-8)*(data-16)*(data-32)*(data-64)*(data-128)
        ld      d, h
      ENDIF
        multsub %10000000, %01000000
        multsub %11000000, %00100000
        multsub %11100000, %00010000
        multsub %11110000, %00001000
        multsub %11111000, %00000100
        multsub %11111100, %00000010
        multsub %11111110, %00000001
    ENDIF
  ENDM

; Paolo Ferraris' shortest loader, then we move all the code to $8000
        output  juego.bin
        org     $8000-22
ini     ld      de, $8000+fin-empe-1
        di
        db      $de, $c0, $37, $0e, $8f, $39, $96 ;OVER USR 7 ($5ccb)
aki     ld      hl, $5ccb+fin-ini-1
        ld      bc, fin-empe
        lddr
        jp      $8000

; First we clear the 2 upper thirds of the screen (our game area)
; Note that ink=paper=0, this is to hide the sprites over the edges

empe    ld      hl, $5800
        ld      de, $5801
        ld      bc, $01ff
        ld      (hl), l
        ldir

; These self modifying code saves the correct value of the stack (out an into the routine)
        ld      (paint3+1), sp
        push    af
        ld      (paint4+1), sp

; Main loop. This loop is executed when the main character exits over the edge of the screen
; so we must generate the whole screen (into embed code) according to the map
; First we calculate 12*y+x
bucl    ld      a, (y)
        ld      e, a
        mult8x8 mapw
        ld      a, (x)
        add     a, l

; Pass the calculated actual screen (from 0 to 23) to the decompressor (after this we have the actual screen at $5801)
        call    descom

; Put the centered initial position (in attribute area) into attr variable because we haven't free registers
        ld      hl, $5810-scrw
        ld      (attr), hl
; Points to the data (in reality is code because is embed) where we paint the tiles
        ld      hl, screen+12*4
        exx
; BC points to the uncompressed buffer
        ld      bc, DMAP_BUFFER 
; The count of tiles is saved in A and A' registers
        ld      a, scrh
paint1  ex      af, af'
        ld      a, scrw
; Read the tile number in HL
paint2  ld      h, b
        ld      l, c
        ld      l, (hl)
        ld      h, 0
; HL= HL*36
        add     hl, hl
        add     hl, hl
        ld      d, h
        ld      e, l
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, de
        ld      de, tiles
        add     hl, de
        ld      sp, hl
; Now SP points to the 36 bytes of the tile that we must to print
        exx
        ld      bc, 51
; Prints the first cell (there are 4 cells to print)
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        ld      de, -357+1
        add     hl, de
; Prints the second cell 
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        ld      de, 51-1
        add     hl, de
; Prints the third cell 
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        ld      de, -357+1
        add     hl, de
; Prints the fourth cell 
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        ld      de, -765-5
        add     hl, de
        ex      de, hl
; Now we must print the 4 bytes of the attributes
        ld      hl, (attr)
        pop     bc
        ld      (hl), c
        inc     l
        ld      (hl), b
        ld      bc, $001f
        add     hl, bc
        pop     bc
        ld      (hl), c
        inc     l
        ld      (hl), b
; This code updates the attr pointer to the next position
        ld      bc, $ffe1
        add     hl, bc
        ld      (attr), hl
        ex      de, hl
        exx
        inc     bc
; Repeat 12 times (12 tiles per line)
        dec     a
        jp      nz, paint2
        exx
        ex      de, hl
; When a line of tiles is printed, the attr pointer must point to the first row on the next line
        ld      bc, $40-(scrw*2)
        add     hl, bc
        ld      (attr), hl
        ex      de, hl
; Do the same with the other pointer
        ld      de, 816+48
        add     hl, de
        exx
        ex      af, af'
; Repeat 8 times (8 lines of tiles)
        dec     a
        jp      nz, paint1

; Second main loop, in this case we only redraw the actual screen for erasing all the sprites
; Wait to cycle 14400 (approx), when the electron beam points the first non-border pixel
repet   in      a, ($ff)
        inc     a
        jr      z, repet
; Now we generate the playing area of pre-generated tiles to erase the sprites
; This is not visible because speed of generation is slower than the electron beam
; We must generate the lines in the same non linear order than the electrom beam (this takes about 40000 cycles)
screen  copy    $00
        copy    $10
        copy    $20
        copy    $30
        copy    $40
        copy    $50
        copy    $60
        copy    $70
        copy    $02
        copy    $12
        copy    $22
        copy    $32
        copy    $42
        copy    $52
        copy    $62
        copy    $72
        copy    $04
        copy    $14
        copy    $24
        copy    $34
        copy    $44
        copy    $54
        copy    $64
        copy    $74
        copy    $06
        copy    $16
        copy    $26
        copy    $36
        copy    $46
        copy    $56
        copy    $66
        copy    $76
        copy    $08
        copy    $18
        copy    $28
        copy    $38
        copy    $48
        copy    $58
        copy    $68
        copy    $78
        copy    $0a
        copy    $1a
        copy    $2a
        copy    $3a
        copy    $4a
        copy    $5a
        copy    $6a
        copy    $7a
        copy    $0c
        copy    $1c
        copy    $2c
        copy    $3c
        copy    $4c
        copy    $5c
        copy    $6c
        copy    $7c
        copy    $0e
        copy    $1e
        copy    $2e
        copy    $3e
        copy    $4e
        copy    $5e
        copy    $6e
        copy    $7e
        copy    $80
        copy    $90
        copy    $a0
        copy    $b0
        copy    $c0
        copy    $d0
        copy    $e0
        copy    $f0
        copy    $82
        copy    $92
        copy    $a2
        copy    $b2
        copy    $c2
        copy    $d2
        copy    $e2
        copy    $f2
        copy    $84
        copy    $94
        copy    $a4
        copy    $b4
        copy    $c4
        copy    $d4
        copy    $e4
        copy    $f4
        copy    $86
        copy    $96
        copy    $a6
        copy    $b6
        copy    $c6
        copy    $d6
        copy    $e6
        copy    $f6
        copy    $88
        copy    $98
        copy    $a8
        copy    $b8
        copy    $c8
        copy    $d8
        copy    $e8
        copy    $f8
        copy    $8a
        copy    $9a
        copy    $aa
        copy    $ba
        copy    $ca
        copy    $da
        copy    $ea
        copy    $fa
        copy    $8c
        copy    $9c
        copy    $ac
        copy    $bc
        copy    $cc
        copy    $dc
        copy    $ec
        copy    $fc
        copy    $8e
        copy    $9e
        copy    $ae
        copy    $be
        copy    $ce
        copy    $de
        copy    $ee
        copy    $fe
; Restores the stack, we need it for do CALLs
paint3  ld      sp, 0
; We will paint 12 enemies, storing the actual value in sprind (variable embed into code)
        ld      a, 11
busp    ld      (sprind+1), a
; Point HL to the parameters (4 bytes) of actual enemy
        add     a, a
        add     a, a
        ld      l, a
        ld      h, ene0 >> 8
; Reads X and Y position
        ld      c, (hl)
        inc     l
        ld      b, (hl)
        inc     l
; Test vertical direction
        bit     0, (hl)
        jr      nz, binc
; If direction is up, decrement Y and test upper edge
        dec     b
        djnz    bfin
; If upper edge detected invert vertical direction
        inc     (hl)
        jr      bfin
; If direction is down, increment Y, test and process lower edge
binc    inc     b
        inc     b
        ld      a, $70
        cp      b
        jr      nz, bfin
        dec     (hl)
; Do the same in horizontal direction
bfin    bit     1, (hl)
        jr      nz, cinc
        dec     c
        dec     c
        ld      a, $1e
        cp      c
        jr      nz, cfin
        set     1, (hl)
        jr      cfin
cinc    inc     c
        inc     c
        ld      a, $d2
        cp      c
        jr      nz, cfin
        res     1, (hl)
; Read sprite picture to use in A
cfin    inc     l
        ld      a, (hl)
        dec     l
        dec     l
; Update X and Y to memory
        ld      (hl), b
        dec     l
        ld      (hl), c
; Paint the enemy sprite
        call    put_sprite
; Repeat 12 times
sprind  ld      a, 0
        dec     a
        jp      p, busp
; Paint the main character sprite
        ld      bc, (corx)
        xor     a
        call    put_sprite
; Points HL and IX to vertical variables, BC with upper and lower limits, DE with input port and vertical map dimension
        ld      hl, cory
        ld      ix, y
        ld      bc, $026e
        ld      de, $fd | maph<<8
        call    key_process
        jr      c, tbucl
        cp      $03
        jr      nz, pact
; Do the same with horizontal stuff
        ld      bc, $14dc
        dec     l
        dec     ixl
        ld      de, $df | mapw<<8
        call    key_process
; If main character croses an edge jump to bucl (main loop), else jump to repet (2nd main loop)
tbucl   jp      c, bucl
pact    jp      repet

; Paint a sprite
; A register is the sprite number (must be multiple of 8)
; BC register is X and Y coordinates
put_sprite:
        xor     c
        and     $f8
        xor     c
        ld      (cspr+2), a
cspr    ld      sp, (sprites)
        pop     de
        ld      a, b
        add     a, d
        ld      (clin+1), a
clin    ld      hl, (lookt)
        ld      a, c
        and     $f8
        rra
        rra
        rra
        or      l
        ld      l, a
        ld      a, e
spr1    ex      af, af'
        pop     bc
        ld      a, c
        and     $03
        add     a, l
        dec     a
        ld      l, a
        bit     3, c
        jr      z, ncol24
col24   pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        inc     l
        pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        inc     l
        pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        inc     h
        pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        dec     l
        pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        dec     l
        pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        inc     h
        ld      a, h
        and     $06
        jr      nz, col24a
        ld      a, l
        add     a, $20
        ld      l, a
        jr      c, col24a
        ld      a, h
        sub     $08
        ld      h, a
col24a  djnz    col24
        jr      fini
ncol24  bit     2, c
        jr      z, col8
col16   pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        inc     l
        pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        inc     h
        pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        dec     l
        pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        inc     h
        ld      a, h
        and     $06
        jr      nz, col16a
        ld      a, l
        add     a, $20
        ld      l, a
        jr      c, col16a
        ld      a, h
        sub     $08
        ld      h, a
col16a  djnz    col16
        jr      fini
col8    pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        inc     h
        pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        inc     h
        ld      a, h
        and     $06
        jr      nz, col8a
        ld      a, l
        add     a, $20
        ld      l, a
        jr      c, col8a
        ld      a, h
        sub     $08
        ld      h, a
col8a   djnz    col8
fini    ex      af, af'
        dec     a
        jp      nz, spr1
paint4  ld      sp, 0
        ret

; This routine tests the keys and moves the main character
key_process:
        ld      a, e
        in      a, ($fe)
        and     $03
        cp      $02
        jr      z, key2
        ret     nc
        dec     (hl)
        dec     (hl)
        ld      a, (hl)
        cp      b
        ret     nc
        dec     (ix)
        jp      p, key1
        inc     (hl)
        inc     (hl)
        inc     (ix)
        and     a
        ret
key1    ld      (hl), c
        ret
key2    ld      a, c
        inc     (hl)
        inc     (hl)
        cp      (hl)
        ret     nc
        inc     (ix)
        ld      a, (ix)
        cp      d
        jr      nz, key3
        dec     (hl)
        dec     (hl)
        dec     (ix)
        and     a
        ret
key3    ld      (hl), 0
        ret

; Some variables
attr    dw      $5810-scrw
x       db      0
y       db      0
corx    db      32
cory    db      2

; Look up table, from Y coordinate to memory address, 256 byte aligned
        block   $9c00-$
lookt   incbin  table.bin

; Enemy table. For each item: X, Y, direction and sprite number, 256 byte aligned
        block   $9d00-$
ene0    db      $42, $12, %01, 0<<3 | $40
        db      $60, $60, %10, 1<<3 | $40
        db      $a8, $48, %11, 2<<3 | $40
        db      $22, $02, %01, 3<<3 | $40
        db      $d0, $6e, %10, 4<<3 | $40
        db      $b6, $34, %11, 5<<3 | $40
        db      $32, $32, %01, 6<<3 | $40
        db      $52, $5e, %00, 7<<3 | $40
        db      $72, $04, %11, $38
        db      $12, $42, %01, 0<<3 | $40
        db      $40, $60, %10, 1<<3 | $40
        db      $a8, $10, %11, 2<<3 | $40

; Sprites file. Generated externally with GfxBu.c from sprites.png
        block   $9e00-$
sprites incbin  sprites.bin

; Decompressor code
descom  include descom12.asm

; Tiles file. Generated externally with tilegen.c from tiles.png
tiles   incbin  tiles.bin

; Map file. Generated externally with TmxCompress.c from map.tmx
map     incbin  map_compressed.bin
fin