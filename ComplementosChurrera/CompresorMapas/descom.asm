      IFNDEF initregs
        ld      de, map
        ld      hl, mapend-1
        ld      bc, 0
      ENDIF
desc1:  sbc     hl, bc
        ex      de, hl
        ld      c, (hl)
        ex      de, hl
        inc     de
        dec     a
        jp      p, desc1
        ld      de, mapbuf+scrw*scrh+149
        ld      b, $80          ; marker bit
desc2:  ld      a, 256 >> bitsym
desc3:  call    gbit3           ; load bitsym bits (literal)
        jr      nc, desc3
    IF bithlf=1
      IF bitsym=1
        rrca
        jr      nc, desc4
        xor     a
        call    gbit3
        inc     a
      ELSE
        rrca                    ; half bit implementation (ie 48 tiles)
        call    c, gbit1
      ENDIF
    ELSE
        and     a
    ENDIF
desc4:  ld      (de), a         ; write literal
desc5:  dec     e               ; test end of file (map is always 150 bytes)
        ret     z
        call    gbit3           ; read one bit
        rra
        jr      nc, desc2       ; test if literal or sequence
        push    de              ; if sequence put de in stack
        ld      a, 1            ; determine number of bits used for length
desc6:  call    nc, gbit3       ; (Elias gamma coding)
        and     a
        call    gbit3
        rra
        jr      nc, desc6       ; check end marker
        inc     a               ; adjust length
        ld      c, a            ; save lenth to c
        xor     a
        ld      de, scrw        ; initially point to 15
        call    gbit3           ; get two bits
        call    gbit3
        jr      z, desc9        ; 00 = 1
        dec     a
        call    gbit3
        jr      z, descb        ; 010 = 15
        bit     2, a
        jr      nz, desc7
    IF  scrw>15
        call    gbit3           ; [011, 100, 101] xx = from 2 to 13
        dec     a
        call    gbit3
        jr      desca
desc7   call    gbit3           ; [110, 111] xxxxxx = from 14-15, 17-142
        jr      nc, desc7
        cp      scrw-14
        sbc     a, -14
    ELSE
      IF  scrw=15
        add     a, $7c          ; [011, 100, 101] xx = from 2 to 13
        dec     e
desc7:  dec     e               ; [110, 111] xxxxxx = 14 and from 16 to 142
desc8:  call    gbit3
        jr      nc, desc8
        jr      z, descb
        add     a, e
      ELSE
        call    gbit3           ; [011, 100, 101] xx = from 2 to 11 and from 13 to 14
        call    gbit3
        cp      scrw+2
        sbc     a, 2
        jr      desc9
desc7:  call    gbit3           ; [110, 111] xxxxxx = from 15 to 142
        jr      nc, desc7
        add     a, 14
      ENDIF
    ENDIF
desc9:  inc     a
desca:  ld      e, a
descb:  ld      a, b            ; save b (byte reading) on a
        ld      b, d            ; b= 0 because lddr moves bc bytes
        ex      (sp), hl        ; store source, restore destination
        ex      de, hl          ; HL = destination + offset + 1
        add     hl, de          ; DE = destination
        lddr
        pop     hl              ; restore source address (compressed data)
        ld      b, a            ; restore b register
        inc     e               ; prepare test of end of file
        jr      desc5           ; jump to main loop

      IF bithlf=1 && bitsym>1
gbit1:  sub     $80 - (1 << bitsym - 2)
        defb    $da             ; second part of half bit implementation
      ENDIF
gbit2:  ld      b, (hl)         ; load another group of 8 bits
        dec     hl
gbit3:  rl      b               ; get next bit
        jr      z, gbit2        ; no more bits left?
        adc     a, a            ; put bit in a
        ret
