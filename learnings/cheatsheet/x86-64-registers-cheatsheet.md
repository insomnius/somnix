# Linux x86-64 registers and syscalls

Scope: Linux on x86-64, using GNU assembler with Intel syntax. Other CPU
architectures and operating systems use different conventions.

## 1. Registers: small storage locations inside the CPU

The general-purpose registers below each hold 64 bits (8 bytes). Those bits can
represent an integer, an address, or other data. Registers do not carry type labels:
the instructions and conventions determine what their contents mean.

Most registers have no permanent job. The syscall and function-call columns below
are conventions, not restrictions on every use of that register.

| Register | Common use | Linux syscall role | System V AMD64 function-call role |
|---|---|---|---|
| `rax` | Arithmetic, results | Syscall number before; result after | Primary integer/pointer return value |
| `rbx` | General storage | No argument role | Callee preserves |
| `rcx` | General storage, some shift/count operations | Destroyed by `syscall` | Integer/pointer argument 4 |
| `rdx` | General storage, some multiply/divide operations | Argument 3 | Integer/pointer argument 3 |
| `rsi` | General storage, source pointer for string instructions | Argument 2 | Integer/pointer argument 2 |
| `rdi` | General storage, destination pointer for string instructions | Argument 1 | Integer/pointer argument 1 |
| `rbp` | Optional stack-frame base; otherwise general storage | No argument role | Callee preserves |
| `rsp` | Stack pointer: current top of the stack | Must remain a valid stack pointer | Callee restores before returning |
| `r8` | General storage | Argument 5 | Integer/pointer argument 5 |
| `r9` | General storage | Argument 6 | Integer/pointer argument 6 |
| `r10` | General storage | Argument 4 | Caller-saved temporary |
| `r11` | General storage | Destroyed by `syscall` | Caller-saved temporary |
| `r12`–`r15` | General storage | No argument role | Callee preserves |

Function-call rules here cover ordinary integer/pointer arguments. Floating-point,
vector, aggregate, and variadic arguments have additional ABI rules.

- **Callee preserves:** a function must restore the register if it changes it.
- **Caller-saved:** a function may change the register; save a needed value before calling.
- These function rules do not apply to a syscall in exactly the same way.

### Other important registers

| Register | Meaning |
|---|---|
| `rip` | Instruction pointer: locates the code being executed. RIP-relative addressing uses the address of the next instruction as its base. Not an ordinary `mov` destination. |
| `rflags` | Status/control bits, including zero, carry, sign, and overflow flags. Comparisons and arithmetic set flags; conditional jumps inspect them. |
| `xmm0`–`xmm15` | 128-bit vector registers, also used for scalar floating-point operations and floating-point arguments/results. Not syscall argument registers. |

## 2. Register sizes: different views of the same storage

| 64-bit | Low 32-bit | Low 16-bit | Low 8-bit |
|---|---|---|---|
| `rax` | `eax` | `ax` | `al` |
| `rbx` | `ebx` | `bx` | `bl` |
| `rcx` | `ecx` | `cx` | `cl` |
| `rdx` | `edx` | `dx` | `dl` |
| `rsi` | `esi` | `si` | `sil` |
| `rdi` | `edi` | `di` | `dil` |
| `rbp` | `ebp` | `bp` | `bpl` |
| `rsp` | `esp` | `sp` | `spl` |
| `r8` (through `r15`) | `r8d` | `r8w` | `r8b` |

These are not separate storage locations. Writing `eax` also clears the upper
32 bits of `rax`. Writing `ax` or `al` leaves the remaining bits unchanged.
Legacy high-byte names (`ah`, `bh`, `ch`, `dh`) also exist, with encoding restrictions;
avoid them while learning.

## 3. How to make a Linux x86-64 syscall

```asm
mov rax, syscall_number
mov rdi, argument_1
mov rsi, argument_2
mov rdx, argument_3
mov r10, argument_4
mov r8,  argument_5
mov r9,  argument_6
syscall
```

This is a template, not literal code to assemble. Supply only the arguments the
selected syscall needs. You do not need to clear unused argument registers.

**Important:** syscall argument 4 uses `r10`, but ordinary function argument 4
uses `rcx`.

After a returning syscall:

- `rax` contains the result, replacing the syscall number.
- Raw Linux syscall errors are negative error numbers in `rax` (`-1` through `-4095`).
  This differs from C library wrappers, which generally return `-1` and set `errno`.
- `rcx` and `r11` are overwritten by `syscall`; do not keep needed values there.
- `exit` does not return.

## 4. Input variations: the syscall determines the meaning

The same number has different meanings in different argument positions. Register
values can be numbers, addresses, bit flags, or special constants, depending on
the selected syscall.

Common **Linux x86-64** syscall numbers:

| Syscall | `rax` before | `rdi` | `rsi` | `rdx` | Additional arguments | Success result in `rax` |
|---|---:|---|---|---|---|---|
| `read` | 0 | File descriptor | Writable buffer address | Maximum byte count | None | Bytes read; 0 means end of file for ordinary files/pipes |
| `write` | 1 | File descriptor | Data address | Byte count | None | Bytes written; may be fewer than requested |
| `close` | 3 | File descriptor | Unused | Unused | None | 0 |
| `mmap` | 9 | Address hint, often 0 | Length in bytes | Protection flags | `r10`: mapping flags; `r8`: file descriptor; `r9`: byte offset | Mapping address |
| `munmap` | 11 | Mapping address | Length in bytes | Unused | None | 0 |
| `exit` | 60 | Exit status | Unused | Unused | None | Does not return |
| `exit_group` | 231 | Exit status | Unused | Unused | None | Does not return |

`exit` ends the calling thread; in our single-threaded example that ends the
program. `exit_group` ends all threads in the process.

### File descriptors: which input/output destination?

A file descriptor is a small integer identifying an open stream or file. Normally:

| Value | Name | Typical connection |
|---:|---|---|
| 0 | Standard input (`stdin`) | Terminal input |
| 1 | Standard output (`stdout`) | Terminal output |
| 2 | Standard error (`stderr`) | Terminal diagnostics |

Shell redirection can change those connections. `write` writes bytes to a file
descriptor; it is not inherently a terminal-printing operation.

### Memory input: address versus contents

```asm
mov rdi, 1                    # A literal integer: standard output
lea rsi, [rip + message]      # Address of bytes, not the bytes themselves
mov rdx, message_end - message # Length calculated by the assembler
```

`write` has no automatic string-end detection and does not add a newline. The
length counts **bytes**, not necessarily visible characters. Non-ASCII text can
use multiple bytes per character.

### Flags: multiple choices packed into one number

Some syscalls accept bit flags instead of a single choice. For example, `mmap`
protection flags include `PROT_READ = 1` and `PROT_WRITE = 2`. Combining them with
bitwise OR gives `3`, requesting both read and write access. Mapping also needs
other valid arguments; setting protection alone is not a complete `mmap` request.

## 5. Instructions used in our greeting

Registers are storage locations; instructions such as `mov` and `lea` tell the
CPU what to do with them. Intel syntax generally puts the destination first.

| Instruction | Meaning | Example |
|---|---|---|
| `mov` | Copy a value into a register or memory location; the source is not erased | `mov rax, 1` puts 1 into `rax` |
| `lea` | Load Effective Address: calculate an address without reading memory there | `lea rsi, [rip + message]` puts the message's address into `rsi` |
| `syscall` | Enter the kernel using the prepared syscall number and arguments | `syscall` requests the operation selected by `rax` |

### `lea` versus `mov`: address versus contents

```asm
lea rsi, [rip + message]  # Address of message
mov rsi, [rip + message]  # Read 8 bytes from message into rsi
```

If `message` starts at address `0x402000`, the first instruction puts `0x402000`
into `rsi`. The second reads the bytes stored there instead. It reads 8 bytes
because `rsi` is a 64-bit destination.

Brackets describe a memory-address expression. `lea` is special: it calculates
that address without accessing the memory contents. It can also calculate
arithmetic expressions, for example `lea rax, [rdi + rdi*2]` computes `rdi * 3`
without reading memory or changing arithmetic flags.

In GNU assembler's `[rip + message]` notation, the assembler/linker calculates
a displacement from the next instruction to the label. It does not literally
add the label's absolute address to `rip`.

## 6. Our greeting, decoded

```asm
# Request: write(1, address_of_message, message_length)
mov rax, 1                        # Operation: write
mov rdi, 1                        # Argument 1: standard output
lea rsi, [rip + message]          # Argument 2: text address
mov rdx, message_end - message    # Argument 3: text length
syscall                           # Submit the request

# Request: exit(0)
mov rax, 60                       # Operation: exit
mov rdi, 0                        # Argument 1: success status
syscall                           # Ends this single-threaded program
```

Our first exercise assumes the whole write succeeds. A reusable runtime must
check errors and handle partial writes rather than assuming success.

## 7. Small experiments

Rebuild after each change, and restore the original afterward:

1. Set the write length to `5`: prints `Hello` with no newline.
2. Set the write destination to `2`: prints to standard error instead.
3. Set the exit status to `42`: run the executable directly, then immediately
   run `echo $?` to see `42`. Do not use `make run` for this status check: Make
   treats a nonzero recipe status as failure and returns its own status.

## References

- System V AMD64 ABI (ordinary function calls): https://gitlab.com/x86-psABIs/x86-64-ABI
- Linux syscall conventions: https://man7.org/linux/man-pages/man2/syscall.2.html
- Write arguments and behavior: https://man7.org/linux/man-pages/man2/write.2.html
- Exit behavior: https://man7.org/linux/man-pages/man2/exit.2.html
- On systems with the manual pages installed: `man 2 write`, `man 2 read`,
  `man 2 mmap`, and `man 2 syscall`. C-like signatures in those pages describe
  the arguments; our assembly supplies them using the raw syscall convention.
