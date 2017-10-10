                mov     al, $80
copyby          movsb
mainlo          call    bp
                jnc     copyby
                mov     bh, cl
                db      $3d
lenval          call    bp
                rcl     cx, 1
                call    bp
                jnc     lenval
                inc     cl
                jz      toret
                mov     bl, [si]
                dec     si
                rcl     bl, 1
                jnc     offend
                mov     bh, $10
nexbit          call    bp
                rcl     bh, 1
                jnc     nexbit
                inc     bh
                shr     bh, 1
offend          rcr     bl, 1
                push    si
                lea     si, [di+bx+1]
                rep     movsb
                pop     si
                jmp     mainlo
getbit          add     al, al
                jnz     toret
                lodsb
                adc     al, al
toret           ret
