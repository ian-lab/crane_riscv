
all:
	riscvasm -o test.o test.s
	riscvlink -o test.elf test.o
	riscvcopy -O binary test.elf test.bin
	hexdump -v -e '1/4 "%08x\n"' test.bin > test..hex