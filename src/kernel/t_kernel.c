/* kernel test*/

void print_char(char c) {
    asm volatile (
        "movb $0x0E, %%ah\n"
        "movb $0, %%bh\n"
        "int $0x10\n"
        :
        : "al"(c)
        : "ah", "bh"
    );
}

void print_string(const char* str) {
    while (*str) {
        print_char(*str++);
    }
}

__attribute__((section(".text.kernel_main")))
void kernel_main() {
    print_string("Hello from the kernel\r\n");
    while (1);
}