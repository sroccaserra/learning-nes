; vim: set filetype=asmM6502:

.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y, scroll_y, ppu_ctrl, joypad_1

.segment "CODE"

.import main

.export reset_handler
.proc reset_handler
        sei                     ; set interrupt ignore bit
        cld                     ; clear decimal mode bit
        ldx #$ff
        txs                     ; reset stack
        ldx #$00
        stx PPUCTRL             ; turn off non maskable interrupts (NMI)
        stx ppu_ctrl
        stx PPUMASK             ; disable rendering

        ; disable sound
        stx $4015
        stx $4010
        lda #$40
        sta $4017

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

        ; init variables
        lda #120
        sta player_x
        lda #160
        sta player_y
        lda #$00
        sta scroll_y
        sta joypad_1

@waitvb2:
        bit PPUSTATUS
        bpl @waitvb2

        jmp main
.endproc
