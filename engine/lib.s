.include  /define.s/
.globl _DZX7B
.globl _PAUSE

_DZX7B::
        pop     af
        pop     hl
        pop     de
        push    af
        jp      dzx7a

_PAUSE::
        pop     af
        pop     hl
        push    af
loop1:  ld      bc, #21
loop2:  djnz    loop2
        dec     c
        jr      nz, loop2
        dec     hl
        ld      a, l
        or      h
        jr      nz, loop1
        ret
