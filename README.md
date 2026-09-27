# Somnix

An experimental compiled language exploring Ruby-inspired syntax, CPU concurrency,
and explicit GPU programming.

**Status: design and repository scaffold only. No compiler or runtime is implemented yet.**

## Proposed direction

- Static types with simple local type inference.
- Functions, conditions, loops, structs, and numerical arrays.
- A Go compiler generating C for native executables.
- A small C runtime, initially using OS-thread-backed tasks and typed channels.
- Explicit GPU allocation, transfers, launches, and synchronization.
- A restricted numerical subset that generates CUDA kernels.

These are initial design proposals. Full Ruby compatibility and Go-runtime parity
are outside the first version.

## Repository layout

- `compiler/`: future compiler implementation.
- `runtime/`: future runtime implementation.
- `examples/`: future runnable examples.
- `docs/language-design.md`: proposed semantics and scope.

## First milestones

1. Specify a minimal grammar and semantics.
2. Implement a lexer, parser, type checker, and reference interpreter.
3. Generate C and validate native execution against the interpreter.
4. Add runtime memory management and thread-backed concurrency.
5. Integrate handwritten CUDA, then restricted GPU code generation.

There are no build commands or executable examples yet. Add them alongside the implementation.
