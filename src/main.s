; vim: set filetype=asmM6502:

.MACPACK generic

.include "constants.inc"
.include "header.inc"
.include "macros.inc"

.import reset_handler
.import load_background
.import read_joypad

.segment "ZEROPAGE"

; state variables
player_x: .res 1
player_y: .res 1
player_dir: .res 1
scroll_y: .res 1
ppu_ctrl: .res 1
.exportzp player_x, player_y, scroll_y, ppu_ctrl

joypad_1: .res 1
.exportzp joypad_1

; temp variables
p_1: .res 1
p_2: .res 1
.exportzp p_1, p_2

; temp variables for 16 bit values
lo_1: .res 1
hi_1: .res 1
lo_2: .res 1
hi_2: .res 1
.exportzp lo_1, lo_2, hi_1, hi_2

.segment "CODE"

.proc nmi_handler
        push_registers
        lda #$00
        sta OAMADDR
        lda #$02
        sta OAMDMA

        jsr draw_player
        lda scroll_y
        bnz @do_scroll
        lda #Y_RESOLUTION
        sta scroll_y
        lda ppu_ctrl
        eor #%00000010          ; switch nametable between $2000 (%00) and  $2800 (%10)
        sta ppu_ctrl
        sta PPUCTRL
@do_scroll:
        dec scroll_y
        lda #$00                ; scroll x is 0
        sta PPUSCROLL
        lda scroll_y
        sta PPUSCROLL

        pop_registers
        rti
.endproc

.proc irq_handler
        rti
.endproc

.export main
.proc main
        ; write palettes
        ldx PPUSTATUS           ; resets the address latch
        ldx #$3f
        stx PPUADDR
        ldx #$00
        stx PPUADDR             ; sets #$3f00 (first palette index) as address
@load_palettes:
        lda palettes,X
        sta PPUDATA
        inx
        cpx #32
        bne @load_palettes

        jsr load_background

@waitvb:                        ; wait for another vblank before continuing
        bit PPUSTATUS
        bpl @waitvb

        lda #%10010000
        sta PPUCTRL             ; turn on NMIs, sprites use first pattern table
        sta ppu_ctrl

        lda #%00011110
        sta PPUMASK             ; enable rendering
@loop:
        bit PPUSTATUS
        bpl @loop

        jsr read_joypad
        jsr update_player
        jmp @loop
.endproc

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

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"

palettes:
.byte $0f, $12, $23, $27        ; Background palettes
.byte $0f, $2b, $3c, $39
.byte $0f, $0c, $07, $13
.byte $0f, $19, $09, $29

.byte $0f, $11, $21, $20        ; Sprites palettes
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29

.segment "CHR"
.incbin "graphics.chr"
