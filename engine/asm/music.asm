;Tritone v2 beeper music engine by Shiru (shiru@mail.ru) 03'11
;Three channels of tone, per-pattern tempo
;One channel of interrupting drums
;Feel free to do whatever you want with the code, it is PD

        include build/define.asm
      IF  smooth=0
        DEFINE  desc  $fe80
      ELSE
        DEFINE  desc  $fc81+notabl
      ENDIF

        output  build/music.bin
        org     $8060

OP_NOP  equ     $00
OP_SCF  equ     $37

        ;define NO_VOLUME       ;define this if you want to have the same volume for all the channels

play    ld      c, 16
        push    iy
        exx
        push    hl
        ld      (stoppl+1), sp
        xor     a
        ld      h, a
        ld      l, h
        ld      (plrwcn0+1), hl
        ld      (plrwcn1+1), hl
        ld      (plrwcn2+1), hl
        ld      (solodu0+1),a
        ld      (solodu1+1),a
        ld      (solodu2+1),a
        ld      (nextb),a
;        in      a, ($1f)
;        and     $1f
;        ld      a, OP_NOP
;        jr      nz, play1
;        ld      a, OP_ORC
;play1   ld      (chkemp),a
        jp      nextps

nextrow ld      hl, 0
        ld      a, (hl)
        inc     hl
        cp      2
        jr      c, next1
        cp      128
        jr      c, drumso
        cp      255
        jp      z, nextps
next1   ld      d, 1
        cp      d
        jr      z, next4
        or      a
        jr      nz, next2
        ld      b, a
        ld      c, a
        jr      next3
next2   ld      e, a
        and     $0f
        ld      b, a
        ld      c, (hl)
        inc     hl
        ld      a, e
        and     $f0
next3   ld      (solodu0+1), a
        ld      (plrwcn0+1), bc
next4   ld      a, (hl)
        inc     hl
        cp      d
        jr      z, next7
        or      a
        jr      nz, next5
        ld      b, a
        ld      c, a
        jr      next6
next5   ld      e, a
        and     $0f
        ld      b, a
        ld      c, (hl)
        inc     hl
        ld      a, e
        and     $f0
next6   ld      (solodu1+1),a
        ld      (plrwcn1+1),bc
next7   ld      a, (hl)
        inc     hl
        cp      d
        jr      z, nexta
        or      a
        jr      nz, next8
        ld      b, a
        ld      c, a
        jr      next9
next8   ld      e, a
        and     $0f
        ld      b, a
        ld      c, (hl)
        inc     hl
        ld      a, e
        and     $f0
next9   ld      (solodu2+1), a
        ld      (plrwcn2+1), bc
nexta   ld      (nextrow+1), hl
nextb   scf
        jp      nc, playro
        ld      a, OP_NOP
        ld      (nextb), a
        ld      hl, (playro+1)
        ld      de, -150
        add     hl, de
        ex      de, hl
        jr      c, nextc
        ld      de, 257
nextc   ld      a, d
        or      a
        jr      nz, nextd
        inc     d
nextd   ld      a, e
        or      a
        jr      nz, nexte
        inc     e
nexte   jr      plrwcn0

drumso  ld      (nextrow+1), hl
        add     a, a
        ld      ixl, a
        ld      ixh, 0
        ld      bc, drumse-4
        add     ix, bc
        cp      14*2
        ld      a, OP_SCF
        ld      (nextb), a
        jr      nc, drumno
        ld      bc, 2
        ld      a, b
        ld      de, $1001
        ld      l, (ix)
drums1  bit     0, b
        jr      z, drums2
        dec     e
        jr      nz, drums2
        ld      e, l
        ex      af, af'
        ld      a, l
        add     a, (ix+1)
        ld      l, a
        ex      af, af'
        xor     d
drums2  out     ($fe), a
        djnz    drums1
        dec     c
        jp      nz, drums1
        jp      nextrow

drumno  ld      b, 0
        ld      h, b
        ld      l, h
        ld      de, $1001
drumn1  ld      a, (hl)
        and     d
        out     ($fe), a
        and     (ix)
        dec     e
        out     ($fe), a
        jr      nz, drumn2
        ld      e, (ix+1)
        inc     hl
drumn2  djnz    drumn1
        jp      nextrow

nextps  ld      hl, musicd
nextrd  ld      e, (hl)
        inc     hl
        ld      d, (hl)
        inc     hl
        ld      a, d
        or      e
        jr      z, orderl
        ld      (nextps+1), hl
        ex      de, hl
        ld      c, (hl)
        inc     hl
        ld      b, (hl)
        inc     hl
        ld      (nextrow+1),hl
        ld      (playro+1),bc
        jp      nextrow

orderl  ld      e, (hl)
        inc     hl
        ld      d, (hl)
        ex      de, hl
        jr      nextrd

playro  ld      de, 0
plrwcn0 ld      bc, 0
plrwphl ld      hl, 0
        exx
plrwcn1 ld      de, 0
plrwcn2 ld      sp, 0
        exx

soundl
    ifdef NO_VOLUME             ;all the channels has the same volume
        add     hl, bc          ;11
        ld      a, h            ;4
solodu0 cp      128             ;7
        sbc     a, a            ;4
        exx                     ;4
        and     c               ;4
        out     ($fe), a        ;11
        add     ix, de          ;15
        ld      a, ixh          ;8
solodu1 cp      128             ;7
        sbc     a, a            ;4
        and     c               ;4
        out     ($fe), a        ;11
        add     hl, sp          ;11
        ld      a, h            ;4
solodu2 cp      128             ;7
        sbc     a, a            ;4
        and     c               ;4
        exx                     ;4
        dec     e               ;4
        out     ($fe), a        ;11
        jp      nz, soundl      ;10=153t
        dec     d               ;4
        jp      nz, soundl      ;10
    else                        ;all the channels has different volume
        add     hl, bc          ;11
        ld      a, h            ;4
        exx                     ;4
solodu0 cp      128             ;7
        sbc     a, a            ;4
        and     c               ;4
        add     ix, de          ;15
        out     ($fe), a        ;11
        ld      a, ixh          ;8
solodu1 cp      128             ;7
        sbc     a, a            ;4
        and     c               ;4
        out     ($fe), a        ;11
        add     hl, sp          ;11
        ld      a, h            ;4
solodu2 cp      128             ;7
        sbc     a, a            ;4
        and     c               ;4
        exx                     ;4
        dec     e               ;4
        out     ($fe), a        ;11
        jp      nz, soundl      ;10=153t
        dec     d               ;4
        jp      nz, soundl      ;10
    endif

        xor     a
        out     ($fe), a
        ld      (plrwphl+1), hl
;        in      a, ($1f)
;        and     $1f
;        ld      c, a
        in      a, ($fe)
;        cpl
;chkemp  or      c
;        and     $1f
        or      $e0
        inc     a
        jp      z, nextrow
stoppl  ld      sp, 0
        pop     hl
        exx
        pop     iy
;        ei
        ret

drumse  defb    $01, $01        ;tone, highest
        defb    $01, $02
        defb    $01, $04
        defb    $01, $08
        defb    $01, $20
        defb    $20, $04
        defb    $40, $04
        defb    $40, $08        ;lowest
        defb    $04, $80        ;special
        defb    $08, $80
        defb    $10, $80
        defb    $10, $02
        defb    $20, $02
        defb    $40, $02
        defb    $16, $01        ;noise, highest
        defb    $16, $02
        defb    $16, $04
        defb    $16, $08
        defb    $16, $10
        defb    $00, $01
        defb    $00, $02
        defb    $00, $04
        defb    $00, $08
        defb    $00, $10

musicd  include build/music.asm
