tabla_song:
        defw    song_0, song_1

        include "mus/song.mus.asm"

song_0: binary  "mus/song0.mus"
song_1: binary  "mus/song1.mus"

;; INCLUIR LOS EFECTOS DE SONIDO:

tabla_efectos: defw  efecto0, efecto1, efecto2, efecto3, efecto4, efecto5

; (0) select
efecto0: defb  $51, $1a
        defb  $5a, $0f
        defb  $3c, $0f
        defb  $1e, $0e
        defb  $2d, $0e
        defb  $5a, $0b
        defb  $3c, $0b
        defb  $1e, $0a
        defb  $2d, $0a
        defb  $b4, $01
        defb  $ff
  
; (1) start 
efecto1: defb  $25, $1c
        defb  $3a, $0f
        defb  $2d, $0f
        defb  $e2, $0f
        defb  $bc, $0f
        defb  $96, $0d
        defb  $4b, $0d
        defb  $32, $0d
        defb  $3a, $0d
        defb  $2d, $0d
        defb  $e2, $0d
        defb  $bc, $0d
        defb  $96, $0d
        defb  $4b, $0d
        defb  $32, $0d
        defb  $3a, $0d
        defb  $2d, $0c
        defb  $e2, $0c
        defb  $bc, $0c
        defb  $96, $0b
        defb  $4b, $0b
        defb  $32, $0b
        defb  $3a, $0b
        defb  $2d, $0b
        defb  $e2, $0b
        defb  $bc, $0b
        defb  $96, $0b
        defb  $4b, $0a
        defb  $32, $0a
        defb  $3a, $0a
        defb  $2d, $09
        defb  $e2, $09
        defb  $bc, $08
        defb  $96, $08
        defb  $4b, $08
        defb  $32, $07
        defb  $3a, $07
        defb  $2d, $06
        defb  $e2, $06
        defb  $bc, $06
        defb  $96, $05
        defb  $4b, $05
        defb  $32, $05
        defb  $3a, $04
        defb  $2d, $04
        defb  $e2, $03
        defb  $bc, $03
        defb  $96, $03
        defb  $4b, $03
        defb  $32, $02
        defb  $3a, $01
        defb  $2d, $01
        defb  $e2, $01
        defb  $bc, $01
        defb  $ff

; (2) sartar
efecto2: defb  $e8, $1b
        defb  $b4, $0f
        defb  $a0, $0e
        defb  $90, $0d
        defb  $87, $0d
        defb  $78, $0c 
        defb  $6c, $0b 
        defb  $60, $0a 
        defb  $5a, $09
        defb  $ff 

; (3) disparo 1
efecto3: defb  $1f, $0b
        defb  $5a, $0f
        defb  $3c, $0f
        defb  $1e, $0a
        defb  $2d, $0a
        defb  $5a, $05
        defb  $3c, $05
        defb  $1e, $04
        defb  $2d, $02
        defb  $b4, $01
        defb  $ff

; (4) disparo 2
efecto4: defb  $1f, $0b
        defb  $af, $0f
        defb  $8a, $0f
        defb  $71, $0f
        defb  $64, $0f
        defb  $3e, $0c
        defb  $25, $0c
        defb  $25, $0c
        defb  $25, $0c
        defb  $25, $0a
        defb  $4b, $0a
        defb  $4b, $0a
        defb  $4b, $0a
        defb  $3e, $08
        defb  $3e, $08
        defb  $3e, $08
        defb  $71, $08
        defb  $3e, $07
        defb  $25, $05
        defb  $25, $02
        defb  $ff
  
; (5) vida  
efecto5: defb  $1a, $0e
        defb  $b4, $0e
        defb  $b4, $0e
        defb  $b4, $0e
        defb  $b4, $0e
        defb  $b4, $0e
        defb  $b4, $0e
        defb  $b4, $0e
        defb  $b4, $0e 
        defb  $a0, $0e
        defb  $a0, $0e
        defb  $a0, $0e
        defb  $a0, $0e
        defb  $a0, $0e
        defb  $a0, $0e
        defb  $a0, $0e
        defb  $87, $0e
        defb  $87, $0e
        defb  $87, $0e
        defb  $87, $0e
        defb  $87, $0e
        defb  $87, $0e
        defb  $87, $0e
        defb  $87, $0e
        defb  $87, $0e   
        defb  $78, $0e
        defb  $78, $0e
        defb  $78, $0d
        defb  $78, $0d
        defb  $78, $0d
        defb  $78, $0d
        defb  $78, $0d
        defb  $78, $0d
        defb  $78, $0c
        defb  $78, $09
        defb  $78, $06
        defb  $78, $05 
        defb  $ff
