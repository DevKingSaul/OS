main32:
	export PATH="$PATH:/usr/local/i386elfgcc/bin"
	nasm -f bin boot.asm -o boot.bin
	nasm "kernel_entry.asm" -f elf -o "kernel_entry.o"
	nasm "idt.asm" -f elf -o "idt-asm.o"
	/usr/local/i386elfgcc/bin/i386-elf-gcc -ffreestanding -m32 -g -c "kernel.cpp" -o "kernel.o"
	/usr/local/i386elfgcc/bin/i386-elf-gcc -ffreestanding -m32 -g -c "idt.cpp" -o "idt.o"
	/usr/local/i386elfgcc/bin/i386-elf-ld -o "kernel.bin" -Ttext 0x1000 "kernel_entry.o" "kernel.o" "idt-asm.o" --oformat binary
	cat "boot.bin" "kernel.bin" > "os.bin"
	rm idt.o
	rm boot.bin
	rm kernel.o
	rm kernel_entry.o
	rm kernel.bin
	truncate -s 2048 os.
	
main:
	export PATH="$PATH:/usr/local/i386elfgcc/bin"
	nasm -f bin boot.asm -o boot.bin
	nasm "kernel_entry.asm" -f elf -o "kernel_entry.o"
	nasm "idt.asm" -f elf -o "idt-asm.o"
	gcc -ffreestanding -m64 -g -c "kernel.cpp" -o "kernel.o"
	gcc -ffreestanding -m64 -g -c "idt.cpp" -o "idt.o"
	ld -o "kernel.bin" -Ttext 0x1000 "kernel_entry.o" "kernel.o" "idt-asm.o" --oformat binary
	cat "boot.bin" "kernel.bin" > "os.bin"
	rm idt.o
	rm boot.bin
	rm kernel.o
	rm kernel_entry.o
	rm kernel.bin
	truncate -s 2048 os.bin

virtualbox:
	rm os.vdi
	truncate -s 1M os.bin
	VBoxManage convertfromraw os.bin os.vdi --format VDI --uuid 75ed0c5b-6e07-4b13-a08a-ac6d14eb18dd