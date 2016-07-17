        define  zxuno_port      $fc3b
        define  radas_ctrl      $40
        define  radas_mode      3

        output  example.bin
        org     $5ccb
        defb    0, 0, 0, 0, $de, $c0, $37, $0e, $8f, $39, $ac ;OVER USR 7 ($5cd6)

init    ld      bc, zxuno_port
        ld      a, radas_ctrl
        out     (c), a
        inc     b
        ld      a, radas_mode
        out     (c), a
        ld      hl, palette
        xor     a
paloop  ld      b, $bf
        out     (c), a
        ld      e, (hl)
        inc     hl
        ld      b, $ff
        out     (c), e
        inc     a
        cp      bitmap-palette
        jr      nz, paloop
        ld      de, $4000
        ld      bc, $1800
        ldir
        jr      $

palette incbin  lenna.pal
bitmap  incbin  lenna.rad
