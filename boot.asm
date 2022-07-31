[org 0x7c00]
KERNEL_LOCATION equ 0x1000
; Set Extra Segment to 0
mov ax, 0
mov es, ax

mov al, 0x13
mov ah, 0
int 10h

; Read Disk
mov ah, 2
mov al, 3 ; Disk - Sectors to Read
mov ch, 0 ; Disk - Cylinder Number
mov cl, 2 ; Disk - Sector Number
mov dh, 0 ; Disk - Head Number
mov bx, KERNEL_LOCATION
int 0x13


call clearScreen
cli
lgdt [gdt_desc]
mov eax, cr0
or eax, 1
mov cr0, eax
jmp codeSegment:protected_mode_kernel

CPUID_ERR_LABEL:
    db "Platform doesn't support x86_64.", 0

[bits 32]
protected_mode_kernel:
    mov ax, dataSegment
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

    call DETECT_CPUID
    call DETECT_x86_64
	
    jmp KERNEL_LOCATION

DETECT_x86_64:
    mov eax, 0x80000001  
    cpuid                  ; CPU identification.
    test edx, 1 << 29      ; Test if the LM-bit, which is bit 29, is set in the D-register.
    jz CPUID_ERR
    ret

DETECT_CPUID:
    pushfd
    pop eax
    
    ; Copy to ECX as well for comparing later on
    mov ecx, eax
    
    ; Flip the ID bit
    xor eax, 1 << 21
    
    ; Copy EAX to FLAGS via the stack
    push eax
    popfd
    
    ; Copy FLAGS back to EAX (with the flipped bit if CPUID is supported)
    pushfd
    pop eax
    
    ; Restore FLAGS from the old version stored in ECX (i.e. flipping the ID bit
    ; back if it was ever flipped).
    push ecx
    popfd
    
    ; Compare EAX and ECX. If they are equal then that means the bit wasn't
    ; flipped, and CPUID isn't supported.
    jz CPUID_ERR
    ret

CPUID_ERR:
    ; Disable Cursor

    mov dx, 0x3D4
    mov al, 0x0A
    out dx, al

	mov dx, 0x3D5
    mov al, 0x20
    out dx, al

    mov ebx, 0xb8000 ; Move 0xb8000 (Video Pointer) into ecx
    mov edx, CPUID_ERR_LABEL ; Move Pointer for CPUID_ERR_LABEL into edx
    jmp CPUID_ERR_LOOP
CPUID_ERR_LOOP:
    cmp byte [edx], $0
    je CPUID_ERR_END ; Jump to label CPUID_ERR_END if [edx] == 0
    mov al, [edx] ; Move byte at edx (String Pointer) into al (Character)
    mov ah, 0x0F  ; Move byte 0x0F into ah (Color Encoding)
    mov [ebx], ax ; Move ax (Character + Color Encoding) into ebx (Video Pointer)
    inc edx ; Increment edx (String Pointer)
    add ebx, 2 ; Increment ebx (Video Pointer)
    jmp CPUID_ERR_LOOP ; Jump to stop CPU
CPUID_ERR_END:
    hlt ; Stop CPU from executing tasks
    jmp CPUID_ERR_END ; Jump back to stop CPU

clearScreen:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    ret

gdt_start:
    null_desc:
        dd 0
        dd 0
    code_desc:
        dw 65535 ; Limit
        dw 0 ; Base (2 bytes)
        db 0 ; Base (1 byte)
        db 0b10011010 ; Type Flags
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

times 510-($-$$) db 0
db 0x55, 0xaa