[bits 32]
global IDT_LOAD
IDT_LOAD:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]
    lidt [eax]

    mov esp, ebp
    pop ebp
    ret

isrl:
    ret
    GLOBAL isrl