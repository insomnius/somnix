# Somnix language design (proposal)

Status: design only. Syntax and semantics are not implemented.

Error handling and the separation of waiting from task failures were agreed on
September 28, 2026. Examples below describe the target design, not working features.

## First version

Ruby-inspired syntax with static typing and local inference.
Numbers, booleans, variables, functions, conditions, loops, structs, and numerical arrays.
Compiler implemented in Go, emitting C linked to a small runtime.
Reference interpretation provides an independent behavior baseline.

CPU concurrency begins with OS-thread-backed tasks and bounded typed channels.
Initially restrict messages to copied scalar values and use isolated heaps.
Specify channel close behavior, task completion, cancellation, and synchronization before expanding.

## Error handling: explicit Result values

- A fallible function returns `Result[Value, Error]`.
- `Ok(value)` represents success; `Err(error)` represents failure.
- Error types may carry structured context, such as a variable name and source location.
- `operation()?` extracts a successful value or returns an error from the current function.
- The enclosing function must return a compatible `Result`. Implicit conversions between
  distinct error types are not yet specified; examples use the same error type.
- Callers handle results using `match`, or propagate errors with `?`.
- Ordinary recoverable failures use returned values, not thrown exceptions.
- Panic is separate from ordinary errors. Its runtime behavior remains to be designed.

This selects Rust-style error representation over Go-style separate return values
and Zig-style payload-free error tags. It supports contextual diagnostics and concise propagation.
The full enum syntax, exhaustiveness rules, unused-result diagnostics, and resource-cleanup
semantics still need specification before implementation.

## Waiting and communication

- `WaitGroup` tracks completion only; it does not collect or return task errors.
- `spawn(wg) do ... end` registers a task before starting it and automatically marks
  completion when the task exits. It avoids manual `add`/`done` bookkeeping.
- `wg.wait()` waits for registered work to finish. It is not a fallible task-result API,
  and is not written as `wg.wait()?`.
- Channels carry data. Bounded sends block when full; receives block when empty.
- Recoverable task errors must be handled within the task or communicated explicitly.
  Result-carrying channels or a separate error-aware task group are later design options,
  not features implied by `WaitGroup`.
- Waiting before receiving can deadlock if tasks are blocked sending into a channel
  without enough capacity. A wait group does not replace communication.

Define wait-group reuse, concurrent registration, task-start failures, cancellation,
panic behavior, and precise memory-ordering guarantees before runtime implementation.
Automatic completion must not be mistaken for recovery from a process-ending panic.

See [illustrative design examples](design-examples.md).

GPU access begins with explicit allocation, upload, launch, wait, and download.
Integrate handwritten CUDA first, then emit CUDA for a restricted numeric subset.
No heap allocation, arbitrary objects, channels, or garbage collection inside GPU kernels initially.
Reject unsupported operations clearly. Buffer destruction must account for in-flight GPU operations.

## Later directions

Lightweight tasks, richer types, closures, LLVM, improved collectors, kernel optimizations.
Full Ruby compatibility and Go-runtime parity are not first-version goals.

## Decision record template

Problem / alternatives / chosen behavior / rationale / test evidence / limitations.
