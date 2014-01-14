        output  game.sna
        defb    $3f, $58, $27, $9b, $36, $96, $b9, $1e, $d5, $02, $f0, $44, $d5
        defb    $00, $00, $3a, $5c, $00, $f0, $00, $73, $45, $01, $3c, $ff, $01
        block   $5c00-$3fe5-$
        defb    $ff, $00, $00, $00, $ff, $00, $00, $00
        defb    $00, $23, $05, $00, $00, $00, $cf, $12
        defb    $01, $00, $06, $00, $0b, $00, $01, $00
        defb    $01, $00, $06, $00, $10, $00, $00, $00
        block   $5d00-$3fe5-$
        org     $5d00
        include dzx7_smartRCS.asm
        org     $5d6e-$3fe5
        block   $5e88-$3fe5-$
        incbin  game.bin
        block   $ff3c-$3fe5-$
        defw    $5e88
        block   $10000-$3fe5-$