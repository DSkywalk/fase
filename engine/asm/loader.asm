        DEFINE  machine 1
        output  build/nulo.bin
        include asm/engine.asm

        include build/ndefload.asm
      IF  smooth=0
        DEFINE  desc  $fe80
        DEFINE  ramt  $fd00+notabl
      ELSE
        DEFINE  desc  $fc81+notabl
        DEFINE  ramt  desc
      ENDIF
        display "----------------------------"
        display /A,0x7fad-tmpbuf-stasp-mainrw-scrlen, " bytes free"
        display "____________________________"
        output  build/loader.bin
        org     $5b0a+ini-prnbuf
ini     ld      de, desc        ; apunto al descompresor
        di
        db      $de, $c0, $37, $0e, $8f, $39, $96 ;OVER USR 7 ($5ccb)
        ld      hl, $5ccb+descom-ini
        ld      bc, $7f
        ldir                    ; muevo el descompresor a su sitio
        ld      hl, $5b00
        ld      de, $5aff
        push    de
        ld      (hl), $3f
        ld      b, 3
        lddr                    ; pongo pantalla en blanco
        ld      hl, $5ccb+descom-ini-1
        call    desc            ; descomprimo bitmap pantalla carga
        push    hl
        call    drcs            ; aplico filtro inverso
        pop     hl
        pop     de
        call    desc            ; descomprimo atributos
        ld      hl, ramt-engicm
        ld      de, engicm
        call    $07f4           ; cargo bloque cinta principal
        di
        ld      hl, $ffff
        ld      ($feff), hl
        ld      a, $fe
        ld      i, a
        im      2
        ld      hl, $5ccb+prnbuf-ini
        ld      de, $8000
        ld      bc, mitad-prnbuf
        ldir                    ; copio resto del cargador encima de memoria video
        ld      hl, $5ccb+mitad-ini
        ld      de, $5b0a
        ld      c, ldscrn-mitad
        ldir                    ; copio resto del cargador encima de memoria video
        ld      hl, ramt-engicm+blo1cm-1
        ld      de, $7fff
        jp      $8000+salto-prnbuf

prnbuf  out     (c), a
        exx
        call    $c00d
        exx
        ld      a, ($5c01)      ; toggle port value between 00 and 80 every frame
        xor     $80
        ld      ($5c01), a
        ld      a, $18          ; also toggle between bank 5 & 7 for the screen
        jr      z, prnbuf       ; and 7 & 0 for the current paging at $c000
        dec     a               ; so we always show a screen and modify the other
        jr      prnbuf
salto   call    desc
        ld      hl, ramt-engicm+blo1cm
        ld      de, $8000+mitad-prnbuf
        ld      bc, music+scrlen+maincm
        ldir                    ; bajo music+scrlen+maincm
        ld      hl, ramt-engicm+blo1cm+music+scrlen+maincm+blo2cm-1
        ld      de, $8000+mitad-prnbuf+music+scrlen+maincm+codel2+codel1+codel0+bl2len+$281+$7f*smooth-notabl-1
        call    desc            ; descomprimo block2
        ld      sp, $5b0a
        ld      de, $ffff
        ld      hl, $8000+mitad-prnbuf+music+scrlen+maincm+$281+$7f*smooth-notabl-1
    IF  smooth=0
        inc     b
        inc     c
        lddr
        ld      e, $7f
      IF notabl
        ld      c, $80
      ELSE
        ld      bc, $180
      ENDIF
    ELSE
        ld      b, 3-(notabl>>8)
    ENDIF
        lddr                    ; alto arriba
        ld      a, $17          ; compruebo si 128k
        ld      bc, $7ffd
        out     (c), a
        ld      ($fff8), a
        ld      a, $10
        out     (c), a
        ld      a, ($fff8)
        cp      $17
        ld      de, ramt-1-maplen
        jp      $5b0a

mitad   jr      z, next         ; si no, salto a next
        ld      de, $8000+mitad-prnbuf+music+scrlen+maincm+$281+$7f*smooth-notabl+bl2len+codel0-1
        ld      hl, desc+$7e
        ld      bc, $7f
        lddr
        ld      a, $11
        ld      bc, $7ffd
        out     (c), a
        ex      de, hl
        ld      bc, $80         ; en realidad menos, no necesito filtro rcs
        ldir                    ; recopio descompresor en página 1
        ld      hl, $c000
        ld      de, player
        call    $07f4           ; cargo bloque wyzplayer comprimido
        di
        ld      hl, $c000+player-1
        ld      de, $c000+playrw+3
        call    desc            ; descomprimo
        ld      de, do1+6
        ld      hl, $8000
        ld      c, salto-prnbuf
        ldir                    ; copio pequeño fragmento/parche
        ld      a, $10
        ld      bc, $7ffd
        out     (c), a
        ld      de, ramt-1-maplen
        ld      hl, init1
        ld      ($fffd), hl
        ld      hl, frame1
        ld      ($fffa), hl
        ld      a, parche
        ld      ($fff7), a      ; apunto vectores para máquina 1
        ld      a, $c3
        ld      ($fff4), a      ; apunto vectores para máquina 1
        ld      hl, $8000+mitad-prnbuf+music+scrlen+maincm+$281+$7f*smooth-notabl+bl2len+codel0+codel1-1
        ld      bc, codel1
        jr      copied
next    call    $8000+mitad-prnbuf+music+scrlen+maincm+$281+$7f*smooth-notabl+bl2len+codel0+codel1+codel2-12  ; llamo rutina comprobación bus flotante
        ld      hl, $8000+mitad-prnbuf+music+scrlen+maincm+$281+$7f*smooth-notabl+bl2len+codel0+codel1+codel2-1
        ld      bc, codel2
        jr      z, copied       ; si hay bus flotante me quedo con máquina 2
        ld      hl, init0
        ld      ($fffd), hl
        ld      hl, frame0
        ld      ($fffa), hl     ; con sus vectores
        ld      hl, $8000+mitad-prnbuf+music+scrlen+maincm+$281+$7f*smooth-notabl+bl2len+codel0-1
        ld      bc, codel0      ; aquí me puedo ahorrar 1 byte
copied  lddr                    ; copio máquina 0 ó 2
      IF  bl2len>0
        ld      hl, $8000+mitad-prnbuf+music+scrlen+maincm+$281+$7f*smooth-notabl+bl2len-1
        ld      de, $10000-stasp+bl2len-1
        ld      bc, bl2len
        lddr                    ; sprites_reloc2 si existe
      ENDIF
        ld      hl, $8000+mitad-prnbuf+music+scrlen-1
        ld      de, 0xffad-tmpbuf-stasp ; 10 calls anidados
        ld      bc, scrlen
        lddr
        dec     bc
        ld      ($fffe-stasp), bc
      IF  music>0
        ld      hl, $8000+mitad-prnbuf+music-1
        ld      de, $8060+musirw-1
        call    desc
      ENDIF    
        ld      sp, 0x10000-tmpbuf-stasp
        ld      hl, 0xffad-tmpbuf-stasp-1
        ld      e, (hl)
        inc     hl
        ld      d, (hl)
        add     hl, de
        ld      a, (hl)
        rrca
        rra
        dec     hl
        push    hl
        ld      hl, $5aff
        ld      de, $5afe
        ld      bc, $02ff
        ld      (hl), a
        lddr                    ; pongo pantalla en blanco
        pop     hl
        call    desc
        push    hl
        call    desc+65
        pop     hl
        ld      de, $5aff
        call    desc
      IF  music>0
        call    $8060
      ELSE
        out     ($fe), a
      ENDIF
        ld      hl, $8000+mitad-prnbuf+music+scrlen
        ld      de, $8000
        ld      bc, maincm
        ldir
        ex      de, hl
        dec     hl
        ld      de, $8004+mainrw-1
        call    desc            ; descomprimo main.bin
        jp      $8004
ldscrn  incbin  build/loading.atr.zx7b
        incbin  build/loading.rcs.zx7b
descom  org     desc
        include asm/dzx7b_rcs.asm
