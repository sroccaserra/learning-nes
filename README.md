### Learnings

#### PPU

The first screen tile indexes are in $2000-$23bf included. The first screen
attributes are in $23c0-$23ff.

A one byte attribute sets the bg color palettes of a square of 4x4 tiles, or
four 2x2 tiles. There are 64 attributes ($40).

- PPU nametables ~ <https://wiki.nesdev.org/w/index.php/PPU_nametables>
- PPU attribute tables ~ <https://wiki.nesdev.org/w/index.php?title=PPU_attribute_tables>

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

### References

#### Introductions

- Famicom Party ~ <https://famicom.party/book>
- Game Development in Eight Bits ~ <https://www.youtube.com/watch?v=TPbroUDHG0s>
- Nerdy Nights ~ <https://taywee.github.io/NerdyNights/nerdynights.html>

#### 6502

- NMOS 6502 Opcodes ~ <http://www.6502.org/tutorials/6502opcodes.html>
- 6502 Microprocessor ~ <https://www.zophar.net/fileuploads/2/10532krzvs/6502.txt>
- 6502 Instruction Set ~ <https://www.masswerk.at/6502/6502_instruction_set.html>
- Beyond 8-bit Unsigned Comparisons ~ <http://www.6502.org/tutorials/compare_beyond.html>

#### NES

- Nesdev Wiki ~ <https://wiki.nesdev.org/w/index.php/Nesdev_Wiki>
- NROM ~ <https://wiki.nesdev.org/w/index.php?title=NROM>
- Programming NROM ~ <https://wiki.nesdev.org/w/index.php?title=Programming_NROM>
- CPU memory map ~ <https://wiki.nesdev.org/w/index.php?title=CPU_memory_map>
- PPU registers - PPUCTRL ~ <https://wiki.nesdev.org/w/index.php?title=PPU_registers#PPUCTRL>
- PPU registers - PPUMASK ~ <https://wiki.nesdev.org/w/index.php?title=PPU_registers#PPUMASK>
- PPU registers - PPUSTATUS ~ <https://wiki.nesdev.org/w/index.php?title=PPU_registers#PPUSTATUS>
- PPU registers - OAMDMA ~ <https://wiki.nesdev.org/w/index.php?title=PPU_registers#OAMDMA>
- PPU nametables ~ <https://wiki.nesdev.org/w/index.php/PPU_nametables>
- PPU attribute tables ~ <https://wiki.nesdev.org/w/index.php?title=PPU_attribute_tables>

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
