; vim: set filetype=asmM6502:

.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y, scroll_y

.segment "CODE"

.import main

.export reset_handler
.proc reset_handler
        sei                     ; set interrupt ignore bit
        cld                     ; clear decimal mode bit
        ldx #$00
        stx PPUCTRL             ; turn off non maskable interrupts (NMI)
        stx PPUMASK             ; disable rendering

@waitvb:
        bit PPUSTATUS
        bpl @waitvb             ; loop waiting for vblank

        ldx #$00
        lda #$ff
@clear_oam:
        sta $0200,X             ; set all sprite y-positions off the screen
        inx
        inx
        inx
        inx
        bne @clear_oam

        lda #128
        sta player_x
        lda #160
        sta player_y
        lda #0
        sta scroll_y

@waitvb2:
        bit PPUSTATUS
        bpl @waitvb2

        jmp main
.endproc
