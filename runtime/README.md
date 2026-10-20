# Runtime

Planned implementation language: x86-64 assembly, targeting Linux. This favors learning
calling conventions, Linux syscalls, memory management, and synchronization directly,
at the cost of more implementation and debugging work than a C runtime.

Compiler output is assembly generated from Somnix programs. The runtime is separately
written assembly providing shared support such as allocation, task spawning, and channels.
Both are assembled into machine code and linked into the native executable; no C runtime
implementation is planned. External libraries, including CUDA, may still be dependencies.

## Build plan

Initially, each program build will assemble both the generated program assembly and
handwritten runtime assembly into object files, then link them into one executable.
Rebuilding the runtime each time keeps the build process explicit and easy to learn.

In a later iteration, build the runtime separately and reuse its object files (or a
static library), rebuilding them only when runtime sources or build settings change.
This changes the build process, not the language semantics.

## Implementation order

Start with process entry/exit and output, then memory allocation. Initial concurrency
uses OS-thread-backed tasks. Concurrent garbage collection and a production
lightweight-task scheduler are later work.
No runtime is implemented yet.
