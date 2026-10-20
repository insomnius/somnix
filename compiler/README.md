# Compiler

Planned implementation language: Go. Initial target: x86-64 Linux.

The native backend will generate x86-64 assembly, then use the platform assembler and linker
to produce a Linux executable. Somnix will not generate C or run on a bytecode virtual machine.
An assembler/object writer implemented in Somnix may replace the external assembler in a later
milestone.

No compiler is implemented yet.
