
        output  build/player.bin
        org     $c000
        jp      inicio
        jp      cancion
        jp      poff

; SPECTRUM PSG proPLAYER V 0.2 - WYZ 07.09.2011
; VER AL FINAL PARA DATOS PROPIOS:

; ISR LLAMA A:
inicio  call    rout
        ld      hl, psg_reg
        ld      de, psg_reg_sec
        ld      bc, 14
        ldir                
        call    reproduce_sonido
        call    reproduce_efecto

;play __________________________________________________
        ld      hl, interr               ;play bit 1 on?
        bit     1, (hl)
        ret     z
;tempo          
        inc     l
;        ld      hl, ttempo               ;contador tempo
        inc     (hl)
        ld      a, (tempo)
        sub     (hl)
        jr      nz, pautas
        ld      (hl), a
            
;INTERPRETA      
        ld      iy, psg_reg
        ld      ix, puntero_a
        ld      bc, psg_reg+8
        call    localiza_nota
        ld      iy, psg_reg+2
        ld      ix, puntero_b
        ld      bc, psg_reg+9
        call    localiza_nota
        ld      iy, psg_reg+4
        ld      ix, puntero_c
        ld      bc, psg_reg+10
        call    localiza_nota
        ld      ix, puntero_p   ;el canal de efectos enmascara otro canal
        call    localiza_efecto

;pautas               
pautas  ld      iy, psg_reg+0
        ld      ix, puntero_p_a
        ld      hl, psg_reg+8
        call    pauta           ;pauta canal a
        ld      iy, psg_reg+2
        ld      ix, puntero_p_b
        ld      hl, psg_reg+9
        call    pauta           ;pauta canal b
        ld      iy, psg_reg+4
        ld      ix, puntero_p_c
        ld      hl, psg_reg+10  ;pauta canal c

; PAUTA DE LOS 3 CANALES
; IN:(IX):PUNTERO DE LA PAUTA
;    (HL):REGISTRO DE VOLUMEN
;    (IY):REGISTROS DE FRECUENCIA

; FORMATO PAUTA 
;       7    6     5     4   3-0                        3-0  
; BYTE 1 (LOOP|OCT-1|OCT+1|ORNMT|VOL) - BYTE 2 ( | | | |PITCH/NOTA)

pauta   bit     4, (hl)         ;si la envolvente esta activada no actua pauta
        ret     nz
        ld      a, (iy+0)
        ld      b, (iy+1)
        or      b
        ret     z
        push    hl
pcajp4  ld      l, (ix+0)
        ld      h, (ix+1)         
        ld      a, (hl)
        bit     7, a            ;loop / el resto de bits no afectan
        jr      z, pcajp0
        and     %00011111       ;máximo loop pauta (0,32)x2!!!-> para ornamentos
        rlca                    ;x2
        ld      d, 0
        ld      e, a
        sbc     hl, de
        ld      a, (hl)
pcajp0  bit     6, a            ;octava -1
        jr      z, pcajp1
        ld      e, (iy+0)
        ld      d, (iy+1)
        and     a
        rrc     d
        rr      e
        ld      (iy+0), e
        ld      (iy+1), d
        jr      pcajp2
pcajp1  bit     5, a            ;octava +1
        jr      z, pcajp2
        ld      e, (iy+0)
        ld      d, (iy+1)
        and     a
        rlc     e
        rl      d
        ld      (iy+0), e
        ld      (iy+1), d        
pcajp2  ld      a, (hl)
        bit     4, a
        jr      nz, pcajp6      ;ornamentos seleccionados
        inc     hl              ;funcion pitch de frecuencia
        push    hl
        ld      e, a
        ld      a, (hl)         ;pitch de frecuencia
        ld      l, a
        and     a
        ld      a, e
        jr      z, ornmjp1
        ld      a, (iy+0)       ;si la frecuencia es 0 no hay pitch
        add     a, (iy+1)
        and     a
        ld      a, e
        jr      z, ornmjp1
        bit     7, l
        jr      z, ornneg
        ld      h, $ff
        jr      pcajp3
ornneg  ld      h, 0
pcajp3  ld      e, (iy+0)
        ld      d, (iy+1)
        adc     hl, de
        ld      (iy+0), l
        ld      (iy+1), h
        jr      ornmjp1
pcajp6  inc     hl              ;funcion ornamentos
        push    hl
        push    af
        ld      a, (ix+24)      ;recupera registro de nota en el canal
        ld      e, (hl)
        adc     a, e            ;+- nota 
        call    tabla_notas
        pop     af
ornmjp1 pop     hl
        inc     hl
        ld      (ix+0), l
        ld      (ix+1), h
pcajp5  pop     hl
        and     %00001111       ;volumen final
        ld      (hl), a
        ret

;carga una cancion
;in:(a)=nº de cancion
cancion ld      hl, interr      ;carga cancion
        set     1, (hl)         ;reproduce cancion
        ld      hl, song
        ld      (hl), a         ;nº (a)
;decodificar
;in-> interr 0 on
;     song
;carga cancion si/no
;decode_song:

        ld      a, (song)

;lee cabecera de la cancion
;byte 0=tempo

        ld      hl, tabla_song
        call    ext_word
        ld      a, (hl)
        ld      (tempo), a
        xor     a
        ld      (ttempo), a
            
;header byte 1
;(-|-|-|-|-|-|-|loop)

        inc     hl              ;loop 1=on/0=off?
        ld      a, (hl)
        bit     0, a
        jr      z, nptjp0
        push    hl
        ld      hl, interr
        set     4, (hl)
        pop     hl
nptjp0  inc     hl              ;2 bytes reservados
        inc     hl
        inc     hl

;busca y guarda inicio de los canales en el modulo mus
    
        ld      (puntero_p_deca), hl
        ld      e, $3f          ;codigo intrumento 0
        ld      b, $ff          ;el modulo debe tener una longitud menor de $ff00 ... o_o!
bgicmo1 xor     a               ;busca el byte 0
        cpir
        dec     hl
        dec     hl
        ld      a, e            ;es el instrumento 0??
        cp      (hl)
        inc     hl
        inc     hl
        jr      z, bgicmo1
        ld      (puntero_p_decb), hl
bgicmo2 xor     a               ;busca el byte 0
        cpir
        dec     hl
        dec     hl
        ld      a, e
        cp      (hl)            ;es el instrumento 0??
        inc     hl
        inc     hl
        jr      z, bgicmo2
        ld      (puntero_p_decc), hl
bgicmo3 xor     a               ;busca el byte 0
        cpir
        dec     hl
        dec     hl
        ld      a, e
        cp      (hl)            ;es el instrumento 0??
        inc     hl
        inc     hl
        jr      z, bgicmo3
        ld      (puntero_p_decp), hl

;lee datos de las notas
;(|)(|||||) longitud\nota
; init_decoder:
        ld      de, (canal_a)
        ld      (puntero_a), de
        ld      hl, (puntero_p_deca)
        call    decode_canal    ;canal a
        ld      (puntero_deca), hl
        ld      de, (canal_b)
        ld      (puntero_b), de
        ld      hl, (puntero_p_decb)
        call    decode_canal    ;canal b
        ld      (puntero_decb), hl
        ld      de, (canal_c)
        ld      (puntero_c), de
        ld      hl, (puntero_p_decc)
        call    decode_canal    ;canal c
        ld      (puntero_decc), hl
        ld      de, (canal_p)
        ld      (puntero_p), de
        ld      hl, (puntero_p_decp)
        call    decode_canal    ;canal p
        ld      (puntero_decp), hl
        ret


;DECODIFICA NOTAS DE UN CANAL
;IN (DE)=DIRECCION DESTINO
;NOTA=0 FIN CANAL
;NOTA=1 SILENCIO
;NOTA=2 PUNTILLO
;NOTA=3 COMANDO I

decode_canal:   
            LD      A,(HL)
            AND     A                       ;FIN DEL CANAL?
            JR      Z,FIN_DEC_CANAL
            CALL    GETLEN

            CP      00000001B               ;ES SILENCIO?
            JR      NZ,NO_SILENCIO
            SET     6,A
            JR      NO_MODIFICA
                
NO_SILENCIO:    
            CP      00111110B               ;ES PUNTILLO?
            JR      NZ,NO_PUNTILLO
            OR      A
            RRC     B
            XOR     A
            JR      NO_MODIFICA

NO_PUNTILLO:   
             CP      00111111B              ;ES COMANDO?
            JR      NZ,NO_MODIFICA
            BIT     0,B                     ;COMADO=INSTRUMENTO?
            JR      Z,NO_INSTRUMENTO   
            LD      A,11000001B             ;CODIGO DE INSTRUMENTO      
            LD      (DE),A
            INC     HL
            INC     DE
            LD      A,(HL)                  ;Nº DE INSTRUMENTO
            LD      (DE),A
            INC     DE
            INC     HL
            JR      decode_canal
            
NO_INSTRUMENTO: 
            BIT     2,B
            JR      Z,NO_ENVOLVENTE
            LD      A,11000100B             ;CODIGO ENVOLVENTE
            LD      (DE),A
            INC     DE
            INC HL
            LD  A,(HL)
            LD  (DE),A
            INC DE
            INC HL
            JR      decode_canal
     
NO_ENVOLVENTE:  
            BIT     1,B
            JR      Z,NO_MODIFICA           
            LD      A,11000010B             ;CODIGO EFECTO
            LD      (DE),A                  
            INC     HL                      
            INC     DE                      
            LD      A,(HL)                  
            CALL    GETLEN   
                
NO_MODIFICA:    
            LD      (DE),A
            INC     DE
            XOR     A
            DJNZ    NO_MODIFICA
            SET     7,A
            SET     0,A
            LD      (DE),A
            INC     DE
            INC     HL
            RET                 ;** JR      DECODE_CANAL
                
FIN_DEC_CANAL:  
            SET     7,A
            LD      (DE),A
            INC     DE
            RET

GETLEN:     LD      B,A
            AND     00111111B
            PUSH    AF
            LD      A,B
            AND     11000000B
            RLCA
            RLCA
            INC     A
            LD      B,A
            LD      A,10000000B
DCBC0:      RLCA
            DJNZ    DCBC0
            LD      B,A
            POP     AF
            RET

;REPRODUCE EFECTOS DE SONIDO 

reproduce_sonido:
            LD      HL,interr   
            BIT     2,(HL)                  ;ESTA ACTIVADO EL EFECTO?
            RET     Z
            LD      HL,(PUNTERO_SONIDO)
            LD      A,(HL)
            CP      $FF
            JR      Z,FIN_SONIDO
            LD      (psg_reg_sec+2),A
            INC     HL
            LD      A,(HL)
            RRCA
            RRCA
            RRCA
            RRCA
            AND     00001111B
            LD      (psg_reg_sec+3),A
            LD      A,(HL)
            AND     00001111B
            LD      (psg_reg_sec+9),A
            INC     HL
            LD      A,(HL)
            AND     A
            JR      Z,NO_RUIDO
            LD      (psg_reg_sec+6),A
            LD      A,10101000B
            JR      SI_RUIDO
NO_RUIDO:   LD      A,10111000B
SI_RUIDO:   LD      (psg_reg_sec+7),A
       
            INC     HL
            LD      (PUNTERO_SONIDO),HL
            RET
            
FIN_SONIDO: LD      HL,interr
            RES     2,(HL)

FIN_NOPLAYER:
            LD      A,10111000B
            LD      (psg_reg+7),A
            RET         
                
;LOCALIZA NOTA CANAL A
;IN (puntero_a)

localiza_nota:  
            LD      L,(IX)  ;HL=(PUNTERO_A_C_B)
            LD      H,(IX+1)
            LD      A,(HL)
            AND     11000000B               ;COMANDO?
            CP      11000000B
            JR      NZ,LNJP0

;BIT(0)=INSTRUMENTO
                
COMANDOS:   LD      A,(HL)
            BIT     0,A                     ;INSTRUMENTO
            JR      Z,COM_EFECTO

            INC     HL
            LD      A,(HL)                  ;Nº DE PAUTA
            INC     HL
            LD      (IX),L
            LD      (IX+1),H
            LD      HL,TABLA_PAUTAS
            CALL    ext_word
            LD      (IX+PUNTERO_P_A0-puntero_a),L
            LD      (IX+PUNTERO_P_A0-puntero_a+1),H
            LD      (IX+puntero_p_a-puntero_a),L
            LD      (IX+puntero_p_a-puntero_a+1),H
            LD      L,C
            LD      H,B
            RES     4,(HL)                  ;APAGA EFECTO ENVOLVENTE
            XOR     A
            LD      (psg_reg_sec+13),A
            LD      (psg_reg+13),A
            JR      localiza_nota

COM_EFECTO: BIT     1,A                     ;EFECTO DE SONIDO
            JR      Z,COM_ENVOLVENTE

            INC     HL
            LD      A,(HL)
            INC     HL
            LD      (IX),L
            LD      (IX+1),H
;INICIA EL SONIDO Nº (A)
INICIA_SONIDO:  
            LD      HL,TABLA_SONIDOS
            CALL    ext_word
            LD      (PUNTERO_SONIDO),HL
            LD      HL,interr
            SET     2,(HL)
            RET

COM_ENVOLVENTE: 

            BIT     2,A
            RET     Z                       ;IGNORA - ERROR            
       
            INC     HL
            LD      A,(HL)                  ;CARGA CODIGO DE ENVOLVENTE
            LD      (ENVOLVENTE),A
            INC     HL
            LD      (IX),L
            LD      (IX+1),H
            LD      L,C
            LD      H,B
            LD      (HL),00010000B          ;ENCIENDE EFECTO ENVOLVENTE
            JR      localiza_nota
              
LNJP0:      LD      A,(HL)
            INC     HL
            BIT     7,A
            JR      Z,NO_FIN_CANAL_A    ;
            BIT     0,A
            JR      Z,FIN_CANAL_A

FIN_NOTA_A: LD      E,(IX+canal_a-puntero_a)
            LD      D,(IX+canal_a-puntero_a+1)      ;PUNTERO BUFFER AL INICIO
            LD      (IX),E
            LD      (IX+1),D
            LD      L,(IX+puntero_deca-puntero_a)   ;CARGA PUNTERO DECODER
            LD      H,(IX+puntero_deca-puntero_a+1)
            PUSH    BC
            CALL    decode_canal                    ;DECODIFICA CANAL
            POP     BC
            LD      (IX+puntero_deca-puntero_a),L   ;GUARDA PUNTERO DECODER
            LD      (IX+puntero_deca-puntero_a+1),H
            JP      localiza_nota
            
FIN_CANAL_A:    
            LD      HL,interr           ;LOOP?
            BIT     4,(HL)              
            JR      NZ,FCA_CONT
poff    xor     a
        ld      (interr), a
        ld      hl, psg_reg
        ld      de, psg_reg+1
        ld      bc, 14*2-1
        ld      (hl), a
        ldir
rout    ld      de, $ffc0
        ld      bc, $fffe
        ld      hl, psg_reg_sec+13
        xor     a
        cpd
        jr      nz, qout
sout    ld      a, 12
lout    out     (c), a
        ld      b, e
        outd
        ld      b, d
        dec     a
        jp      p, lout
        ret
qout    ld      a, 13
        out     (c), a
        inc     l
        ld      b, e
        outd
        xor     a
        ld      (psg_reg_sec+13), a
        ld      (psg_reg+13), a
        jr      sout


FCA_CONT:   LD      L,(IX+puntero_p_deca-puntero_a) ;CARGA PUNTERO INICIAL DECODER
            LD      H,(IX+puntero_p_deca-puntero_a+1)
            LD      (IX+puntero_deca-puntero_a),L
            LD      (IX+puntero_deca-puntero_a+1),H
            JR      FIN_NOTA_A
                
NO_FIN_CANAL_A: 
            LD      (IX),L      ;(PUNTERO_A_B_C)=HL GUARDA PUNTERO
            LD      (IX+1),H
            AND     A                               ;NO REPRODUCE NOTA SI NOTA=0
            JR      Z,FIN_RUTINA
            BIT     6,A                             ;SILENCIO?
            JR      Z,NO_SILENCIO_A
            LD      A,(BC)
            AND     00010000B
            JR      NZ,SILENCIO_ENVOLVENTE
            XOR     A
            LD      (BC),A                          ;RESET VOLUMEN DEL CORRESPODIENTE CHIP
            LD      (IY+0),A
            LD      (IY+1),A
            RET
        
SILENCIO_ENVOLVENTE:
            LD  A,$FF
            LD  (psg_reg+11),A
            LD  (psg_reg+12),A               
            XOR A
            LD  (psg_reg+13),A                               
            LD  (IY+0),A
            LD  (IY+1),A
            RET

NO_SILENCIO_A:  
            LD  (IX+REG_NOTA_A-puntero_a),A ;REGISTRO DE LA NOTA DEL CANAL         
            CALL    NOTA                    ;REPRODUCE NOTA
            LD      L,(IX+PUNTERO_P_A0-puntero_a)   ;HL=(PUNTERO_P_A0) RESETEA PAUTA 
            LD      H,(IX+PUNTERO_P_A0-puntero_a+1)
            LD      (IX+puntero_p_a-puntero_a),L    ;(PUNTERO_P_A)=HL
            LD      (IX+puntero_p_a-puntero_a+1),H
FIN_RUTINA:     
            RET

;LOCALIZA EFECTO
;IN HL=(PUNTERO_P)

localiza_efecto:
            LD      L,(IX+0)                ;HL=(PUNTERO_P)
            LD      H,(IX+1)
            LD      A,(HL)
            CP      11000010B
            JR      NZ,LEJP0

            INC     HL
            LD      A,(HL)
            INC     HL
            LD      (IX+00),L
            LD      (IX+01),H
            CALL    INICIA_SONIDO
            RET
              
LEJP0:      INC     HL
            BIT     7,A
            JR      Z,NO_FIN_CANAL_P    ;
            BIT     0,A
            JR      Z,FIN_CANAL_P
            
FIN_NOTA_P: 
            LD      DE,(canal_p)
            LD      (IX+0),E
            LD      (IX+1),D
            LD      HL,(puntero_decp)       ;CARGA PUNTERO DECODER
            PUSH    BC
            CALL    decode_canal            ;DECODIFICA CANAL
            POP     BC
            LD      (puntero_decp),HL       ;GUARDA PUNTERO DECODER
            JP      localiza_efecto
                
FIN_CANAL_P:    
            LD      HL,(puntero_p_decp)     ;CARGA PUNTERO INICIAL DECODER
            LD      (puntero_decp),HL
            JR      FIN_NOTA_P
                
NO_FIN_CANAL_P: 
            LD      (IX+0),L                ;(PUNTERO_A_B_C)=HL GUARDA PUNTERO
            LD      (IX+1),H
            RET

;NOTA : REPRODUCE UNA NOTA
;IN (A)=CODIGO DE LA NOTA
;   (IY)=REGISTROS DE FRECUENCIA


NOTA:       LD      L,C
            LD      H,B
            BIT     4,(HL)
            LD      B,A
            JR      NZ,ENVOLVENTES
            LD      A,B
tabla_notas LD      HL,DATOS_NOTAS      ;BUSCA FRECUENCIA
            CALL    ext_word
            LD      (IY+0),L
            LD      (IY+1),H
            RET

;IN (A)=CODIGO DE LA ENVOLVENTE
;   (IY)=REGISTRO DE FRECUENCIA

ENVOLVENTES:
            LD      HL,DATOS_NOTAS      ;BUSCA FRECUENCIA
            CALL    ext_word
        
            LD      A,(ENVOLVENTE)      ;FRECUENCIA DEL CANAL ON/OFF
LOCALIZA_ENV:   
            RRA
            JR      FRECUENCIA_OFF
            LD      (IY+0),L
            LD      (IY+1),H
            JR      CONT_ENV
                
FRECUENCIA_OFF:     
            LD      HL,$0000
            LD      (IY+0),L
            LD      (IY+1),H

;CALCULO DEL RATIO (OCTAVA ARRIBA)

CONT_ENV:   PUSH    AF
            PUSH    BC
            AND     00000011B
            LD      B,A
            INC     B
            XOR     A
OCTBC01:    ADD     A,12                ;INCREMENTA OCTAVAS
            DJNZ    OCTBC01
            POP     BC                  ;RECUPERA CODIGO DE LA NOTA
            ADD     A,B                   ;EN REGISTRO A CODIGO NOTA
            
            LD      HL,DATOS_NOTAS      ;BUSCA FRECUENCIA
            CALL    ext_word
                
            LD      A,L
            LD      (psg_reg+11),A
            LD      A,H
            AND     00000011B
            LD      (psg_reg+12),A
            POP     AF                  ;SELECCION FORMA DE ENVOLVENTE
                
            RRA
            AND     00000110B           ;$08,$0A,$0C,$0E
            ADD     A,8                
            LD      (psg_reg+13),A
       
            RET

;EXTRAE UN WORD DE UNA TABLA
;IN:(HL)=DIRECCION TABLA
;   (A)= POSICION
;OUT(HL)=WORD

ext_word    LD      D,0
            RLCA
            LD      E,A
            ADD     HL,DE
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            EX      DE,HL
            RET

;;;;;;;; EFECTOS DE SONIDO ;;;;;;;;;;;
            
INICIA_EFECTO:  
            LD      A,B
            LD      HL,TABLA_EFECTOS
            CALL    ext_word
            LD      (PUNTERO_EFECTO),HL
            LD      HL,interr
            SET     3,(HL)
            RET       

reproduce_efecto:
            LD      HL,interr   
            BIT     3,(HL)             ;ESTA ACTIVADO EL EFECTO?
            RET     Z
            LD      HL,(PUNTERO_EFECTO)
            LD      A,(HL)
            CP      $FF
            JP      Z,FIN_EFECTO
            LD      B,A                 ;FRECUENCIA FINO
            INC     HL
            LD      A,(HL)
            RRCA
            RRCA
            RRCA
            RRCA
            AND     00001111B
            LD      C,A                 ;FRECUENCIA GRAVE
            LD      A,(HL)
            DEC     A                   ;DEC A PARA BAJR VOLUMEN!!
            AND     00001111B

            LD   D,A                    ;VOLUMEN
            INC     HL                  ;INCREMENTA Y GUARDA EL PUNTERO
            LD      (PUNTERO_EFECTO),HL     
            LD      IX,psg_reg_sec
            LD      A,(CANAL_EFECTOS)   ;SELECCION DE CANAL
            CP      1
            JR      Z,RS_CANALA
            CP      2
            JR      Z,RS_CANALB
  
RS_CANALC:  LD      (IX+4),B
            LD      (IX+5),C
            LD      (IX+10),D
            RET      
  
RS_CANALA:  LD      (IX+0),B
            LD      (IX+1),C
            LD      (IX+8),D
            RET
           
RS_CANALB:  LD      (IX+2),B
            LD      (IX+3),C
            LD      (IX+9),D
            RET
           
FIN_EFECTO: LD      HL,interr
            RES     3,(HL)              ;DESACTIVA EFECTO
            RET         

; VARIABLES__________________________


interr          DB     00               ;INTERRUPTORES 1=ON 0=OFF
                                        ;BIT 0=CARGA CANCION ON/OFF
                                        ;BIT 1=PLAYER ON/OFF
                                        ;BIT 2=SONIDOS ON/OFF
                                        ;BIT 3=EFECTOS ON/OFF
ttempo          DB     00               ;DB CONTADOR TEMPO
tempo           DB     00               ;DB TEMPO
song            DB     00               ;DBNº DE CANCION
puntero_a       DW     00               ;DW PUNTERO DEL CANAL A
puntero_b       DW     00               ;DW PUNTERO DEL CANAL B
puntero_c       DW     00               ;DW PUNTERO DEL CANAL C

canal_a         DW     BUFFERS_CANALES      ;DW DIRECION DE INICIO DE LA MUSICA A
canal_b         DW     BUFFERS_CANALES+$30  ;DW DIRECION DE INICIO DE LA MUSICA B
canal_c         DW     BUFFERS_CANALES+$60  ;DW DIRECION DE INICIO DE LA MUSICA C

puntero_p_a     DW     00               ;DW PUNTERO PAUTA CANAL A
puntero_p_b     DW     00               ;DW PUNTERO PAUTA CANAL B
puntero_p_c     DW     00               ;DW PUNTERO PAUTA CANAL C

PUNTERO_P_A0:   DW     00               ;DW INI PUNTERO PAUTA CANAL A
PUNTERO_P_B0:   DW     00               ;DW INI PUNTERO PAUTA CANAL B
PUNTERO_P_C0:   DW     00               ;DW INI PUNTERO PAUTA CANAL C


puntero_p_deca  DW     00               ;DW PUNTERO DE INICIO DEL DECODER CANAL A
puntero_p_decb  DW     00               ;DW PUNTERO DE INICIO DEL DECODER CANAL B
puntero_p_decc  DW     00               ;DW PUNTERO DE INICIO DEL DECODER CANAL C

puntero_deca    DW     00               ;DW PUNTERO DECODER CANAL A
puntero_decb    DW     00               ;DW PUNTERO DECODER CANAL B
puntero_decc    DW     00               ;DW PUNTERO DECODER CANAL C       

REG_NOTA_A:     DB     00               ;DB REGISTRO DE LA NOTA EN EL CANAL A
                DB     00               ;VACIO
REG_NOTA_B:     DB     00               ;DB REGISTRO DE LA NOTA EN EL CANAL B
                DB     00               ;VACIO
REG_NOTA_C:     DB     00               ;DB REGISTRO DE LA NOTA EN EL CANAL C
                DB     00               ;VACIO

;CANAL DE EFECTOS - ENMASCARA OTRO CANAL

puntero_p       DW     00               ;DW PUNTERO DEL CANAL EFECTOS
canal_p         DW     BUFFERS_CANALES+$90 ;DW DIRECION DE INICIO DE LOS EFECTOS
puntero_p_decp  DW     00               ;DW PUNTERO DE INICIO DEL DECODER CANAL P
puntero_decp    DW     00               ;DW PUNTERO DECODER CANAL P

psg_reg:        defs   14               ;DB (11) BUFFER DE REGISTROS DEL PSG
psg_reg_sec:    defs   14               ;DB (11) BUFFER SECUNDARIO DE REGISTROS DEL PSG



;ENVOLVENTE_A    EQU     $D033           ;DB
;ENVOLVENTE_B    EQU     $D034           ;DB
;ENVOLVENTE_C    EQU     $D035           ;DB


;EFECTOS DE SONIDO

N_SONIDO:       DB      0               ;DB : NUMERO DE SONIDO
PUNTERO_SONIDO: DW      0               ;DW : PUNTERO DEL SONIDO QUE SE REPRODUCE

;EFECTOS

N_EFECTO:       DB      0               ;DB : NUMERO DE SONIDO
PUNTERO_EFECTO: DW      0               ;DW : PUNTERO DEL SONIDO QUE SE REPRODUCE
CANAL_EFECTOS:  DB      1               ; CANAL DE SFX
ENVOLVENTE:     DB      0               ;DB : FORMA DE LA ENVOLVENTE
                                        ;BIT 0    : FRECUENCIA CANAL ON/OFF
                                        ;BIT 1-2  : RATIO 
                                        ;BIT 3-3  : FORMA

;BUFFER_DEC:     DB      $00     

;************************* mucha atencion!!!!
; aqui se decodifica la cancion hay que dejar suficiente espacio libre.
;*************************
                
;; INCLUIR LOS DATOS DE LA MUSICA (PATTERNS/EFFECTS)

                INCLUDE "mus/list.asm"

;; INCLUIR LOS EFECTOS DE SONIDO:

;                INCLUDE "efectos.asm"

; (0) Select
EFECTO0:		DB 	$51,$1A
				DB	$5A,$0F
				DB	$3C,$0F
				DB	$1E,$0E
				DB	$2D,$0E
				DB	$5A,$0B
				DB	$3C,$0B
				DB	$1E,$0A
				DB	$2D,$0A
				DB	$B4,$01
				DB	$FF
				
; (1) Start
EFECTO1:		DB 	$25,$1C
				DB 	$3A,$0F
				DB	$2D,$0F
				DB	$E2,$0F
				DB	$BC,$0F
				DB	$96,$0D
				DB	$4B,$0D
				DB	$32,$0D
				DB 	$3A,$0D
				DB	$2D,$0D
				DB	$E2,$0D
				DB	$BC,$0D
				DB	$96,$0D
				DB	$4B,$0D
				DB	$32,$0D
				DB 	$3A,$0D
				DB	$2D,$0C
				DB	$E2,$0C
				DB	$BC,$0C
				DB	$96,$0B
				DB	$4B,$0B
				DB	$32,$0B
				DB 	$3A,$0B
				DB	$2D,$0B
				DB	$E2,$0B
				DB	$BC,$0B
				DB	$96,$0B
				DB	$4B,$0A
				DB	$32,$0A
				DB 	$3A,$0A
				DB	$2D,$09
				DB	$E2,$09
				DB	$BC,$08
				DB	$96,$08
				DB	$4B,$08
				DB	$32,$07
				DB 	$3A,$07
				DB	$2D,$06
				DB	$E2,$06
				DB	$BC,$06
				DB	$96,$05
				DB	$4B,$05
				DB	$32,$05
				DB 	$3A,$04
				DB	$2D,$04
				DB	$E2,$03
				DB	$BC,$03
				DB	$96,$03
				DB	$4B,$03
				DB	$32,$02
				DB 	$3A,$01
				DB	$2D,$01
				DB	$E2,$01
				DB	$BC,$01
				DB	$FF
				
; (2) Sartar
EFECTO2:		DB	$E8,$1B
				DB	$B4,$0F
				DB	$A0,$0E
				DB	$90,$0D
				DB	$87,$0D
				DB	$78,$0C	
				DB	$6C,$0B	
				DB	$60,$0A	
				DB	$5A,$09
				DB	$FF	
				
; (3) Disparo 1
EFECTO3:		DB	$1F,$0B
				DB	$5A,$0F
				DB	$3C,$0F
				DB	$1E,$0A
				DB	$2D,$0A
				DB	$5A,$05
				DB	$3C,$05
				DB	$1E,$04
				DB	$2D,$02
				DB	$B4,$01
				DB	$FF
	
; (4) Disparo 2
EFECTO4:		DB	$1F,$0B
				DB	$AF,$0F
				DB	$8A,$0F
				DB	$71,$0F
				DB	$64,$0F
				DB	$3E,$0C
				DB	$25,$0C
				DB	$25,$0C
				DB	$25,$0C
				DB	$25,$0A
				DB	$4B,$0A
				DB	$4B,$0A
				DB	$4B,$0A
				DB	$3E,$08
				DB	$3E,$08
				DB	$3E,$08
				DB	$71,$08
				DB	$3E,$07
				DB	$25,$05
				DB	$25,$02
				DB	$FF
				
; (5) Vida
EFECTO5:		DB	$1A,$0E
				DB	$B4,$0E
				DB	$B4,$0E
				DB	$B4,$0E
				DB	$B4,$0E
				DB	$B4,$0E
				DB	$B4,$0E
				DB	$B4,$0E
				DB	$B4,$0E	
				DB	$A0,$0E
				DB	$A0,$0E
				DB	$A0,$0E
				DB	$A0,$0E
				DB	$A0,$0E
				DB	$A0,$0E
				DB	$A0,$0E
				DB	$87,$0E
				DB	$87,$0E
				DB	$87,$0E
				DB	$87,$0E
				DB	$87,$0E
				DB	$87,$0E
				DB	$87,$0E
				DB	$87,$0E
				DB	$87,$0E		
				DB	$78,$0E
				DB	$78,$0E
				DB	$78,$0D
				DB	$78,$0D
				DB	$78,$0D
				DB	$78,$0D
				DB	$78,$0D
				DB	$78,$0D
				DB	$78,$0C
				DB	$78,$09
				DB	$78,$06
				DB	$78,$05	
				DB	$FF
				
                                
TABLA_EFECTOS:  DW      EFECTO0, EFECTO1, EFECTO2, EFECTO3, EFECTO4, EFECTO5

;; NADA A PARTIR DE AQUI!!!
BUFFERS_CANALES:
                DB              0