section .text
    [bits 64]
    [extern main]
    [extern _initalize]
    
    ; Stop Flickering

    mov dx, 0x3DA
    in al, dx
    mov dx, 0x3C0
    mov al, 0x30
    out dx, al
    inc dx
    in al, dx
    and al, 0xF7
    dec dx
    out dx, al
    
    call _initalize
    call main
    hlt
    jmp $-1