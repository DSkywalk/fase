zx7b:   moveq   #$80, d0
copyby: move.b  -(a0), -(a1)
mainlo: bsr.s   getbit
        bcc.s   copyby
        moveq   #1, d1
        moveq   #0, d2
        bra.s   skip
lenval: bsr.s   getbit
        addx    d1, d1
skip:   bsr.s   getbit
        bcc.s   lenval
        cmpi.b  #$ff, d1
        beq.s   return
        move.b  -(a0), d3
        lsl.b   #1, d3
        bcc.s   offend
        moveq   #$10, d2
nexbit: bsr.s   getbit
        addx.b  d2, d2
        bcc     nexbit
        addq    #1, d2
        lsr     #1, d2
offend: roxr.b  #1, d3
        lsl     #8, d2
        add     d3, d2
bucle:  move.b  (a1, d2), -(a1)
        dbra    d1, bucle
        bra.s   mainlo

getbit: add.b   d0, d0
        bne.s   return
        move.b  -(a0), d0
        addx.b  d0, d0
return: rts
