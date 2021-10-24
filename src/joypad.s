; vim: set filetype=asmM6502:

; https://wiki.nesdev.org/w/index.php?title=Controller_reading_code

.include "constants.inc"

.importzp joypad_1

.export read_joypad
read_joypad:
        lda #1
        sta JOYPAD1
        lda #0
        sta JOYPAD1
        ldx #8

@loop:
        pha
        lda JOYPAD1
        and #%00000011
        cmp #%00000001
        pla
        ror
        dex
        bne @loop

        sta joypad_1
        rts
