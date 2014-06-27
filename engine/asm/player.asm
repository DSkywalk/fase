
        output  build/player.bin
        org     $c000
        jp      INICIO
        jp      CARGA_CANCION
        jp      PLAYER_OFF

; SPECTRUM PSG proPLAYER V 0.2 - WYZ 07.09.2011
; VER AL FINAL PARA DATOS PROPIOS:

; ISR LLAMA A:
INICIO:     CALL    ROUT
            LD      HL,PSG_REG
            LD      DE,PSG_REG_SEC
            LD      BC,14
            LDIR                
            CALL    REPRODUCE_SONIDO
            CALL    REPRODUCE_EFECTO
            CALL    PLAY    ; 1 sola vez
            RET
    
;VUELCA BUFFER DE SONIDO AL PSG DEL SPECTRUM

ROUT:       XOR     A
ROUT_A0:    LD      DE,$FFBF
            LD      BC,$FFFD
            LD      HL,PSG_REG_SEC
LOUT:       OUT     [C],A
            LD      B,E
            OUTI 
            LD      B,D
            INC     A
            CP      13
            JR      NZ,LOUT
            OUT     [C],A
            LD      A,[HL]
            AND     A
            RET     Z
            LD      B,E
            OUTI
            XOR     A
            LD      [PSG_REG_SEC+13],A
            LD      [PSG_REG+13],A
            RET

;INICIA EL SONIDO Nº [A]

INICIA_SONIDO:  
            LD      HL,TABLA_SONIDOS
            CALL    EXT_WORD
            LD      [PUNTERO_SONIDO],HL
            LD      HL,INTERR
            SET     2,[HL]
            RET

;PLAYER OFF

PLAYER_OFF: XOR     A           ;***** IMPORTANTE SI NO HAY MUSICA ****
            LD      [INTERR],A
    
            LD      HL,PSG_REG
            LD      DE,PSG_REG+1
            LD      BC,14
            LD      [HL],A
            LDIR
    
            LD      HL,PSG_REG_SEC
            LD      DE,PSG_REG_SEC+1
            LD      BC,14
            LD      [HL],A
            LDIR
    
        
            LD      A,10111000B     ; **** POR SI ACASO ****
            LD      [PSG_REG+7],A
            CALL    ROUT
            RET

;CARGA UNA CANCION
;IN:[A]=Nº DE CANCION

CARGA_CANCION:  
            LD      HL,INTERR           ;CARGA CANCION
            SET     1,[HL]              ;REPRODUCE CANCION
            LD      HL,SONG
            LD      [HL],A              ;Nº [A]

;DECODIFICAR
;IN-> INTERR 0 ON
;     SONG

;CARGA CANCION SI/NO

DECODE_SONG:
            LD      A,[SONG]

;LEE CABECERA DE LA CANCION
;BYTE 0=TEMPO

            LD      HL,TABLA_SONG
            CALL    EXT_WORD
            LD      A,[HL]
            LD      [TEMPO],A
            XOR     A
            LD      [TTEMPO],A
                
;HEADER BYTE 1
;[-|-|-|-|-|-|-|LOOP]

            INC     HL          ;LOOP 1=ON/0=OFF?
            LD      A,[HL]
            BIT     0,A
            JR      Z,NPTJP0
            PUSH    HL
            LD      HL,INTERR
            SET     4,[HL]
            POP     HL
            
NPTJP0:     INC     HL              ;2 BYTES RESERVADOS
            INC     HL
            INC     HL

;BUSCA Y GUARDA INICIO DE LOS CANALES EN EL MODULO MUS
        
            LD      [PUNTERO_P_DECA],HL
            LD      E,$3F           ;CODIGO INTRUMENTO 0
            LD      B,$FF           ;EL MODULO DEBE TENER UNA LONGITUD MENOR DE $FF00 ... o_O!
            
BGICMODBC1: XOR     A               ;BUSCA EL BYTE 0
            CPIR
            DEC     HL
            DEC     HL
            LD      A,E             ;ES EL INSTRUMENTO 0??
            CP      [HL]
            INC     HL
            INC     HL
            JR      Z,BGICMODBC1
    
            LD      [PUNTERO_P_DECB],HL

BGICMODBC2: XOR     A               ;BUSCA EL BYTE 0
            CPIR
            DEC     HL
            DEC     HL
            LD      A,E
            CP      [HL]            ;ES EL INSTRUMENTO 0??
            INC     HL
            INC     HL
            JR      Z,BGICMODBC2
    
            LD      [PUNTERO_P_DECC],HL
        
BGICMODBC3: XOR     A               ;BUSCA EL BYTE 0
            CPIR
            DEC     HL
            DEC     HL
            LD      A,E
            CP      [HL]                ;ES EL INSTRUMENTO 0??
            INC     HL
            INC     HL
            JR      Z,BGICMODBC3
            LD      [PUNTERO_P_DECP],HL
        
                
;LEE DATOS DE LAS NOTAS
;[|][|||||] LONGITUD\NOTA

INIT_DECODER:   
            LD      DE,[CANAL_A]
            LD      [PUNTERO_A],DE
            LD      HL,[PUNTERO_P_DECA]
            CALL    DECODE_CANAL    ;CANAL A
            LD      [PUNTERO_DECA],HL
            
            LD      DE,[CANAL_B]
            LD      [PUNTERO_B],DE
            LD      HL,[PUNTERO_P_DECB]
            CALL    DECODE_CANAL    ;CANAL B
            LD      [PUNTERO_DECB],HL
            
            LD      DE,[CANAL_C]
            LD      [PUNTERO_C],DE
            LD      HL,[PUNTERO_P_DECC]
            CALL    DECODE_CANAL    ;CANAL C
            LD      [PUNTERO_DECC],HL
            
            LD      DE,[CANAL_P]
            LD      [PUNTERO_P],DE
            LD      HL,[PUNTERO_P_DECP]
            CALL    DECODE_CANAL    ;CANAL P
            LD      [PUNTERO_DECP],HL
           
            RET


;DECODIFICA NOTAS DE UN CANAL
;IN [DE]=DIRECCION DESTINO
;NOTA=0 FIN CANAL
;NOTA=1 SILENCIO
;NOTA=2 PUNTILLO
;NOTA=3 COMANDO I

DECODE_CANAL:   
            LD      A,[HL]
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
            LD      [DE],A
            INC     HL
            INC     DE
            LD      A,[HL]                  ;Nº DE INSTRUMENTO
            LD      [DE],A
            INC     DE
            INC     HL
            JR      DECODE_CANAL
            
NO_INSTRUMENTO: 
            BIT     2,B
            JR      Z,NO_ENVOLVENTE
            LD      A,11000100B             ;CODIGO ENVOLVENTE
            LD      [DE],A
            INC     DE
            INC HL
            LD  A,[HL]
            LD  [DE],A
            INC DE
            INC HL
            JR      DECODE_CANAL
     
NO_ENVOLVENTE:  
            BIT     1,B
            JR      Z,NO_MODIFICA           
            LD      A,11000010B             ;CODIGO EFECTO
            LD      [DE],A                  
            INC     HL                      
            INC     DE                      
            LD      A,[HL]                  
            CALL    GETLEN   
                
NO_MODIFICA:    
            LD      [DE],A
            INC     DE
            XOR     A
            DJNZ    NO_MODIFICA
            SET     7,A
            SET     0,A
            LD      [DE],A
            INC     DE
            INC     HL
            RET                 ;** JR      DECODE_CANAL
                
FIN_DEC_CANAL:  
            SET     7,A
            LD      [DE],A
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
                
;PLAY __________________________________________________

PLAY:       LD      HL,INTERR               ;PLAY BIT 1 ON?
            BIT     1,[HL]
            RET     Z
;TEMPO          
            LD      HL,TTEMPO               ;CONTADOR TEMPO
            INC     [HL]
            LD      A,[TEMPO]
            CP      [HL]
            JR      NZ,PAUTAS
            LD      [HL],0
                
;INTERPRETA      
            LD      IY,PSG_REG
            LD      IX,PUNTERO_A
            LD      BC,PSG_REG+8
            CALL    LOCALIZA_NOTA
            LD      IY,PSG_REG+2
            LD      IX,PUNTERO_B
            LD      BC,PSG_REG+9
            CALL    LOCALIZA_NOTA
            LD      IY,PSG_REG+4
            LD      IX,PUNTERO_C
            LD      BC,PSG_REG+10
            CALL    LOCALIZA_NOTA
            LD      IX,PUNTERO_P            ;EL CANAL DE EFECTOS ENMASCARA OTRO CANAL
            CALL    LOCALIZA_EFECTO              

;PAUTAS               
PAUTAS:     LD      IY,PSG_REG+0
            LD      IX,PUNTERO_P_A
            LD      HL,PSG_REG+8
            CALL    PAUTA                   ;PAUTA CANAL A
            LD      IY,PSG_REG+2
            LD      IX,PUNTERO_P_B
            LD      HL,PSG_REG+9
            CALL    PAUTA                   ;PAUTA CANAL B
            LD      IY,PSG_REG+4
            LD      IX,PUNTERO_P_C
            LD      HL,PSG_REG+10
            CALL    PAUTA                   ;PAUTA CANAL C                

            RET

;REPRODUCE EFECTOS DE SONIDO 

REPRODUCE_SONIDO:

            LD      HL,INTERR   
            BIT     2,[HL]                  ;ESTA ACTIVADO EL EFECTO?
            RET     Z
            LD      HL,[PUNTERO_SONIDO]
            LD      A,[HL]
            CP      $FF
            JR      Z,FIN_SONIDO
            LD      [PSG_REG_SEC+2],A
            INC     HL
            LD      A,[HL]
            RRCA
            RRCA
            RRCA
            RRCA
            AND     00001111B
            LD      [PSG_REG_SEC+3],A
            LD      A,[HL]
            AND     00001111B
            LD      [PSG_REG_SEC+9],A
            INC     HL
            LD      A,[HL]
            AND     A
            JR      Z,NO_RUIDO
            LD      [PSG_REG_SEC+6],A
            LD      A,10101000B
            JR      SI_RUIDO
NO_RUIDO:   LD      A,10111000B
SI_RUIDO:   LD      [PSG_REG_SEC+7],A
       
            INC     HL
            LD      [PUNTERO_SONIDO],HL
            RET
            
FIN_SONIDO: LD      HL,INTERR
            RES     2,[HL]

FIN_NOPLAYER:
            LD      A,10111000B
            LD      [PSG_REG+7],A
            RET         
                
;LOCALIZA NOTA CANAL A
;IN [PUNTERO_A]

LOCALIZA_NOTA:  
            LD      L,[IX+PUNTERO_A-PUNTERO_A]  ;HL=[PUNTERO_A_C_B]
            LD      H,[IX+PUNTERO_A-PUNTERO_A+1]
            LD      A,[HL]
            AND     11000000B               ;COMANDO?
            CP      11000000B
            JR      NZ,LNJP0

;BIT[0]=INSTRUMENTO
                
COMANDOS:   LD      A,[HL]
            BIT     0,A                     ;INSTRUMENTO
            JR      Z,COM_EFECTO

            INC     HL
            LD      A,[HL]                  ;Nº DE PAUTA
            INC     HL
            LD      [IX+PUNTERO_A-PUNTERO_A],L
            LD      [IX+PUNTERO_A-PUNTERO_A+1],H
            LD      HL,TABLA_PAUTAS
            CALL    EXT_WORD
            LD      [IX+PUNTERO_P_A0-PUNTERO_A],L
            LD      [IX+PUNTERO_P_A0-PUNTERO_A+1],H
            LD      [IX+PUNTERO_P_A-PUNTERO_A],L
            LD      [IX+PUNTERO_P_A-PUNTERO_A+1],H
            LD      L,C
            LD      H,B
            RES     4,[HL]                  ;APAGA EFECTO ENVOLVENTE
            XOR     A
            LD      [PSG_REG_SEC+13],A
            LD      [PSG_REG+13],A
            JR      LOCALIZA_NOTA

COM_EFECTO: BIT     1,A                     ;EFECTO DE SONIDO
            JR      Z,COM_ENVOLVENTE

            INC     HL
            LD      A,[HL]
            INC     HL
            LD      [IX+PUNTERO_A-PUNTERO_A],L
            LD      [IX+PUNTERO_A-PUNTERO_A+1],H
            CALL    INICIA_SONIDO
            RET

COM_ENVOLVENTE: 

            BIT     2,A
            RET     Z                       ;IGNORA - ERROR            
       
            INC     HL
            LD      A,[HL]                  ;CARGA CODIGO DE ENVOLVENTE
            LD      [ENVOLVENTE],A
            INC     HL
            LD      [IX+PUNTERO_A-PUNTERO_A],L
            LD      [IX+PUNTERO_A-PUNTERO_A+1],H
            LD      L,C
            LD      H,B
            LD      [HL],00010000B          ;ENCIENDE EFECTO ENVOLVENTE
            JR      LOCALIZA_NOTA
              
LNJP0:      LD      A,[HL]
            INC     HL
            BIT     7,A
            JR      Z,NO_FIN_CANAL_A    ;
            BIT     0,A
            JR      Z,FIN_CANAL_A

FIN_NOTA_A: LD      E,[IX+CANAL_A-PUNTERO_A]
            LD      D,[IX+CANAL_A-PUNTERO_A+1]      ;PUNTERO BUFFER AL INICIO
            LD      [IX+PUNTERO_A-PUNTERO_A],E
            LD      [IX+PUNTERO_A-PUNTERO_A+1],D
            LD      L,[IX+PUNTERO_DECA-PUNTERO_A]   ;CARGA PUNTERO DECODER
            LD      H,[IX+PUNTERO_DECA-PUNTERO_A+1]
            PUSH    BC
            CALL    DECODE_CANAL                    ;DECODIFICA CANAL
            POP     BC
            LD      [IX+PUNTERO_DECA-PUNTERO_A],L   ;GUARDA PUNTERO DECODER
            LD      [IX+PUNTERO_DECA-PUNTERO_A+1],H
            JP      LOCALIZA_NOTA
            
FIN_CANAL_A:    
            LD      HL,INTERR           ;LOOP?
            BIT     4,[HL]              
            JR      NZ,FCA_CONT
            CALL    PLAYER_OFF
            RET

FCA_CONT:   LD      L,[IX+PUNTERO_P_DECA-PUNTERO_A] ;CARGA PUNTERO INICIAL DECODER
            LD      H,[IX+PUNTERO_P_DECA-PUNTERO_A+1]
            LD      [IX+PUNTERO_DECA-PUNTERO_A],L
            LD      [IX+PUNTERO_DECA-PUNTERO_A+1],H
            JR      FIN_NOTA_A
                
NO_FIN_CANAL_A: 
            LD      [IX+PUNTERO_A-PUNTERO_A],L      ;[PUNTERO_A_B_C]=HL GUARDA PUNTERO
            LD      [IX+PUNTERO_A-PUNTERO_A+1],H
            AND     A                               ;NO REPRODUCE NOTA SI NOTA=0
            JR      Z,FIN_RUTINA
            BIT     6,A                             ;SILENCIO?
            JR      Z,NO_SILENCIO_A
            LD      A,[BC]
            AND     00010000B
            JR      NZ,SILENCIO_ENVOLVENTE
            XOR     A
            LD      [BC],A                          ;RESET VOLUMEN DEL CORRESPODIENTE CHIP
            LD      [IY+0],A
            LD      [IY+1],A
            RET
        
SILENCIO_ENVOLVENTE:
            LD  A,$FF
            LD  [PSG_REG+11],A
            LD  [PSG_REG+12],A               
            XOR A
            LD  [PSG_REG+13],A                               
            LD  [IY+0],A
            LD  [IY+1],A
            RET

NO_SILENCIO_A:  
            LD  [IX+REG_NOTA_A-PUNTERO_A],A ;REGISTRO DE LA NOTA DEL CANAL         
            CALL    NOTA                    ;REPRODUCE NOTA
            LD      L,[IX+PUNTERO_P_A0-PUNTERO_A]   ;HL=[PUNTERO_P_A0] RESETEA PAUTA 
            LD      H,[IX+PUNTERO_P_A0-PUNTERO_A+1]
            LD      [IX+PUNTERO_P_A-PUNTERO_A],L    ;[PUNTERO_P_A]=HL
            LD      [IX+PUNTERO_P_A-PUNTERO_A+1],H
FIN_RUTINA:     
            RET

;LOCALIZA EFECTO
;IN HL=[PUNTERO_P]

LOCALIZA_EFECTO:
            LD      L,[IX+0]                ;HL=[PUNTERO_P]
            LD      H,[IX+1]
            LD      A,[HL]
            CP      11000010B
            JR      NZ,LEJP0

            INC     HL
            LD      A,[HL]
            INC     HL
            LD      [IX+00],L
            LD      [IX+01],H
            CALL    INICIA_SONIDO
            RET
              
LEJP0:      INC     HL
            BIT     7,A
            JR      Z,NO_FIN_CANAL_P    ;
            BIT     0,A
            JR      Z,FIN_CANAL_P
            
FIN_NOTA_P: 
            LD      DE,[CANAL_P]
            LD      [IX+0],E
            LD      [IX+1],D
            LD      HL,[PUNTERO_DECP]       ;CARGA PUNTERO DECODER
            PUSH    BC
            CALL    DECODE_CANAL            ;DECODIFICA CANAL
            POP     BC
            LD      [PUNTERO_DECP],HL       ;GUARDA PUNTERO DECODER
            JP      LOCALIZA_EFECTO
                
FIN_CANAL_P:    
            LD      HL,[PUNTERO_P_DECP]     ;CARGA PUNTERO INICIAL DECODER
            LD      [PUNTERO_DECP],HL
            JR      FIN_NOTA_P
                
NO_FIN_CANAL_P: 
            LD      [IX+0],L                ;[PUNTERO_A_B_C]=HL GUARDA PUNTERO
            LD      [IX+1],H
            RET

; PAUTA DE LOS 3 CANALES
; IN:[IX]:PUNTERO DE LA PAUTA
;    [HL]:REGISTRO DE VOLUMEN
;    [IY]:REGISTROS DE FRECUENCIA

; FORMATO PAUTA 
;       7    6     5     4   3-0                        3-0  
; BYTE 1 [LOOP|OCT-1|OCT+1|ORNMT|VOL] - BYTE 2 [ | | | |PITCH/NOTA]

PAUTA:      BIT     4,[HL]        ;SI LA ENVOLVENTE ESTA ACTIVADA NO ACTUA PAUTA
            RET     NZ

            LD      A,[IY+0]
            LD      B,[IY+1]
            OR      B
            RET     Z

            PUSH    HL
           
PCAJP4:     LD      L,[IX+0]
            LD      H,[IX+1]         
            LD      A,[HL]
        
            BIT     7,A             ;LOOP / EL RESTO DE BITS NO AFECTAN
            JR      Z,PCAJP0
            AND     00011111B       ;MÁXIMO LOOP PAUTA [0,32]X2!!!-> PARA ORNAMENTOS
            RLCA                    ;X2
            LD      D,0
            LD      E,A
            SBC     HL,DE
            LD      A,[HL]

PCAJP0:     BIT     6,A             ;OCTAVA -1
            JR      Z,PCAJP1
            LD      E,[IY+0]
            LD      D,[IY+1]
    
            AND     A
            RRC     D
            RR      E
            LD      [IY+0],E
            LD      [IY+1],D
            JR      PCAJP2
        
PCAJP1:     BIT     5,A             ;OCTAVA +1
            JR      Z,PCAJP2
            LD      E,[IY+0]
            LD      D,[IY+1]

            AND     A
            RLC     E
            RL      D
            LD      [IY+0],E
            LD      [IY+1],D        

PCAJP2:     LD      A,[HL]
            BIT     4,A
            JR      NZ,PCAJP6   ;ORNAMENTOS SELECCIONADOS

            INC     HL      ;______________________ FUNCION PITCH DE FRECUENCIA__________________       
            PUSH    HL
            LD      E,A
            LD      A,[HL]      ;PITCH DE FRECUENCIA
            LD      L,A
            AND     A
            LD      A,E
            JR      Z,ORNMJP1

            LD      A,[IY+0]    ;SI LA FRECUENCIA ES 0 NO HAY PITCH
            ADD     A,[IY+1]
            AND     A
            LD      A,E
            JR      Z,ORNMJP1

            BIT     7,L
            JR      Z,ORNNEG
            LD      H,$FF
            JR      PCAJP3
            
ORNNEG:     LD      H,0
        
PCAJP3:     LD      E,[IY+0]
            LD      D,[IY+1]
            ADC     HL,DE
            LD      [IY+0],L
            LD      [IY+1],H
            JR      ORNMJP1

PCAJP6:     INC     HL      ;______________________ FUNCION ORNAMENTOS__________________    
            PUSH    HL
            PUSH    AF
            LD      A,[IX+24]   ;RECUPERA REGISTRO DE NOTA EN EL CANAL
            LD      E,[HL]      ;
                ADC     A,E             ;+- NOTA 
            CALL    TABLA_NOTAS
            POP     AF  
        
ORNMJP1:    POP     HL
        
            INC     HL
            LD      [IX+0],L
            LD      [IX+1],H
PCAJP5:     POP     HL
            AND     00001111B   ;VOLUMEN FINAL
            LD      [HL],A
            RET

;NOTA : REPRODUCE UNA NOTA
;IN [A]=CODIGO DE LA NOTA
;   [IY]=REGISTROS DE FRECUENCIA


NOTA:       LD      L,C
            LD      H,B
            BIT     4,[HL]
            LD      B,A
            JR      NZ,ENVOLVENTES
            LD      A,B
TABLA_NOTAS:    
            LD      HL,DATOS_NOTAS      ;BUSCA FRECUENCIA
            CALL    EXT_WORD
            LD      [IY+0],L
            LD      [IY+1],H
            RET

;IN [A]=CODIGO DE LA ENVOLVENTE
;   [IY]=REGISTRO DE FRECUENCIA

ENVOLVENTES:
            LD      HL,DATOS_NOTAS      ;BUSCA FRECUENCIA
            CALL    EXT_WORD
        
            LD      A,[ENVOLVENTE]      ;FRECUENCIA DEL CANAL ON/OFF
LOCALIZA_ENV:   
            RRA
            JR      FRECUENCIA_OFF
            LD      [IY+0],L
            LD      [IY+1],H
            JR      CONT_ENV
                
FRECUENCIA_OFF:     
            LD      HL,$0000
            LD      [IY+0],L
            LD      [IY+1],H

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
            CALL    EXT_WORD
                
            LD      A,L
            LD      [PSG_REG+11],A
            LD      A,H
            AND     00000011B
            LD      [PSG_REG+12],A
            POP     AF                  ;SELECCION FORMA DE ENVOLVENTE
                
            RRA
            AND     00000110B           ;$08,$0A,$0C,$0E
            ADD     A,8                
            LD      [PSG_REG+13],A
       
            RET

;EXTRAE UN WORD DE UNA TABLA
;IN:[HL]=DIRECCION TABLA
;   [A]= POSICION
;OUT[HL]=WORD

EXT_WORD:       
            LD      D,0
            RLCA
            LD      E,A
            ADD     HL,DE
            LD      E,[HL]
            INC     HL
            LD      D,[HL]
            EX      DE,HL
            RET

;;;;;;;; EFECTOS DE SONIDO ;;;;;;;;;;;
            
INICIA_EFECTO:  
            LD      A,B
            LD      HL,TABLA_EFECTOS
            CALL    EXT_WORD
            LD      [PUNTERO_EFECTO],HL
            LD      HL,INTERR
            SET     3,[HL]
            RET       

REPRODUCE_EFECTO:
            LD      HL,INTERR   
            BIT     3,[HL]             ;ESTA ACTIVADO EL EFECTO?
            RET     Z
            LD      HL,[PUNTERO_EFECTO]
            LD      A,[HL]
            CP      $FF
            JP      Z,FIN_EFECTO
            LD      B,A                 ;FRECUENCIA FINO
            INC     HL
            LD      A,[HL]
            RRCA
            RRCA
            RRCA
            RRCA
            AND     00001111B
            LD      C,A                 ;FRECUENCIA GRAVE
            LD      A,[HL]
            DEC     A                   ;DEC A PARA BAJR VOLUMEN!!
            AND     00001111B

            LD   D,A                    ;VOLUMEN
            INC     HL                  ;INCREMENTA Y GUARDA EL PUNTERO
            LD      [PUNTERO_EFECTO],HL     
            LD      IX,PSG_REG_SEC
            LD      A,[CANAL_EFECTOS]   ;SELECCION DE CANAL
            CP      1
            JR      Z,RS_CANALA
            CP      2
            JR      Z,RS_CANALB
  
RS_CANALC:  LD      [IX+4],B
            LD      [IX+5],C
            LD      [IX+10],D
            RET      
  
RS_CANALA:  LD      [IX+0],B
            LD      [IX+1],C
            LD      [IX+8],D
            RET
           
RS_CANALB:  LD      [IX+2],B
            LD      [IX+3],C
            LD      [IX+9],D
            RET
           
FIN_EFECTO: LD      HL,INTERR
            RES     3,[HL]              ;DESACTIVA EFECTO
            RET         

; VARIABLES__________________________


INTERR:         DB     00               ;INTERRUPTORES 1=ON 0=OFF
                                        ;BIT 0=CARGA CANCION ON/OFF
                                        ;BIT 1=PLAYER ON/OFF
                                        ;BIT 2=SONIDOS ON/OFF
                                        ;BIT 3=EFECTOS ON/OFF

;MUSICA **** EL ORDEN DE LAS VARIABLES ES FIJO ******



SONG:           DB     00               ;DBNº DE CANCION
TEMPO:          DB     00               ;DB TEMPO
TTEMPO:         DB     00               ;DB CONTADOR TEMPO
PUNTERO_A:      DW     00               ;DW PUNTERO DEL CANAL A
PUNTERO_B:      DW     00               ;DW PUNTERO DEL CANAL B
PUNTERO_C:      DW     00               ;DW PUNTERO DEL CANAL C

CANAL_A:        DW     BUFFERS_CANALES      ;DW DIRECION DE INICIO DE LA MUSICA A
CANAL_B:        DW     BUFFERS_CANALES+$30  ;DW DIRECION DE INICIO DE LA MUSICA B
CANAL_C:        DW     BUFFERS_CANALES+$60  ;DW DIRECION DE INICIO DE LA MUSICA C

PUNTERO_P_A:    DW     00               ;DW PUNTERO PAUTA CANAL A
PUNTERO_P_B:    DW     00               ;DW PUNTERO PAUTA CANAL B
PUNTERO_P_C:    DW     00               ;DW PUNTERO PAUTA CANAL C

PUNTERO_P_A0:   DW     00               ;DW INI PUNTERO PAUTA CANAL A
PUNTERO_P_B0:   DW     00               ;DW INI PUNTERO PAUTA CANAL B
PUNTERO_P_C0:   DW     00               ;DW INI PUNTERO PAUTA CANAL C


PUNTERO_P_DECA: DW     00               ;DW PUNTERO DE INICIO DEL DECODER CANAL A
PUNTERO_P_DECB: DW     00               ;DW PUNTERO DE INICIO DEL DECODER CANAL B
PUNTERO_P_DECC: DW     00               ;DW PUNTERO DE INICIO DEL DECODER CANAL C

PUNTERO_DECA:   DW     00               ;DW PUNTERO DECODER CANAL A
PUNTERO_DECB:   DW     00               ;DW PUNTERO DECODER CANAL B
PUNTERO_DECC:   DW     00               ;DW PUNTERO DECODER CANAL C       

REG_NOTA_A:     DB     00               ;DB REGISTRO DE LA NOTA EN EL CANAL A
                DB     00               ;VACIO
REG_NOTA_B:     DB     00               ;DB REGISTRO DE LA NOTA EN EL CANAL B
                DB     00               ;VACIO
REG_NOTA_C:     DB     00               ;DB REGISTRO DE LA NOTA EN EL CANAL C
                DB     00               ;VACIO

;CANAL DE EFECTOS - ENMASCARA OTRO CANAL

PUNTERO_P:      DW     00               ;DW PUNTERO DEL CANAL EFECTOS
CANAL_P:        DW     BUFFERS_CANALES+$90 ;DW DIRECION DE INICIO DE LOS EFECTOS
PUNTERO_P_DECP: DW     00               ;DW PUNTERO DE INICIO DEL DECODER CANAL P
PUNTERO_DECP:   DW     00               ;DW PUNTERO DECODER CANAL P

PSG_REG:        DB     00,00,00,00,00,00,00,10111000B,00,00,00,00,00,00,00    ;DB [11] BUFFER DE REGISTROS DEL PSG
PSG_REG_SEC:    DB     00,00,00,00,00,00,00,10111000B,00,00,00,00,00,00,00    ;DB [11] BUFFER SECUNDARIO DE REGISTROS DEL PSG



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

; [0] Select
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
				
; [1] Start
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
				
; [2] Sartar
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
				
; [3] Disparo 1
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
	
; [4] Disparo 2
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
				
; [5] Vida
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
				
                                
TABLA_SONG:     DW      SONG_0 ;SONG_1
TABLA_EFECTOS:  DW      EFECTO0, EFECTO1, EFECTO2, EFECTO3, EFECTO4, EFECTO5

;; NADA A PARTIR DE AQUI!!!
BUFFERS_CANALES:
                DB              0