OUTPUT_FORMAT(binary)
SECTIONS
{
    . = 0x1000;
    .text : {
        *(.text.kernel_main)  /* kernel_main’s code first */
        *(.text*)             /* All other text sections (print_char, print_string) */
    }
    .data : { *(.data) }      /* String data like "K\r\n" */
    .bss : { *(.bss) }
}