        include define.asm
        include defmap.asm
        DEFINE  sylo    $66
        DEFINE  syhi    $c0
        DEFINE  enems   $5b00
        DEFINE  mapbuf  $5b40
        DEFINE  screen  $5c00
        DEFINE  port    $5c01
        DEFINE  selbeg  $5c02
        DEFINE  selend  $5c03
        DEFINE  tiladdr $5c08
        DEFINE  sprites $fe00
      IF  smooth=0
        DEFINE  final   $fd00
      ELSE
        DEFINE  final   $fc81
      ENDIF

      MACRO updremove
        ld      a, h
        and     $07
        jp      nz, .upd
        ld      a, l
        sub     $20
        ld      l, a
        jr      c, .upd
        ld      a, h
        add     a, $08
        ld      h, a
.upd
      ENDM

      MACRO updpaint
        ld      a, h
        and     $07
        jp      nz, .upd&$ffff
        ld      a, l
        add     a, $20
        ld      l, a
        jr      c, .upd
        ld      a, h
        sub     $08
        ld      h, a
.upd
      ENDM

    MACRO updcldn
        ld      a, h
        and     $07
        jp      nz, .upd&$ffff
      IF  offsey+scrh*2&7
        ld      de, $f820
        add     hl, de
      ELSE
        ld      a, l
        add     a, $20
        ld      l, a
        jr      c, .upd
        ld      a, h
        sub     $08
        ld      h, a
      ENDIF
.upd
    ENDM

      MACRO updclup
        ld      a, d
        and     $07
        jp      nz, .upd&$ffff
        ld      a, d
        sub     $08
        ld      d, a
.upd
      ENDM

      MACRO cellprint addition
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        inc     h
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        inc     h
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        inc     h
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        ld      de, addition
        add     hl, de
      ENDM

      MACRO ndjnz addr
        defb    $10, addr-.ndj
.ndj
      ENDM

; Paolo Ferraris' shortest loader, then we move all the code to $8000
        org     staspr+final-mapend-$
staspr  defw    draw_sprites+3
        nop
do_sprites
        ld      (drawj+1&$ffff), sp
      IF  machine=0
do0     ld      bc, syhi | sylo<<8
do1     in      a, ($ff)
        cp      b
        jp      nz, do1
        ld      b, 9
do2     in      a, ($ff)
        cp      c
do3     jr      z, do5
        djnz    do2
        jr      do0
      ENDIF
      IF  machine=1
        ld      hl, flag&$ffff
        inc     (hl)
        xor     a
        ei
do1     cp      (hl)
        jr      nz, do1
        ld      bc, $7ffd
        ld      a, (port&$ffff)
        xor     $80
        ld      (port&$ffff), a
        ld      a, $18
        jr      z, do2
        ld      a, $17
do2     out     (c), a
do3     jr      update_complete
      ENDIF
      IF  machine=2
        ld      hl, flag&$ffff
        inc     (hl)
        xor     a
        ei
do1     cp      (hl)
        jr      nz, do1
do3     jr      update_complete
      ENDIF
do5     ld      a, update_complete-2-do3&$ff
        ld      (do3+1), a
        jp      draw_sprites&$ffff
      IF  machine=1
do4     ld      a, update_complete-2-do3&$ff
        ld      (do3+1), a
        jp      descb
      ENDIF

;Complete background update
update_complete
        ld      hl, screen
        ld      a, (hl)
        inc     a
        jp      z, delete_sprites&$ffff
        ld      bc, $00ff
        ld      (hl), c
        ld      hl, mapend+$fe&$ffff
        ld      de, map&$ffff
desc1   sbc     hl, bc
        ex      de, hl
        ld      c, (hl)
        ex      de, hl
        inc     de
        dec     a
        jr      nz, desc1
      IF  machine=1
        ld      bc, $7ffd
        ld      a, (port)
        rla
        ld      e, $18
        jr      c, desc2
        ld      e, $17
desc2   out     (c), e
        ld      a, do4-2-do3
        ld      (do3+1), a
        ld      a, e
        xor     $07
        out     (c), a
        inc     b
      ELSE
        ld      b, $80          ; marker bit
      ENDIF
        ld      de, mapbuf+scrw*scrh-1
desc3   ld      a, 256 >> bitsym
desc4   call    gbit3&$ffff     ; load bitsym bits (literal)
        jr      nc, desc4
    IF bithlf=1
      IF bitsym=1
        rrca
        jr      nc, desc45
        xor     a
        call    gbit3&$ffff
        inc     a
      ELSE
        rrca                    ; half bit implementation (ie 48 tiles)
        call    c, gbit1&$ffff
      ENDIF
    ENDIF
desc45  ld      (de), a         ; write literal
        dec     e               ; test end of file (map is always 150 bytes)
desc5   ld      a, e
        cp      $3f
        jr      z, descb
        call    gbit3&$ffff     ; read one bit
        rra
        jr      nc, desc3       ; test if literal or sequence
        push    de              ; if sequence put de in stack
        ld      a, 1            ; determine number of bits used for length
desc6   call    nc, gbit3&$ffff ; (Elias gamma coding)
        and     a
        call    gbit3&$ffff
        rra
        jr      nc, desc6       ; check end marker
        inc     a               ; adjust length
        ld      c, a            ; save lenth to c
        xor     a
        ld      de, scrw        ; initially point to scrw
        call    gbit3&$ffff     ; get two bits
        call    gbit3&$ffff
        jr      z, desc9        ; 00 = 1
        dec     a
        call    gbit3&$ffff
        jr      z, desca        ; 010 = 15
        bit     2, a
        jr      nz, desc7
    IF  scrw>15
        call    gbit3&$ffff     ; [011, 100, 101] xx = from 2 to 13
        dec     a
        call    gbit3&$ffff
        jr      desc95
desc7   call    gbit3&$ffff     ; [110, 111] xxxxxx = from 14-15, 17-142
        jr      nc, desc7
        cp      scrw-14
        sbc     a, -14
    ELSE
      IF  scrw=15
        add     a, $7c          ; [011, 100, 101] xx = from 2 to 13
        dec     e
desc7   dec     e               ; [110, 111] xxxxxx = 14 and from 16 to 142
desc8   call    gbit3&$ffff
        jr      nc, desc8
        jr      z, desca
        add     a, e
      ELSE
        call    gbit3&$ffff     ; [011, 100, 101] xx = from 2 to 11 and from 13 to 14
        call    gbit3&$ffff
        cp      scrw+2
        sbc     a, 2
        jr      desc9
desc7   call    gbit3&$ffff     ; [110, 111] xxxxxx = from 15 to 142
        jr      nc, desc7
        add     a, 14
      ENDIF
    ENDIF
desc9   inc     a
desc95  ld      e, a
desca   ld      a, b            ; save b (byte reading) on a
        ld      b, d            ; b= 0 because lddr moves bc bytes
        ex      (sp), hl        ; store source, restore destination
        ex      de, hl          ; HL = destination + offset + 1
        add     hl, de          ; DE = destination
        lddr
        pop     hl              ; restore source address (compressed data)
        ld      b, a            ; restore b register
        jr      desc5           ; jump to main loop
descb   ld      a, scrh
        ld      (upba2-1), a
        ld      a, scrw
        ld      (upba3-1), a
        ld      a, $40-scrw*2
        ld      (upba6+1), a
        ld      (upba7+1), a
        ld      bc, $5800+offsex+offsey*32
        ld      hl, $4000+offsex+(offsey<<5&0xe0)+(offsey<<8&0x1800)
upba1
      IF  machine=1
        ld      a, (port)
        xor     b
        ld      b, a
        and     $80
        xor     h
        ld      h, a
      ENDIF
        exx
      IF  tmode=3
        xor     a
        ld      (upba4+1), a
      ELSE
        ld      bc, mapbuf 
      ENDIF
        ld      a, 0
upba2   ex      af, af'
        ld      a, 0
upba3 IF  tmode=3
        ld      hl, upba4+1
        inc     (hl)
upba4   ld      hl, mapbuf 
      ELSE
        ld      h, b
        ld      l, c
      ENDIF
        ld      l, (hl)
        ld      h, 0
      IF  tmode=0
        ld      d, h
        ld      e, l
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, de
        add     hl, hl
        add     hl, hl
        ld      de, tiladdr
        add     hl, de
        ld      sp, hl
        exx
        cellprint $f901
        cellprint $f91f
        cellprint $f901
        cellprint $f8e1
      ENDIF
      IF  tmode=1
        ld      d, h
        ld      e, l
        add     hl, hl
        add     hl, hl
        add     hl, de
        ld      de, tiladdr
        add     hl, de
        ld      (upba5+1), hl
        ld      de, 4
        add     hl, de
        ld      l, (hl)
        ld      h, d
        ld      de, tiladdr+tiles*5
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, de
        ld      sp, hl
        exx
        cellprint $f901
        cellprint $f91f
        cellprint $f901
        cellprint $f8e1
upba5   ld      sp, 0
      ENDIF
      IF  tmode=2
        ld      d, h
        ld      e, l
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, de
        ld      de, tiladdr
        add     hl, de
        ld      e, (hl)
        inc     hl
        ld      sp, hl
        ex      de, hl
        ld      h, 0
        add     hl, hl
        add     hl, hl
        ld      de, tiladdr+tiles*33
        add     hl, de
        ld      (upba5+1), hl
        exx
        cellprint $f901
        cellprint $f91f
        cellprint $f901
        cellprint $f8e1
upba5   ld      sp, 0
      ENDIF
      IF  tmode=3
        add     hl, hl
        ld      de, tiladdr
        add     hl, de
        ld      e, (hl)
        inc     hl
        ld      l, (hl)
        ld      h, 0
        ld      d, h
        add     hl, hl
        add     hl, hl
        ld      bc, tiladdr+tiles*2+bmaps*32
        add     hl, bc
        ld      (upba5+1), hl
        ex      de, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        ld      bc, tiladdr+tiles*2
        add     hl, bc
        ld      sp, hl
        exx
        cellprint $f901
        cellprint $f91f
        cellprint $f901
        cellprint $f8e1
upba5   ld      sp, 0
      ENDIF
        ex      de, hl
        ld      h, b
        ld      l, c
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
        ld      bc, $ffe1
        add     hl, bc
        ld      b, h
        ld      c, l
        ex      de, hl
        exx
      IF  tmode<3
        inc     c
      ENDIF
        dec     a
        jp      nz, upba3
        exx
        ex      de, hl
upba6   ld      bc, 0
        add     hl, bc
        ld      b, h
        ld      c, l
        ex      de, hl
upba7   ld      de, 0
        ld      a, l
        add     a, a
        jr      nc, upba8
        jp      p, upba8
        ld      d, 7
upba8   add     hl, de
        exx
        ex      af, af'
        dec     a
        jp      nz, upba2
        jp      draw_sprites

delete_sprites
        ld      sp, 0
        pop     bc
        ld      ixl, b
        inc     b
      IF smooth=0
        jr      z, update_partial
      ELSE
        jp      z, update_partial
      ENDIF
del1    pop     hl
del2    pop     bc
        ld      a, c
        and     %00001100
        jr      z, del5
        jp      po, del4
del3    updremove
        pop     de
        dec     h
        ld      (hl), e
        inc     l
        ld      (hl), d
        inc     l
        pop     de
        ld      (hl), e
      IF smooth=1
        updremove
      ENDIF
        dec     h
        ld      (hl), d
        dec     l
        pop     de
        ld      (hl), e
        dec     l
        ld      (hl), d
        djnz    del3
        jr      del6
del4    updremove
        pop     de
        dec     h
        ld      (hl), e
        inc     l
        ld      (hl), d
      IF smooth=1
        updremove
      ENDIF
        dec     h
        pop     de
        ld      (hl), e
        dec     l
        ld      (hl), d
        djnz    del4
        jr      del6
del5    updremove
        pop     de
        dec     h
        ld      (hl), e
      IF smooth=1
        updremove
      ENDIF
        dec     h
        ld      (hl), d
        djnz    del5
del6    ld      a, c
        cpl
        and     $03
        add     a, l
        sub     2
        ld      l, a
        dec     ixl
      IF smooth=0
        jr      nz, del2
      ELSE
        jp      nz, del2
      ENDIF
        pop     bc
        ld      ixl, b
        inc     b
      IF smooth=0
        jr      nz, del1
      ELSE
        jp      nz, del1
      ENDIF

update_partial
      IF  machine=1
        jr      uppa3
        ld      a, uppa3-update_partial-2&$ff
        ld      (update_partial+1), a
uppa1   ld      l, 0
uppa2   ld      c, 0
        jr      uppa5
      ENDIF

uppa3   ld      hl, selend
        ld      a, (hl)
        dec     l
        ld      c, (hl)
        sub     c
        jr      c, draw_sprites

;Partial background update
        ld      (hl), l
        ld      l, a
      IF  machine=1
        ld      h, c
        ld      bc, $7ffd
        ld      a, (port)
        rla
        ld      e, $18
        jr      c, uppa4
        ld      e, $17
uppa4   out     (c), e
        ld      (update_partial+1), a
        ld      a, l
        ld      (uppa1+1), a
        ld      a, h
        ld      (uppa2+1), a
        ld      a, e
        xor     $07
        out     (c), a
        ld      c, h
uppa5   ld      a, l
      ENDIF
        and     $0f
        inc     a
        ld      (upba3-1), a
        add     a, a
        cpl
        sub     $bf
        ld      (upba6+1), a
        ld      (upba7+1), a
        ld      a, l
        rlca
        rlca
        rlca
        rlca
        and     $0f
        inc     a
        ld      (upba2-1), a
        ld      a, c
        and     $f0
        ld      b, $58 >> 2
        rla
        rl      b
        rla
        rl      b
        rl      c
        xor     c
        and     %11100001
        xor     c
      IF  offsex=1
        inc     a
      ELSE
        add     a, offsex
      ENDIF
        ld      c, a
        ld      l, a
        ld      a, b
        rlca
        rlca
        rlca
        and     %01111000
        ld      h, a
        jp      upba1

draw_sprites
        ld      a, 7
        ld      bc, 0
draw1   ld      (drawh+1&$ffff), a
        add     a, a
        add     a, a
        ld      l, a
        ld      h, enems >> 8
        ld      a, (hl)
        add     a, a
        jp      c, drawh&$ffff
        add     a, a
        add     a, a
        inc     l
    IF safehr && !cliphr
        ex      af, af
        ld      a, (hl)
        cp      9
        jr      nc, draw15
        ld      a, 8
draw15  cp      (scrw<<4)-8
        jr      c, draw16
        ld      a, (scrw<<4)-8
draw16
      IF smooth=0
        and     $fe
      ENDIF

        ld      e, a
        ex      af, af
    ELSE
        ld      e, (hl)
      IF smooth=0
        res     0, e
      ENDIF
    ENDIF
        inc     l
        xor     e
        and     $f8
        xor     e
      IF smooth=1
        add     a, a
      ENDIF
        ld      (draw2+2&$ffff), a
        ld      a, e
        and     $f8
        rra
        rra
        rra
        ld      (draw8+1&$ffff), a
draw2   ld      sp, (sprites)
        pop     de
        ld      a, (hl)
  IF smooth=0
        and     $fe
    IF clipdn=0
      IF safevr=1
        cp      scrh*16-7
        jr      c, draw3
        ld      a, scrh*16-8
      ENDIF
draw3   add     a, d
    ELSE
      IF safevr=1
        cp      scrh*16+1
        jr      c, draw3
        ld      a, scrh*16
      ENDIF
draw3   add     a, d
      IF clipdn=2
        cp      1+((offsey+scrh*2-2)<<3)
        jp      nc, craw1&$ffff
      ENDIF
    ENDIF
    IF clipup=0
      IF safevr=1
        cp      offsey<<3
        jr      nc, draw4
        ld      a, offsey<<3
      ENDIF
    ELSE
      IF clipup=2
        cp      offsey<<3
        jp      c, braw1&$ffff
      ENDIF
    ENDIF
draw4
  ELSE
    IF safevr=1
      IF clipdn=0
        cp      scrh*16-7
        jr      c, draw3
        ld      a, scrh*16-8
      ELSE
        cp      scrh*16+1
        jr      c, draw3
        ld      a, scrh*16
      ENDIF
    ENDIF
draw3   add     a, d
  IF clipup=0
      IF safevr=1
        cp      offsey<<3
        jr      nc, draw4
        ld      a, offsey<<3
      ENDIF
  ELSE
    IF clipup=2
      IF offsey=0
        jp      nc, braw1&$ffff
      ELSE
        cp      offsey<<3
        jp      c, braw1&$ffff
      ENDIF
    ENDIF
  ENDIF
draw4
      IF clipdn=2
        cp      1+((offsey+scrh*2-2)<<3)
        jp      nc, craw1&$ffff
      ENDIF
  ENDIF
        ld      (draw5+1), a
        cp      192
draw5   ld      a, (lookt&$ffff)
        jr      nc, draw6
        ld      l, a          ; A=L= rrrRRppp
        and     %00011111
        ld      h, a          ;   H= 000RRppp
        set     6, h
        xor     l             ;   A= rrr00000
        ld      l, a          ;   L= rrr00000
        jr      draw8
draw6   ld      l, a          ; A=L= rrrRRppp
        and     %00011111
        ld      h, a          ;   H= 000RRppp
        set     5, h
        xor     l             ;   A= rrr00000
draw8   add     a, 0
      IF  offsex != 1
        add     a, offsex-1
      ENDIF
        ld      l, a
      IF  machine=1
        ld      a, (port)
        or      h
        ld      h, a
      ENDIF
        ld      a, e
        ld      (drawg+1&$ffff), a
draw9   ex      af, af'
        pop     de
        ld      ixl, d
        ld      iyh, d
        ld      iyl, e
        ld      a, e
        and     $03
        add     a, l
        dec     a
        ld      l, a
        ld      a, e
        and     %00001100
      IF smooth=0
        jr      z, drawc
      ELSE
        jp      z, drawc&$ffff
      ENDIF
        jp      po, drawb&$ffff
drawa   pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     l
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     l
        pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
      IF smooth=1
        updpaint
      ENDIF
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        dec     l
        pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        dec     l
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
        updpaint
        dec     ixl
        jr      nz, drawa
        jr      drawd
drawb   pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     l
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
      IF smooth=1
        updpaint
      ENDIF
        pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        dec     l
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
        updpaint
        dec     ixl
        jr      nz, drawb
        jr      drawd
drawc   pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
      IF smooth=1
        updpaint
      ENDIF
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
        updpaint
        dec     ixl
        jr      nz, drawc
drawd   ld      a, iyh
drawe   dec     bc
        ld      (bc), a
        ld      a, iyl
        dec     c
        ld      (bc), a
        ex      af, af'
        dec     a
        jp      nz, draw9
drawf   ld      a, h
        dec     bc
        ld      (bc), a
        ld      a, l
        dec     c
        ld      (bc), a
drawg   ld      a, 0
        dec     bc
        ld      (bc), a
        dec     c
drawh   ld      a, 0
        dec     a
        jp      p, draw1
      IF  machine=1
        ld      (delete_sprites+1), bc
        ld      bc, $7ffd
        ld      a, (port)
        rla
        ld      a, $18
        jr      c, drawi
        ld      a, $10
drawi   out     (c), a
drawj   ld      sp, 0
      ELSE
drawj   ld      sp, 0
        ld      (delete_sprites+1), bc
      ENDIF
        ret

    IF clipup=2
braw1   ld      (brawa+1&$ffff), bc  
        ld      (braw2+1&$ffff), a
        sub     d
        cpl
        sub     -10
        rra
        ld      ixh, a
braw2   ld      a, (lookt&$ffff)
        ld      l, a          ; A=L= rrrRRppp
        and     %00011111
        ld      h, a          ;   H= 000RRppp
      IF offsey=0
        set     5, h
      ELSE
        set     6, h
      ENDIF
        xor     l             ;   A= rrr00000
        ld      l, a          ;   L= rrr00000
        ld      a, (draw8+1)
      IF  offsex != 1
        add     a, offsex-1
      ENDIF
        or      l
        ld      l, a
      IF  machine=1
        ld      a, (port)
        or      h
        ld      h, a
      ENDIF
        ld      a, e
        ex      de, hl
braw3   ex      af, af'
        pop     bc
        ld      a, c
        and     $03
        add     a, e
        dec     a
        ld      e, a
        ld      a, c
        and     %00001100
        jr      z, braw6
        jp      po, braw5&$ffff
braw4   ld      hl, 12
        add     hl, sp
        ld      sp, hl
        inc     d
      IF smooth=1 && offsey&7
        updclup
      ENDIF
        inc     d
      IF offsey&7
        updclup
      ENDIF
        dec     ixh
        jr      z, braw8
        djnz    braw4
        jr      braw7
braw5   ld      hl, 8
        add     hl, sp
        ld      sp, hl
        inc     d
      IF smooth=1 && offsey&7
        updclup
      ENDIF
        inc     d
      IF offsey&7
        updclup
      ENDIF
        dec     ixh
        jr      z, braw8
        djnz    braw5
        jr      braw7
braw6   pop     hl
        pop     hl
        inc     d
      IF smooth=1 && offsey&7
        updclup
      ENDIF
        inc     d
      IF offsey&7
        updclup
      ENDIF
        dec     ixh
        jr      z, braw8
        djnz    braw6
braw7   ex      af, af'
        dec     a
        jp      nz, braw3
        ld      bc, (brawa+1&$ffff)
        jp      drawh
braw8   ld      a, e
        add     a, $20
        ld      e, a
        ndjnz   braw9
        ex      de, hl
        ld      bc, (brawa+1&$ffff)
        ex      af, af'
        dec     a
        ld      (drawg+1), a
        jp      nz, draw9
        jp      drawh
braw9   ld      ixl, b
        ld      iyh, b
        ld      iyl, c
        ex      af, af'
        ld      (drawg+1), a
        ex      af, af'
        ex      de, hl
        ld      a, c
brawa   ld      bc, 0
        and     %00001100
        jp      z, drawc
        jp      po, drawb
        jp      drawa
    ENDIF

    IF clipdn=2
craw1   ld      (craw2+1&$ffff), a
        cpl
        sub     $ff-(offsey+scrh*2<<3)
        rra
        ld      ixh, a
craw2   ld      a, (lookt&$ffff)
        ld      l, a          ; A=L= rrrRRppp
        and     %00011111
        ld      h, a          ;   H= 000RRppp
        set     6, h
        xor     l             ;   A= rrr00000
        ld      l, a          ;   L= rrr00000
        ld      a, (draw8+1)
      IF  offsex != 1
        add     a, offsex-1
      ENDIF
        or      l
        ld      l, a
      IF  machine=1
        ld      a, (port)
        or      h
        ld      h, a
      ENDIF
        ld      a, e
        ld      (drawg+1), a
craw3   ex      af, af'
        pop     de
        ld      ixl, d
        ld      iyh, d
        ld      iyl, e
        ld      a, e
        and     $03
        add     a, l
        dec     a
        ld      l, a
        ld      a, e
        and     %00001100
        jp      z, craw6&$ffff
        jp      po, craw5&$ffff
craw4   pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     l
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     l
        pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
      IF smooth=1
        updcldn
      ENDIF
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        dec     l
        pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        dec     l
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
        updcldn
        dec     ixh
        jp      z, craw8&$ffff
        dec     ixl
        jr      nz, craw4
      IF smooth=0
        jr      craw7
      ELSE
        jp      craw7&$ffff
      ENDIF
craw5   pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     l
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
      IF smooth=1
        updcldn
      ENDIF
        pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        dec     l
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
        updcldn
        dec     ixh
        jp      z, craw8&$ffff
        dec     ixl
        jr      nz, craw5
        jr      craw7
craw6   pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
      IF smooth=1
        updcldn
      ENDIF
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
        updcldn
        dec     ixh
        jp      z, craw8&$ffff
        dec     ixl
        jr      nz, craw6
craw7   ld      a, iyh
        dec     bc
        ld      (bc), a
        ld      a, iyl
        dec     c
        ld      (bc), a
        ex      af, af'
        dec     a
        jp      nz, craw3
        jp      drawf
craw8   ld      a, 1
        ex      af, af'
        ld      e, a
        ld      a, (drawg+1)
        sub     e
        inc     a
        ld      (drawg+1), a
        ld      a, iyh
        sub     ixl
        inc     a
        jp      drawe
    ENDIF

init    ld      (ini7+1&$ffff), sp

      IF clipup=1
        ld      hl, $5800+offsex  -cliphr+(offsey-1<<5)
        ld      de, $5800+offsex+1-cliphr+(offsey-1<<5)
        ld      bc, (scrh+cliphr<<1)-1
        ld      (hl), b
        ldir
      ENDIF
    IF clipdn=1
        ld      hl, $5800+offsex  -cliphr+(offsey+2*scrh<<5)
        ld      de, $5800+offsex+1-cliphr+(offsey+2*scrh<<5)
      IF clipup=1
        ld      c, (scrh+cliphr<<1)-1
      ELSE
        ld      bc, (scrh+cliphr<<1)-1
      ENDIF
        ld      (hl), b
        ldir
    ENDIF
; aprovechar bc=0

    IF  scrw=16 || cliphr=0
        xor     a
    ELSE
      IF  scrw=15 && offsex=1
        ld      a, scrh*2-1
        ld      de, $0020
        ld      b, d
        ld      c, d
        ld      hl, $5821+(offsey<<5)
ini1    ld      sp, hl
        push    bc
        add     hl, de
        dec     a
        jr      nz, ini1
        ld      ($5800+(offsey<<5)), a
        ld      ($5a7f+(offsey<<5)), a
      ELSE
        ld      a, scrh*2
        ld      de, scrw*2+1
        ld      bc, 31-scrw*2
        ld      hl, $5800+offsex-1+(offsey<<5)
ini1    ld      (hl), b
        add     hl, de
        ld      (hl), b
        add     hl, bc
        dec     a
        jr      nz, ini1
      ENDIF
    ENDIF
    IF  machine=0
        dec     a
        ld      (screen), a
        ld      (selbeg), a
      IF clipdn=1
        ld      sp, $4020+(offsey+1+2*scrh<<5&0xe0)+(offsey+1+2*scrh<<8&0x1800)
      ELSE
        ld      sp, $4020+(offsey+2*scrh<<5&0xe0)+(offsey+2*scrh<<8&0x1800)
      ENDIF
        ld      b, 16
ini15   push    af
        djnz    ini15
      IF clipdn=1
        ld      sp, $4120+(offsey+1+2*scrh<<5&0xe0)+(offsey+1+2*scrh<<8&0x1800)
      ELSE
        ld      sp, $4120+(offsey+2*scrh<<5&0xe0)+(offsey+2*scrh<<8&0x1800)
      ENDIF
        ld      de, sylo | syhi<<8
        ld      h, e
        ld      l, e
        ld      b, 10
ini2    push    de
        djnz    ini2
        ld      b, 6
ini3    push    hl
        djnz    ini3
      IF clipdn=1
        ld      sp, $4220+(offsey+1+2*scrh<<5&0xe0)+(offsey+1+2*scrh<<8&0x1800)
      ELSE
        ld      sp, $4220+(offsey+2*scrh<<5&0xe0)+(offsey+2*scrh<<8&0x1800)
      ENDIF
        push    de
        push    de
        push    de
        ld      e, d
        ld      b, 13
ini4    push    de
        djnz    ini4
      IF clipdn=1
        ld      sp, $4320+(offsey+1+2*scrh<<5&0xe0)+(offsey+1+2*scrh<<8&0x1800)
      ELSE
        ld      sp, $4320+(offsey+2*scrh<<5&0xe0)+(offsey+2*scrh<<8&0x1800)
      ENDIF
        ld      b, 16
ini5    push    de
        djnz    ini5
      IF clipdn=1
        ld      sp, $5820+(offsey+1+2*scrh<<5)
      ELSE
        ld      sp, $5820+(offsey+2*scrh<<5)
      ENDIF
        ld      b, 16
ini6    push    de
        djnz    ini6
        ld      a, do5-2-do3
        ld      (do3+1), a
ini7    ld      sp, 0
        ret
    ENDIF
      IF  machine=1
        ld      sp, $5c06
        ld      (do3+1), a
        ld      (port), a
        ld      hl, ini3&$ffff
        ld      de, $5b00
        ld      c, ini4-ini3
        ldir
        ld      hl, $db00
        call    $5b00
        ld      a, $ff
        ld      (screen), a
        ld      (selbeg), a
        dec     a
        ld      i, a
        im      2
ini7    ld      sp, 0
        ret
ini3    ld      c, $ff+ini3-ini4&$ff
        ldir
        ld      a, $17
        call    $5b00+ini35-ini3
        ld      c, $ff+ini3-ini4&$ff
        ex      de, hl
        dec     e
        dec     l
        lddr
        inc     e
        inc     l
        ex      de, hl
        ld      c, $ff+ini3-ini4&$ff
        add     hl, bc
        ld      a, $10
        call    $5b00+ini35-ini3
        jr      nc, ini3
        call    $5b00+ini34-ini3
        ld      hl, $4000
        ld      de, $c000
        ld      bc, $1b00
        ldir
ini34   xor     $07
ini35   push    bc
        ld      bc, $7ffd
        out     (c), a
        pop     bc
        ret
ini4
      ENDIF
      IF  machine=2
        ld      (do3+1), a
        dec     a
        ld      (screen), a
        ld      (selbeg), a
        dec     a
        ld      i, a
        im      2
ini7    ld      sp, 0
        ret
      ENDIF

    IF bithlf=1 && bitsym>1
gbit1   sub     $80 - (1 << bitsym - 2)
        defb    $da             ; second part of half bit implementation
    ENDIF
gbit2   ld      b, (hl)         ; load another group of 8 bits
        dec     hl
gbit3   rl      b               ; get next bit
        jr      z, gbit2        ; no more bits left?
        adc     a, a            ; put bit in a
        ret

      IF  machine=2
ini8    ld      c, 5
ini9    in      a, ($ff)
        inc     a
        ret     nz
        djnz    ini9
        dec     c
        jr      nz, ini9
        ret
      ENDIF

; Map file. Generated externally with TmxCompress.c from map.tmx
map     incbin  map_compressed.bin
mapend
      IF smooth=0
        block   $fd00-$&$ffff
lookt   incbin  file1.bin
        block   $fe80-$&$ffff
        incbin  file2.bin
        defb    $ff
      ELSE
        block   $fc81-$&$ffff
        incbin  file3.bin
lookt   incbin  file1.bin
      ENDIF
        block   $ff00-$&$ffff
        defb    $ff
        block   $fff1-$&$ffff
frame   jp      do_sprites
        push    af
        xor     a
        ld      (flag&$ffff), a
        pop     af
        ret
flag    defb    0
tinit   jp      init
        defb    $18
