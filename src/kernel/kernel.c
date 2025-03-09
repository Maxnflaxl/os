#define BUFFER_SIZE 128

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

char get_char() {
    char c;
    asm volatile (
        "movb $0x00, %%ah\n"
        "int $0x16\n"
        : "=al"(c)
        :
        : "ah"
    );
    return c;
}

void echo() {
    char buffer[BUFFER_SIZE];
    int index = 0;

    print_string("Type something: ");
    while (1) {
        char c = get_char();
        if (c == 0x08) {  // Backspace
            if (index > 0) {
                index--;
                print_char(0x08);
                print_char(' ');
                print_char(0x08);
            }
            continue;
        }
        if (c == 0x0D) {  // Enter
            print_char(0x0D);
            print_char(0x0A);
            buffer[index] = 0;  // Null-terminate
            print_string(buffer);
            print_char(0x0D);
            print_char(0x0A);
            break;
        }
        if (index < BUFFER_SIZE - 1) {
            buffer[index++] = c;
            print_char(c);
        }
    }
}

__attribute__((section(".text.kernel_main"))) // must keep
void kernel_main() {
    print_string("Hello from the kernel!\r\n");
    echo();
    while (1);
}