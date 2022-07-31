call kernelPanic
call clearScreen

; Print Friendly Welcome Message
mov bx, welcomeMesssage + 0x7c00
call printString
call printNewLine
mov bx, commandLineExample + 0x7c00
call printString

keyboardPress:
    mov ah, $0
    int 0x16 ; Call Interrupt 0x16 (Keyboard)
    mov al, ah
    call printHex
    mov al, 0x20
    call printChar
    jmp keyboardPress

kernelPanic:
    call clearScreen
    mov bx, kernelPanicMessage + 0x7c00
    call printString
    hlt
    jmp $-1

clearScreen:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    ret

printChar:
    mov ah, 0x0e
    int 0x10 ; Call Interrupt 0x10 (Write Character)
    ret

printHex:
    movzx dx, al
    mov bx, dx
    shr bx, $4
    add bx, hexTable + 0x7c00
    mov al, [bx]
    call printChar
    mov bx, dx
    and bx, $15
    add bx, hexTable + 0x7c00
    mov al, [bx] ; Set Character to write to defrence of bx register
    call printChar
    ret

printNewLine:
    mov al, 10
    call printChar
    mov al, 13
    call printChar
0xb8000
printString:
    cmp byte [bx], $0
    je return
    mov al, [bx]
    call printChar
    inc bx
    jmp printString

return:
    ret

hexTable:
    db "0123456789ABCDEF", 0

welcomeMesssage:
    db "Welcome to Doors", 10, 13, "Fuck You!", 0

kernelPanicMessage:
    db "Kernel Panick.", 0

commandLineExample:
    db "> ", 0

times 510-($-$$) db 0
db 0x55, 0xaa