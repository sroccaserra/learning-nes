; vim: set filetype=asmM6502:

.MACPACK generic

.include "constants.inc"

.importzp joypad_1

.segment "ZEROPAGE"

player_x: .res 1
player_y: .res 1
player_dir: .res 1
.exportzp player_x, player_y, player_dir

.segment "CODE"

.export draw_player
.proc draw_player
        ; tile numbers
        lda #$05
        sta $0201
        lda #$06
        sta $0205
        lda #$07
        sta $0209
        lda #$08
        sta $020d
        ; tile attributes (palette 0)
        lda #$00
        sta $0202
        sta $0206
        sta $020a
        sta $020e

        ; tile locations
        lda player_y
        sta $0200
        lda player_x
        sta $0203

        lda player_y
        sta $0204
        lda player_x
        add #$08
        sta $0207

        lda player_y
        add #$08
        sta $0208
        lda player_x
        sta $020b

        lda player_y
        add #$08
        sta $020c
        lda player_x
        add #$08
        sta $020f

        rts
.endproc

.export update_player
.proc update_player
        lda joypad_1
        and #PAD_U
        bze :+
        dec player_y
        dec player_y
        :
        lda joypad_1
        and #PAD_D
        bze :+
        inc player_y
        inc player_y
        :
        lda joypad_1
        and #PAD_L
        bze :+
        dec player_x
        dec player_x
        :
        lda joypad_1
        and #PAD_R
        bze :+
        inc player_x
        inc player_x
        :
        rts
.endproc
