; vim: set filetype=asmM6502:

.macro push_registers
  php
  pha
  txa
  pha
  tya
  pha
.endmacro

.macro pop_registers
  pla
  tay
  pla
  tax
  pla
  plp
.endmacro
