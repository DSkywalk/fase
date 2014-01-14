#ifndef __LIBRARY_FASE__
#define __LIBRARY_FASE__
#pragma push(case_insensitive)
#pragma case_insensitive = true

#define INIT        \
    asm             \
        call $fffc  \
    end asm

#define FRAME       \
    asm             \
        call $fff1  \
    end asm

#define DisableInt  \
    asm             \
        di          \
    end asm

#define SETSPRITE(number, param, value) POKE $5b00+(number)*4+(param), (value)
#define GETSPRITE(number, param)        PEEK ($5b00+(number)*4+(param))
DIM scr AS UByte AT $5c00

#pragma pop(case_insensitive)
#endif
