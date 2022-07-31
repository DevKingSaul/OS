; Set Extra Segment to 0
mov ax, 0
mov es, ax

mov ah, 2
mov al, 1 ; Disk - Sectors to Read
mov ch, 0 ; Disk - Cylinder Number
mov cl, 2 ; Disk - Sector Number
mov dh, 0 ; Disk - Head Number
mov bx, 0x7e00
int 0x13

mov ah, 0x0e
mov al, [0x7e00]
int 0x10 ; Call Interrupt 0x10 (Write Character)

hlt
jmp $-1

times 510-($-$$) db 0
db 0x55, 0xaa
times 512 db 'F'