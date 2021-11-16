CC = arm-none-eabi-gcc
LD = $(CC)

CC_ARGS = -mcpu=arm1176jzf-s -fpic -ffreestanding -c -Wall -Wextra
LD_ARGS = -T linker.ld -o kernel.elf -ffreestanding -O2 -nostdlib # -lgcc

QEMU = qemu-system-arm -m 512 -M raspi0 -serial stdio -kernel

BUILD_DIR = output
SRC_DIR = kernel

C_FILES = $(wildcard kernel/*.c)
ASM_FILES = boot/boot.S $(wildcard kernel/*.S)

OBJ_FILES = output/boot.o $(C_FILES:kernel/%.c=output/%_c.o)

TARGET = kernel.elf

.PHONY: clean qemu

all: $(TARGET)

$(BUILD_DIR)/boot.o: boot/boot.S
	mkdir -p $(@D)
	$(CC) $(CC_ARGS) $< -o $@

$(BUILD_DIR)/%_c.o: $(SRC_DIR)/%.c
	$(CC) $(CC_ARGS) -std=gnu99 $< -o $@

$(BUILD_DIR)/%_s.o: $(SRC_DIR)/%.S
	$(CC) $(CC_ARGS) $< -o $@

$(TARGET): $(OBJ_FILES)
	$(CC) $(LD_ARGS) $(OBJ_FILES) -lgcc

clean:
	rm -r output *.o *.elf *.bin *.img

qemu: $(TARGET)
	$(QEMU) $(TARGET)
