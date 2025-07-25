OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY {
    ram (rwx) : ORIGIN = 0x00000000, LENGTH = 0x00008000
}

SECTIONS
{
    .text : {
        *(.text.init)
        *(.text.*)
        *(.text)
    } > ram

    .data : {
        *(.data.*)
        *(.sdata*)
        *(.data)
    } > ram
    
    .rodata : {
        *(.rodata.*)
        *(.srodata.*)
        *(.rodata)
    } > ram

    .bss : {
        *(.bss.*)
        *(.sbss)
        *(.bss)
        *(COMMON)
        _end = .;
    } > ram

    /DISCARD/ : {
        *(.debug*)
    }
}
