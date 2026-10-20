# Linux x86-64 syscall numbers

These numbers are for the native **Linux x86-64** syscall interface, not
32-bit x86, ARM64, Windows, macOS, or the x32 ABI.

Linux assigns each operation a number. Put that number in `rax`, supply its
arguments, then execute `syscall`. You cannot choose your own syscall number.
A syscall number is not an argument, a file descriptor, or an exit status.

## Start with these three

| Number (`rax`) | Name | Purpose |
|---:|---|---|
| 0 | `read` | Read bytes from a file descriptor |
| 1 | `write` | Write bytes to a file descriptor |
| 60 | `exit` | End the calling thread; ends our single-threaded exercises |

```asm
# write(1, message_address, message_length)
mov rax, 1                       # Syscall number: write
mov rdi, 1                       # Argument 1: standard output
lea rsi, [rip + message]         # Argument 2: address of bytes
mov rdx, message_end - message   # Argument 3: byte count
syscall

# exit(0)
mov rax, 60                      # Syscall number: exit
mov rdi, 0                       # Argument 1: successful exit status
syscall
```

`write` does not add a newline or detect the end of a string. It can fail or
write fewer bytes than requested; reusable code must handle those results.

## Argument registers and results

| Register | Before `syscall` |
|---|---|
| `rax` | Syscall number |
| `rdi` | Argument 1 |
| `rsi` | Argument 2 |
| `rdx` | Argument 3 |
| `r10` | Argument 4 (not `rcx`!) |
| `r8` | Argument 5 |
| `r9` | Argument 6 |

Only populate the arguments required by that syscall. Their meanings depend
on the operation: they might be numbers, addresses, lengths, or bit flags.

Afterward, `rax` holds the result. Raw syscall errors are negative error
numbers from `-1` through `-4095`. `rcx` and `r11` are overwritten by `syscall`.
An exit syscall does not return.

For ordinary file descriptors, `0` normally means standard input, `1` standard
output, and `2` standard error. These are separate from syscall numbers.

## Common operations

These are selected numbers, not a learning checklist. Do not call an unfamiliar
syscall just by changing `rax`: its required arguments will be different.

| Number | Name | Purpose |
|---:|---|---|
| 2 | `open` | Open a file; `openat` is a newer alternative |
| 3 | `close` | Close a file descriptor |
| 8 | `lseek` | Change a file's current offset |
| 9 | `mmap` | Map memory |
| 10 | `mprotect` | Change memory protection |
| 11 | `munmap` | Unmap memory |
| 12 | `brk` | Adjust the process's program break |
| 16 | `ioctl` | Device-specific control operations |
| 22 | `pipe` | Create a pipe |
| 32 | `dup` | Duplicate a file descriptor |
| 33 | `dup2` | Duplicate onto a specified descriptor |
| 35 | `nanosleep` | Sleep for a requested duration |
| 39 | `getpid` | Get the process ID |
| 41 | `socket` | Create a communication endpoint |
| 42 | `connect` | Connect a socket |
| 43 | `accept` | Accept a socket connection |
| 49 | `bind` | Assign a socket's local address |
| 50 | `listen` | Mark a socket as accepting connections |
| 56 | `clone` | Create a task with configurable resource sharing |
| 57 | `fork` | Create a child process |
| 59 | `execve` | Replace the process's program |
| 60 | `exit` | End the calling thread |
| 61 | `wait4` | Wait for a child process |
| 62 | `kill` | Send a signal |
| 63 | `uname` | Get system identification |
| 67 | `shmdt` | Detach a System V shared-memory mapping; NOT exit |
| 74 | `fsync` | Request synchronization of file data and metadata to storage |
| 79 | `getcwd` | Get the current directory |
| 80 | `chdir` | Change the current directory |
| 83 | `mkdir` | Create a directory |
| 87 | `unlink` | Remove a filesystem name |
| 202 | `futex` | Low-level synchronization operations |
| 228 | `clock_gettime` | Read a specified clock |
| 231 | `exit_group` | End all threads in the process |
| 257 | `openat` | Open a file relative to a directory descriptor |
| 318 | `getrandom` | Obtain random bytes |

A number appearing in headers does not guarantee a running kernel supports it.
New syscalls may need a newer kernel; security policies can also restrict them.

## Complete local number list

See [linux-x86-64-syscall-numbers.md](linux-x86-64-syscall-numbers.md) for all
number/name pairs from this machine's installed native x86-64 syscall header.
It is a snapshot, not a promise to include future kernel additions.

## Where to look up arguments

- Local numbers: `/usr/include/x86_64-linux-gnu/asm/unistd_64.h`
- Linux syscall calling conventions: https://man7.org/linux/man-pages/man2/syscall.2.html
- Syscall index: https://man7.org/linux/man-pages/man2/syscalls.2.html
- Example: https://man7.org/linux/man-pages/man2/write.2.html
- If installed, run `man 2 write`, `man 2 read`, or `man 2 mmap`.

Manual pages usually show C-like signatures to describe argument order and types.
That does not require us to write C. Watch for documented differences between
C library wrappers and raw kernel syscalls, particularly for `brk`, `clone`,
and exit behavior.
