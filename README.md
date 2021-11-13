![Screen](images/Screen.png?raw=true)

### Learnings

#### PPU

A tile contains 8 x 8 pixels.

A screen consists of 32 x 30 = 960 tiles (or $20 x $1e = $3c0 tiles), this is
256 x 240 pixels.

A one byte attribute sets the bg color palettes of a square of 4x4 tiles, or
four 2x2 tiles. There are 64 attributes ($40).

So a screen consists of 960 + 64 = 1024 bytes, or $3c0 + $40 = $400 bytes.

The first screen tile indexes are in $2000-$23bf included. The first screen
attributes are in $23c0-$23ff. The next screen starts at $2400 (PPU memory, not
CPU).

- PPU nametables ~ <https://wiki.nesdev.org/w/index.php/PPU_nametables>
- PPU attribute tables ~ <https://wiki.nesdev.org/w/index.php?title=PPU_attribute_tables>

**Fill a whole screen of tiles**

See : <https://www.youtube.com/watch?v=CyxznT1JgBg>

If we have a list of 960 tile indexes (a byte = a tile index) at the ROM
address `WorldData`, using the 2 bytes zero page `world` variable we can load
them to the PPU like so:

```s
    lda #<WorldData     ; low byte of the WorldData ROM address
    sta world
    lda #>WorldData     ; high byte of the WorldData ROM address
    sta world+1

    bit PPUSTATUS       ; latch
    lda #$20            ; first screen at $2000 (PPU address)
    sta PPUADDR
    lda #$00
    sta PPUADDR

    ldx #$00
    ldy #$00
@load_world:
    lda (world),y
    sta PPUDATA
    iny
    cpx #$03            ; we stop when we reach 960, i.e. when x = $03 and y = $c0
    bne :+
    cpy #$c0
    beq @done_loading_world
:
    cpy #$00
    bne @load_world
    inx                 ; a whole row has been loaded, we increment x
    inc world+1         ; increment high byte
    jmp @load_world     ; and proceed to fill the next row
@done_loading_world:

    ldx #$00
@set_attributes:
    lda #$55
    sta PPUDATA
    inx
    cpx #64             ; we set the same value for the 64 attributes of the first screen
    bne @set_attributes
```

#### ca65

The .word and .addr commands defines word sized data in little-endian format.
`.dword $1234` will emit the bytes `$34 $12`.

The .dbyt command defines word sized data in big-endian format. `.dbyt $1234`
will emit the bytes `$12 $34`.

#### Arithmetics

ADC #$00 adds #1 when the carry flag is set.

Warning: INC doesn't set the carry flag.

16 bit counter:

```asm
  CLC
  LDA counter_low
  ADC #1
  STA counter_low
  LDA counter_high
  ADC #0
  STA counter_high
```

8 bit addition with 16 bit result:

```asm
  CLC
  LDA num1
  ADC num2
  STA result_low
  LDA result_high
  ADC #$00
  STA result_high
```

16 bit addition:

```asm
  CLC
  LDA num1_low
  ADC num2_low
  STA result_low
  LDA num1_high
  ADC num2_high
  STA result_high
```

16 bit substraction:

```asm
  SEC
  LDA num1_low
  SBC num2_low
  STA result_low
  LDA num1_high
  SBC num2_high
  STA result_high
```

Double an 8 bit number with 16 bits result with BCC:

```asm
  LDA num1
  ASL
  STA result_low
  BCC :+
  INC result_high
  :
```

Multiply by two in place a 16 bit number:

```asm
  ASL num1_low
  ROL num1_high
```

Multiply by two, keeping the initial number:

```asm
  LDA num1_low
  ASL
  STA result_low
  LDA num1_high
  ROL
  STA result_high
```

Divide a 16 bit number by 2:

```asm
  LSR num1_high
  ROR num1_low
```

#### 6502 Addressing modes

The indirect indexed addressing mode `(indirect),y` is useful for array
processing. The 8-bit Y register is added to a 16-bit base address read from
zero page. This mode is only used with the Y register.

The indexed indirect addressing mode `(indirect,x)` is less frequently used. It
wraps around to a zero page address. This mode is only used with the X
register.

### References

#### Introductions

- Famicom Party ~ <https://famicom.party/book>
- Game Development in Eight Bits ~ <https://www.youtube.com/watch?v=TPbroUDHG0s>
- Nerdy Nights ~ <https://taywee.github.io/NerdyNights/nerdynights.html>

#### 6502

- MOS Technology 6502 ~ <https://fr.wikipedia.org/wiki/MOS_Technology_6502>
- NMOS 6502 Opcodes ~ <http://www.6502.org/tutorials/6502opcodes.html>
- 6502 Microprocessor ~ <https://www.zophar.net/fileuploads/2/10532krzvs/6502.txt>
- 6502 Instruction Set ~ <https://www.masswerk.at/6502/6502_instruction_set.html>
- Beyond 8-bit Unsigned Comparisons ~ <http://www.6502.org/tutorials/compare_beyond.html>
- 6502 Addressing Modes ~ <http://www.emulator101.com/6502-addressing-modes.html>

#### NES

- Nesdev Wiki ~ <https://wiki.nesdev.org/w/index.php/Nesdev_Wiki>
- NROM ~ <https://wiki.nesdev.org/w/index.php?title=NROM>
- Programming NROM ~ <https://wiki.nesdev.org/w/index.php?title=Programming_NROM>
- CPU memory map ~ <https://wiki.nesdev.org/w/index.php?title=CPU_memory_map>
- PPU programmer reference ~ <https://wiki.nesdev.org/w/index.php/PPU_programmer_reference>
- PPU registers - PPUCTRL ~ <https://wiki.nesdev.org/w/index.php?title=PPU_registers#PPUCTRL>
- PPU registers - PPUMASK ~ <https://wiki.nesdev.org/w/index.php?title=PPU_registers#PPUMASK>
- PPU registers - PPUSTATUS ~ <https://wiki.nesdev.org/w/index.php?title=PPU_registers#PPUSTATUS>
- PPU registers - OAMDMA ~ <https://wiki.nesdev.org/w/index.php?title=PPU_registers#OAMDMA>
- PPU rendering ~ <https://wiki.nesdev.org/w/index.php?title=PPU_rendering>
- PPU nametables ~ <https://wiki.nesdev.org/w/index.php/PPU_nametables>
- Mirroring ~ <https://wiki.nesdev.org/w/index.php?title=Mirroring>
- PPU attribute tables ~ <https://wiki.nesdev.org/w/index.php?title=PPU_attribute_tables>
- PPU palettes ~ <https://wiki.nesdev.org/w/index.php/PPU_palettes>
- PPU scrolling ~ <https://wiki.nesdev.org/w/index.php/PPU_scrolling>
- NMI thread ~ <https://wiki.nesdev.org/w/index.php/NMI_thread>
- The frame and NMIs ~ <https://wiki.nesdev.org/w/index.php?title=The_frame_and_NMIs>

#### Code

- Minimal NES example using ca65 ~ <https://github.com/bbbradsmith/NES-ca65-example>
- NES Programming ~ <https://www.youtube.com/playlist?list=PL29OkqO3wUxyF9BsTAgZkmCEVtC77rgff>
- smbdis.asm - A comprehensive Super Mario Bros. disassembly ~ <https://gist.github.com/1wert3r/4048722>
- Disassembly by doppelganger ~ <https://6502disassembly.com/nes-smb/SuperMarioBros.html>
- SMB Disassembly CC65 ~ <https://github.com/threecreepio/smb-disassembly>

#### Tools

- cc65 Documentation Overview ~ <https://cc65.github.io/doc/>
- ca65 Users Guide ~ <https://cc65.github.io/doc/ca65.html>
- FCEUX Help - Debugger ~ <https://fceux.com/web/help/Debugger.html>

#### For future reference

- CHR ROM vs. CHR RAM ~ <https://wiki.nesdev.org/w/index.php?title=CHR_ROM_vs._CHR_RAM#Switching_to_CHR_RAM>
- UxROM ~ <https://wiki.nesdev.org/w/index.php?title=UxROM>
- Programming UNROM ~ <https://wiki.nesdev.org/w/index.php?title=Programming_UNROM>
- MMC1 ~ <https://wiki.nesdev.org/w/index.php?title=MMC1>
- Programming MMC1 ~ <https://wiki.nesdev.org/w/index.php?title=Programming_MMC1>
