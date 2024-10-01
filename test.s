.intel_syntax noprefix
.globl _start

.include "string.s"

str1:
  .asciz "mm hello\0"

str2:
  .asciz " hello\0"


_start:

  lea rdi, str1
  lea rsi, str2
  call searchstr


  mov rax, 60
  mov rdi, 0
  syscall
