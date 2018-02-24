
ARMGNU ?= arm-none-eabi

AOPS = --warn --fatal-warnings 
COPS = -Wall -Werror -O2 -nostdlib -nostartfiles -ffreestanding 



gcc : laboratory.hex laboratory.bin

all : gcc clang

clean :
	rm -f *.o
	rm -f *.bin
	rm -f *.hex
	rm -f *.elf
	rm -f *.list
	rm -f *.img
	rm -f *.bc
	rm -f *.clang.opt.s

vectors.o : vectors.s
	$(ARMGNU)-as vectors.s -o vectors.o

laboratory.o : laboratory.c
	$(ARMGNU)-gcc $(COPS) -c laboratory.c -o laboratory.o

laboratory.elf : memmap vectors.o laboratory.o 
	$(ARMGNU)-ld vectors.o laboratory.o -T memmap -o laboratory.elf
	$(ARMGNU)-objdump -D laboratory.elf > laboratory.list

laboratory.bin : laboratory.elf
	$(ARMGNU)-objcopy laboratory.elf -O binary laboratory.bin

laboratory.hex : laboratory.elf
	$(ARMGNU)-objcopy laboratory.elf -O ihex laboratory.hex






LOPS = -Wall -m32 -emit-llvm
LLCOPS = -march=armv8-a -mcpu=cortex-a53
LLCOPS0 = -march=armv8-a 
LLCOPS1 = -march=armv8-a -mcpu=cortex-a53
COPS = -Wall  -O2 -nostdlib -nostartfiles -ffreestanding
OOPS = -std-compile-opts

clang : laboratory.clang.hex laboratory.clang.bin


laboratory.clang.bc : laboratory.c
	clang $(LOPS) -c laboratory.c -o laboratory.clang.bc

laboratory.clang.opt.elf : memmap vectors.o laboratory.clang.bc
	opt $(OOPS) laboratory.clang.bc -o laboratory.clang.opt.bc
	llc $(LLCOPS) laboratory.clang.opt.bc -o laboratory.clang.opt.s
	$(ARMGNU)-as laboratory.clang.opt.s -o laboratory.clang.opt.o
	$(ARMGNU)-ld -o laboratory.clang.opt.elf -T memmap vectors.o laboratory.clang.opt.o
	$(ARMGNU)-objdump -D laboratory.clang.opt.elf > laboratory.clang.opt.list

laboratory.clang.hex : laboratory.clang.opt.elf
	$(ARMGNU)-objcopy laboratory.clang.opt.elf laboratory.clang.hex -O ihex

laboratory.clang.bin : laboratory.clang.opt.elf
	$(ARMGNU)-objcopy laboratory.clang.opt.elf laboratory.clang.bin -O binary


