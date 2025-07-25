OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY {
    ram (rwx) : ORIGIN = 0x00000000, LENGTH = 0x00008000
}

SECTIONS
{
  .text.init : { *(.text.init) } > ram
  .text : { *(.text) } > ram
  .data : { *(.data) } > ram
  .bss : { *(.bss) } > ram
  _end = .;
}
