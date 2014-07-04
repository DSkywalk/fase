tabla_song  dw  song_0, song_1

        include mus/song.mus.asm

song_0  incbin  mus/song0.mus
song_1  incbin  mus/song1.mus

;; INCLUIR LOS EFECTOS DE SONIDO:

tabla_efectos dw  efecto0, efecto1, efecto2, efecto3, efecto4, efecto5

; (0) select
efecto0 db  $51, $1a
        db  $5a, $0f
        db  $3c, $0f
        db  $1e, $0e
        db  $2d, $0e
        db  $5a, $0b
        db  $3c, $0b
        db  $1e, $0a
        db  $2d, $0a
        db  $b4, $01
        db  $ff

; (1) start
efecto1 db  $25, $1c
        db  $3a, $0f
        db  $2d, $0f
        db  $e2, $0f
        db  $bc, $0f
        db  $96, $0d
        db  $4b, $0d
        db  $32, $0d
        db  $3a, $0d
        db  $2d, $0d
        db  $e2, $0d
        db  $bc, $0d
        db  $96, $0d
        db  $4b, $0d
        db  $32, $0d
        db  $3a, $0d
        db  $2d, $0c
        db  $e2, $0c
        db  $bc, $0c
        db  $96, $0b
        db  $4b, $0b
        db  $32, $0b
        db  $3a, $0b
        db  $2d, $0b
        db  $e2, $0b
        db  $bc, $0b
        db  $96, $0b
        db  $4b, $0a
        db  $32, $0a
        db  $3a, $0a
        db  $2d, $09
        db  $e2, $09
        db  $bc, $08
        db  $96, $08
        db  $4b, $08
        db  $32, $07
        db  $3a, $07
        db  $2d, $06
        db  $e2, $06
        db  $bc, $06
        db  $96, $05
        db  $4b, $05
        db  $32, $05
        db  $3a, $04
        db  $2d, $04
        db  $e2, $03
        db  $bc, $03
        db  $96, $03
        db  $4b, $03
        db  $32, $02
        db  $3a, $01
        db  $2d, $01
        db  $e2, $01
        db  $bc, $01
        db  $ff

; (2) sartar
efecto2 db  $e8, $1b
        db  $b4, $0f
        db  $a0, $0e
        db  $90, $0d
        db  $87, $0d
        db  $78, $0c 
        db  $6c, $0b 
        db  $60, $0a 
        db  $5a, $09
        db  $ff 

; (3) disparo 1
efecto3 db  $1f, $0b
        db  $5a, $0f
        db  $3c, $0f
        db  $1e, $0a
        db  $2d, $0a
        db  $5a, $05
        db  $3c, $05
        db  $1e, $04
        db  $2d, $02
        db  $b4, $01
        db  $ff

; (4) disparo 2
efecto4 db  $1f, $0b
        db  $af, $0f
        db  $8a, $0f
        db  $71, $0f
        db  $64, $0f
        db  $3e, $0c
        db  $25, $0c
        db  $25, $0c
        db  $25, $0c
        db  $25, $0a
        db  $4b, $0a
        db  $4b, $0a
        db  $4b, $0a
        db  $3e, $08
        db  $3e, $08
        db  $3e, $08
        db  $71, $08
        db  $3e, $07
        db  $25, $05
        db  $25, $02
        db  $ff

; (5) vida
efecto5 db  $1a, $0e
        db  $b4, $0e
        db  $b4, $0e
        db  $b4, $0e
        db  $b4, $0e
        db  $b4, $0e
        db  $b4, $0e
        db  $b4, $0e
        db  $b4, $0e 
        db  $a0, $0e
        db  $a0, $0e
        db  $a0, $0e
        db  $a0, $0e
        db  $a0, $0e
        db  $a0, $0e
        db  $a0, $0e
        db  $87, $0e
        db  $87, $0e
        db  $87, $0e
        db  $87, $0e
        db  $87, $0e
        db  $87, $0e
        db  $87, $0e
        db  $87, $0e
        db  $87, $0e   
        db  $78, $0e
        db  $78, $0e
        db  $78, $0d
        db  $78, $0d
        db  $78, $0d
        db  $78, $0d
        db  $78, $0d
        db  $78, $0d
        db  $78, $0c
        db  $78, $09
        db  $78, $06
        db  $78, $05 
        db  $ff
