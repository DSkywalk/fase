; -----------------------------------------------------------------------------
; ZX7 Backwards+DRCS by Einar Saukas, Antonio Villena
; Parameters:
;   HL: source address (compressed data)
;   DE: destination address (decompressing)
; -----------------------------------------------------------------------------
dzx7    ld      bc, $8000
        ld      a, b
copyby  inc     c
        ldd
mainlo  add     a, a
        call    z, getbit
        jr      nc, copyby
        push    de
        ld      d, c
        defb    $30
lenval  add     a, a
        call    z, getbit
        rl      c
        rl      b
        add     a, a
        call    z, getbit
        jr      nc, lenval
        inc     c
        jr      z, exitdz
        ld      e, (hl)
        dec     hl
        sll     e
        jr      nc, offend
        ld      d, $10
nexbit  add     a, a
        call    z, getbit
        rl      d
        jr      nc, nexbit
        inc     d
        srl     d
offend  rr      e
        ex      (sp), hl
        ex      de, hl
        adc     hl, de
        lddr
exitdz  pop     hl
        jr      nc, mainlo
        ld      a, $41
        sub     h
        ret     c
        ld      b, a
drcsne  ld      de, $4001
drcslo  ld      h, d
        ld      a, e
        djnz    drcsco
        rrca
        rrca
        ld      c, a
        xor     d
        and     $07
        xor     d
        ld      h, a
        xor     d
        xor     c
drcsco  ld      l, a
        rlca
        rrc     h
        rla
        rl      h
        ld      c, a
        xor     l
        and     $05
        xor     l
        rrca
        rrca
        xor     c
        and     $67
        xor     c
        ld      l, a
        sbc     hl, de
        jr      nc, drcssk
        add     hl, de
        ld      c, (hl)
        ld      a, (de)
        ld      (hl), a
        ld      a, c
        ld      (de), a
drcssk  inc     b
        inc     de
        ld      a, d
        cp      $58
        jr      nz, drcslo
        djnz    drcsne
getbit  ld      a, (hl)
        dec     hl
        adc     a, a
        ret