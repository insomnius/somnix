# Somnix language design (proposal)

Status: design only. Syntax and semantics are not implemented.

## First version

Ruby-inspired syntax with static typing and local inference.
Numbers, booleans, variables, functions, conditions, loops, structs, and numerical arrays.
Compiler implemented in Go, emitting C linked to a small runtime.
Reference interpretation provides an independent behavior baseline.

CPU concurrency begins with OS-thread-backed tasks and bounded typed channels.
Initially restrict messages to copied scalar values and use isolated heaps.
Specify channel close behavior, task completion, cancellation, and synchronization before expanding.

GPU access begins with explicit allocation, upload, launch, wait, and download.
Integrate handwritten CUDA first, then emit CUDA for a restricted numeric subset.
No heap allocation, arbitrary objects, channels, or garbage collection inside GPU kernels initially.
Reject unsupported operations clearly. Buffer destruction must account for in-flight GPU operations.

## Later directions

Lightweight tasks, richer types, closures, LLVM, improved collectors, kernel optimizations.
Full Ruby compatibility and Go-runtime parity are not first-version goals.

## Decision record template

Problem / alternatives / chosen behavior / rationale / test evidence / limitations.
