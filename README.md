# Somnix

An experimental compiled language exploring Ruby-inspired syntax, CPU concurrency,
and explicit GPU programming.

**Status: design and repository scaffold only. No compiler or runtime is implemented yet.**

## Proposed direction

- Static types with simple local type inference.
- Functions, conditions, loops, structs, and numerical arrays.
- A Go compiler targeting native x86-64 Linux executables.
- A small x86-64 assembly runtime for Linux, initially using OS-thread-backed tasks and typed channels.
- Explicit GPU allocation, transfers, launches, and synchronization.
- A restricted numerical subset that generates CUDA kernels.

These are initial design proposals. Full Ruby compatibility and Go-runtime parity
are outside the first version.

The initial backend will generate x86-64 assembly and use the platform assembler and linker
to produce a native Linux executable. It will not generate C or target a bytecode virtual
machine. Implementing object-file generation inside Somnix can be a later learning milestone.

## Repository layout

- `compiler/`: future compiler implementation.
- `runtime/`: future runtime implementation.
- `learnings/`: local historical learning sandbox from `insomnius` when building this language.
- `examples/`: future runnable examples.
- `docs/language-design.md`: proposed semantics and scope.
- `docs/design-examples.md`: illustrative Result handling and wait-group syntax.

The agreed error model uses `Result[Value, Error]`, `Ok`/`Err`, and `?` propagation.
Wait groups track task completion; channels carry values. Task-error reporting is
separate from waiting. These are design decisions, not implemented capabilities.

## First milestones

1. Specify a minimal grammar and semantics.
2. Implement a lexer, parser, type checker, and reference interpreter.
3. Generate x86-64 assembly and validate native execution against the interpreter.
4. Add runtime memory management and thread-backed concurrency.
5. Integrate handwritten CUDA, then restricted GPU code generation.

There are no build commands or executable examples yet. Add them alongside the implementation.
