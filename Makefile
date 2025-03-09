# Tools
ASM = nasm
CC = i686-elf-gcc
LD = i686-elf-ld

# Directories
SRC_DIR = src
BUILD_DIR = build

# Flags
ASM_FLAGS = -f bin
CFLAGS = -ffreestanding -m16 -c
LDFLAGS = -T $(SRC_DIR)/linker.ld --oformat=binary

# Targets
all: $(BUILD_DIR)/boot_floppy.img

$(BUILD_DIR)/boot_floppy.img: $(BUILD_DIR)/boot.bin $(BUILD_DIR)/kernel.bin
	cat $(BUILD_DIR)/boot.bin $(BUILD_DIR)/kernel.bin > $(BUILD_DIR)/boot_floppy.img
	truncate -s 1440k $(BUILD_DIR)/boot_floppy.img

$(BUILD_DIR)/boot.bin: $(SRC_DIR)/boot.asm
	mkdir -p $(BUILD_DIR)
	$(ASM) $(ASM_FLAGS) $(SRC_DIR)/boot.asm -o $(BUILD_DIR)/boot.bin

$(BUILD_DIR)/kernel.bin: $(BUILD_DIR)/kernel.o
	$(LD) $(LDFLAGS) $(BUILD_DIR)/kernel.o -o $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.o: $(SRC_DIR)/kernel/kernel.c
	mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) $(SRC_DIR)/kernel/kernel.c -o $(BUILD_DIR)/kernel.o

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)/*

run: $(BUILD_DIR)/boot_floppy.img
	qemu-system-i386 -drive format=raw,file=$(BUILD_DIR)/boot_floppy.img,if=floppy