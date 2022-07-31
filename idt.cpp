#include <stdint.h>
typedef struct {
   unsigned short offset_1;        // offset bits 0..15
   unsigned short selector;        // a code segment selector in GDT or LDT
   unsigned char  zero;            // unused, set to 0
   unsigned char  type_attributes; // gate type, dpl, and p fields
   unsigned short offset_2;        // offset bits 16..31
} __attribute__((packed)) IDTEntry;

typedef struct {
   unsigned short Limit;
    IDTEntry *ptr;
} __attribute__((packed)) IDTDesc;

IDTEntry _idt[256];
extern uint32_t isrl;

IDTDesc idtDescriptor = { sizeof(_idt) - 1, _idt };

void __attribute__((cdecl)) IDT_LOAD(IDTDesc* idtdesc);


void IDT_SET_GATE(int interrupt, uint32_t base, unsigned short descriptor, unsigned char flags) {
    
}