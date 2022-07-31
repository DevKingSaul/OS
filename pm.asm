clearScreen:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    ret

printChar:
    mov ah, 0x0f
    int 0x10 ; Call Interrupt 0x10 (Write Character)
    ret



gdt_start:
    null_desc:
        dd 0
        dd 0
    code_desc:
        dw 65535 ; Limit
        dw 0 ; Base (2 bytes)
        db 0 ; Base (1 byte)
        db 0b10011000 ; Type Flags
        db 0b11001111; Other Flags (4 bits) + Base (4 bits)
        db 0 ; Base (1 byte)
    data_desc:
        dw 65535 ; Limit
        dw 0 ; Base (2 bytes)
        db 0 ; Base (1 byte)
        db 0b10010010 ; Type Flags
        db 0b11001111; Other Flags (4 bits) + Base (4 bits)
        db 0 ; Base (1 byte)
gdt_end:

gdt_desc:
    dw gdt_end - gdt_start - 1
    dd gdt_start

codeSegment equ code_desc - gdt_start
dataSegment equ data_desc - gdt_start

; Switch to Protected Mode

call clearScreen

cli
lgdt [gdt_desc]

mov eax, cr0
or eax, 1
mov cr0, eax
jmp codeSegment:protected_mode_kernel

[bits 32]
protected_mode_kernel:
    jmp $

times 510-($-$$) db 0
db 0x55, 0xaa