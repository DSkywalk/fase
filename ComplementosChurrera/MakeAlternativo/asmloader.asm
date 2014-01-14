        include define.asm
        output  asmloader.bin
        org     $5ccb
ini     ld      de, $4000
        di
        db      $de, $c0, $37, $0e, $8f, $39, $96 ;OVER USR 7 ($5ccb)
aki     ld      hl, screen
        call    descom
        ld      hl, $f000-COMP_SIZE
        push    hl
        ld      de, COMP_SIZE
        call    $07f4
        di
        ld      a, BORDER_LOADING
        out     ($fe), a
        pop     hl
        ld      de, 24200
        push    de
        defb    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
descom  include dzx7_smartRCS.asm
screen  incbin  loading.bin