.intel_syntax noprefix

.section .rodata
message:
    .ascii "Hello, Somnix!\n"
message_end:

.section .text
.global _start

_start:
    call put
    call put

    mov rax, 60
    mov rdi, 0
    syscall

put:
    mov rax, 1
    mov rdi, 1
    lea rsi, [rip + message]
    mov rdx, message_end - message
    syscall

    ret

.section .note.GNU-stack,"",@progbits
