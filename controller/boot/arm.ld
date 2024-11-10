/* Unused, but here to silence a linker warning. */
ENTRY(main)

/* define output sections */
SECTIONS
{
    /* Program code and read-only data goes to FLASH_TEXT. */
    .text :
    {
        KEEP(*(.isr_vector))
        *(.text)
        *(.text.*)
        *(.rodata)
        *(.rodata.*)
        . = ALIGN(4);
    } >FLASH_TEXT

    /* Put the stack at the bottom of RAM, so that the application will
     * crash on stack overflow instead of silently corrupting memory.
     * See: http://blog.japaric.io/stack-overflow-protection/ */
    .stack (NOLOAD) :
    {
        . = ALIGN(4);
        . += _stack_size;
        __initial_stack_top = .;
    } >RAM

    /* Start address (in flash) of .data, used by startup code. */
    __section_data_flashaddr = LOADADDR(.data);

    /* Globals with initial value */
    .data :
    {
        . = ALIGN(4);
        __section_data_start = .;        /* used by startup code */
        *(.data)
        *(.data.*)
        . = ALIGN(4);
        *(.ramfuncs*)      /* Functions that must execute from RAM */
        . = ALIGN(4);
        __section_data_end = .;        /* used by startup code */
    } >RAM AT>FLASH_TEXT

    /* Zero-initialized globals  */
    .bss :
    {
        . = ALIGN(4);
        __section_bss_start = .;         /* used by startup code */
        *(.bss)
        *(.bss.*)
        *(COMMON)
        . = ALIGN(4);
        __section_bss_end = .;         /* used by startup code */
    } >RAM

    /DISCARD/ :
    {
        *(.ARM.exidx)      /* causes 'no memory region specified' error in lld */
        *(.ARM.exidx.*)    /* causes spurious 'undefined reference' errors */
    }
}

/* For the memory allocator. */
__heap_start = __section_bss_end;
__heap_end = ORIGIN(RAM) + LENGTH(RAM);

/* For the flash API */
__flash_writable_start = LOADADDR(.data) + SIZEOF(.data);
__flash_writable_end = ORIGIN(FLASH_TEXT) + LENGTH(FLASH_TEXT);
