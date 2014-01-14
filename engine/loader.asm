        include ndefload.asm
        DEFINE  border_loading 0
      IF  smooth=0
        DEFINE  desc  $fe80
        DEFINE  ramt  $fd00
      ELSE
        DEFINE  desc  $fc81
        DEFINE  ramt  desc
      ENDIF
        display "----------------------------"
        display /A,0x7e50-stasp-main_size, " bytes free"
        display "____________________________"
        output  loader.bin
        org     $5b06+ini-prnbuf
ini     ld      de, desc
        di
        db      $de, $c0, $37, $0e, $8f, $39, $96 ;OVER USR 7 ($5ccb)
        ld      hl, $5ccb+descom-ini
        ld      bc, $7f
        ldir
      IF  border_loading=0
        xor     a
      ELSE
        ld      a, border_loading
      ENDIF
        out     ($fe), a
        ld      hl, $5ccb+descom-ini-1
        ld      de, $5aff
        call    desc
        ld      hl, $8000-maplen
        ld      de, engcomp_size
        push    hl
        call    $07f4
        di
        pop     hl
        ld      de, ramt-maplen
        ld      bc, maplen
        ldir
        ld      hl, $8000-maplen+engcomp_size-1
        ld      de, ramt-1-maplen
        call    desc
        ld      sp, $5b06
        ld      de, $ffff
        ld      hl, ramt-1-maplen-codel2-codel1-codel0-bl2len
      IF  smooth=0
        ld      bc, $101
        lddr
        ld      e, $7f
        ld      bc, $180
      ELSE
        ld      bc, $300
      ENDIF
        lddr
        ld      hl, $5ccb+prnbuf-ini
        ld      de, $5b06
        push    de
        ld      c, fin-prnbuf
        ldir
        ret
prnbuf  ld      a, $17
        ld      bc, $7ffd
        out     (c), a
        ld      ($fffb), a
        ld      a, $10
        out     (c), a
        ld      a, ($fffb)
        cp      $17
        ld      de, ramt-1-maplen
        jr      z, next
        ld      hl, ramt-1-maplen-codel2
        ld      bc, codel1
        lddr
        ld      hl, init1
        ld      ($fffd), hl
        ld      hl, frame1
        ld      ($fff2), hl
        jr      copied
next    call    ramt-maplen-12
        jr      z, copied
        ld      hl, ramt-1-maplen-codel2-codel1
        ld      bc, codel0
        lddr
        ld      hl, init0
        ld      ($fffd), hl
        ld      hl, frame0
        ld      ($fff2), hl
copied  ld      hl, ramt-1-maplen-codel2-codel1-codel0-bl2len-$281-$7f*smooth
        ld      de, $7fff
        ld      bc, $23f8
        lddr
      IF  bl2len>0
        ld      hl, ramt-maplen-codel2-codel1-codel0-1
        ld      de, $10000-stasp+bl2len-1
        ld      bc, bl2len
        lddr
      ENDIF
        ld      hl, $ffff
        ld      ($fffe-stasp), hl
        ld      hl, $8000+maincomp_size-1
        ld      de, $8040+main_size-1
        call    desc
        ld      hl, $8040
        ld      de, $8000
        ld      sp, 0xfe50-stasp
        push    de
        ld      bc, main_size
        ldir
        ret
fin
screen  incbin  loading.zx7
descom  
      IF  smooth=0
        incbin  file2.bin
      ELSE
        incbin  file3.bin
      ENDIF
