.intel_syntax noprefix

.section .rodata
message:
    .ascii "Hello, Somnix!\nSo this is actually my first assembly compilations,\nlets start build something great!\n"
message_end:

.section .text
.global _start

_start:
    mov rax, 1
    mov rdi, 1
    lea rsi, [rip + message]
    mov rdx, message_end - message
    syscall

    mov rax, 60
    mov rdi, 0
    syscall

.section .note.GNU-stack,"",@progbits
