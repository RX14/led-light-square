MEMORY
{
    FLASH_TEXT (rx) : ORIGIN = 0x00000000, LENGTH = __flash_size
    RAM (rwx)       : ORIGIN = 0x20000000, LENGTH = __ram_size
}

_stack_size = 256;

INCLUDE "boot/arm.ld"
