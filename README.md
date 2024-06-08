# Implementation-of-Compilers
Comprehensive assignments as a part of Implementation of Programming Languages Lab. Built a compiler from scratch implementing C like functionality

* **Assignment 1** : Solving some basic coding questions based on Assembly Language Programming using NASM. 
* **Assignment 2** : A C program that implements a 2 pass Assembler with a given instruction set.

Across a series of four assignments, our objective is to construct a compiler for a C-like language, focusing on a manageable subset known as nanoC. This subset retains the essential aspects of C while ensuring feasibility. The compiler's implementation is divided into the following four assignments:

* **Assignment 3** - Lexical Analyzer: In this phase, we create a lexical analyzer for nanoC using the Flex tool. We define the lexical grammar specification to enable the identification and extraction of tokens from the source code.

* **Assignment 4** - Parser: The parser for nanoC is developed using Bison. This phase involves constructing a syntax analyzer based on the phase structure grammar outlined in Assignment 3. The parser's role is to validate the arrangement of tokens and determine the correctness of the code's structure.

* **Assignment 5** - Machine-Independent Code Generator: Syntax-directed translation is employed with Bison to generate machine-independent code for nanoC. This code generation phase produces Three-Address Code (TAC) as an intermediate representation. TAC serves as an intermediary step before generating the actual target code.

* **Assignment 6** - Target Code Generator: In this final assignment, we implement the target code generator for nanoC. The generator utilizes table lookup techniques to produce target code specifically tailored for the x86 processor architecture. A subset of the x86 assembly language is utilized for generating the actual executable machine code.
