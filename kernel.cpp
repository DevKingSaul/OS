#include <stdint.h>
#include "idt.h"

char *video;
int videoOffset = 0;

char hexTable[16];

void printHex(char chr, char color) {
    video[videoOffset] = hexTable[(chr >> 4) & 0xf];
    video[videoOffset + 1] = color;
    video[videoOffset + 2] = hexTable[(chr & 0xf)];
    video[videoOffset + 3] = color;

    videoOffset += 4;
}

void printHex_U32(uint32_t integer, char color) {
    printHex((integer >> 24) & 0xff, color);
    printHex((integer >> 16) & 0xff, color);
    printHex((integer >> 8) & 0xff, color);
    printHex(integer & 0xff, color);
}

void printString(char *str, int color) {
    while (*str != 0) {
        video[videoOffset] = *str++;
        video[videoOffset + 1] = color;

        videoOffset += 2;
    }
}

static inline void outb(unsigned short port, unsigned char val)
{
    asm volatile ( "outb %0, %1" : : "a"(val), "Nd"(port) );
}

extern "C" void _initalize() {
    videoOffset = 0;

    hexTable[0] = '0';
    hexTable[1] = '1';
    hexTable[2] = '2';
    hexTable[3] = '3';
    hexTable[4] = '4';
    hexTable[5] = '5';
    hexTable[6] = '6';
    hexTable[7] = '7';
    hexTable[8] = '8';
    hexTable[9] = '9';
    hexTable[10] = 'A';
    hexTable[11] = 'B';
    hexTable[12] = 'C';
    hexTable[13] = 'D';
    hexTable[14] = 'E';
    hexTable[15] = 'F';

    video = (char*)0xb8000;
}

void disableCursor() {
    outb(0x3D4, 0x0A);
	outb(0x3D5, 0x20);
}

void setBG(int color) {
    for (int i = 0; i < 4000; i += 2) {
        video[i] = 0;
        video[i + 1] = color;
    }
}

void kePanic(char* errorName, uint32_t errorCode) {
    disableCursor();
    setBG(0x10);

    videoOffset = 216;
    printString(" DoorsOS - Kernel Panic ", 0xf1);

    videoOffset = 484;
    printString(" Build Version: 1.0 ", 0xf1);

    videoOffset = 804;
    printString(" Error: ", 0xf1);
    printString(errorName, 0xf1);
    printString(" (0x", 0xf1);
    printHex_U32(errorCode, 0xf1);
    printString(") ", 0xf1);

    return;
}

// 80 x 25

void update_cursor(int x, int y)
{
	uint16_t pos = y * 80 + x;
 
	outb(0x3D4, 0x0F);
	outb(0x3D5, (uint8_t) (pos & 0xFF));
	outb(0x3D4, 0x0E);
	outb(0x3D5, (uint8_t) ((pos >> 8) & 0xFF));
}

extern "C" void main() {

    videoOffset = 0;
    printString("Welcome to DoorsOS!", 0x0f);
    videoOffset = 160;
    printString("> help", 0x0f);
    videoOffset = 320;
    update_cursor(2, 1);
    //printString("Executing command \"help\" as System (Ring 0)", 0x0f);
    //printHex_U32(isrl, 0x0f);
    //disableCursor();
  
    kePanic("Segmentation Violation", 500);
    
    return;
}
// qemu-system-i386 os.bin # This will give Kernel Panic / Blue Screen of Death
// qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd os.bin