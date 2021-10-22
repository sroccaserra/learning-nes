### Learnings

ADC #$00 adds #1 when the carry flag is set.

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

#### Nes

- Famicom Party ~ <https://famicom.party/book>
- Nesdev Wiki ~ <https://wiki.nesdev.org/w/index.php/Nesdev_Wiki>
- Game Development in Eight Bits ~ <https://www.youtube.com/watch?v=TPbroUDHG0s>

#### 6502

- NMOS 6502 Opcodes ~ <http://www.6502.org/tutorials/6502opcodes.html>
- 6502 Microprocessor ~ <https://www.zophar.net/fileuploads/2/10532krzvs/6502.txt>
- 6502 Instruction Set ~ <https://www.masswerk.at/6502/6502_instruction_set.html>
- cc65 Documentation Overview ~ <https://cc65.github.io/doc/>
- ca65 Users Guide ~ <https://cc65.github.io/doc/ca65.html>

#### Code

- smbdis.asm - A comprehensive Super Mario Bros. disassembly ~ <https://gist.github.com/1wert3r/4048722>
- Disassembly by doppelganger ~ <https://6502disassembly.com/nes-smb/SuperMarioBros.html>
- SMB Disassembly CC65 ~ <https://github.com/threecreepio/smb-disassembly>
- Minimal NES example using ca65 ~ <https://github.com/bbbradsmith/NES-ca65-example>
- NES Programming ~ <https://www.youtube.com/playlist?list=PL29OkqO3wUxyF9BsTAgZkmCEVtC77rgff>
