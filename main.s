.intel_syntax noprefix
.globl _start

.equ BUFSIZE, 19

newline:
  .asciz "\n"
slash:
  .asciz " / "
usedmem:
  .asciz "Used memory : "
path:
  .asciz "/proc/meminfo"

  # TODO: write a string to unsigned int function

_start:
  call sysinfo

  mov rax, 60
  mov rdi, 0
  syscall

empty:
  push rbp
  pop rbp
  ret

memset:
  mov rdx, rax
  add rdx, rsi
  mov byte [rdx], rdi

  sub rsi, 1 # decrement the counter 
  cmp rsi, 0 # if not 0 
  jne memset # repeat

  # return
  ret

# rdi is an unsigned long as the argument
# rax contains 
its:
  push rbp
  mov rbp, rsp

  sub rsp, 24 # 24 because proper stack allignment
  mov QWORD PTR [rbp - 8], rdi


  mov rsi, BUFSIZE
  mov rax, 9
  mov rdi, 0
  mov rdx, 3
  mov r10, 34
  mov r8, -1
  mov r9, 0
  syscall
  mov QWORD PTR [rbp-16], rax
  mov r10, rax

  mov rdi, 0
  mov rsi, BUFSIZE
  sub rsi, 1
  call memset

  mov rbx, BUFSIZE # i = BUFSIZE -1

  jmp L1

  # loop
  mov rax, r10
  add rsp, 24
  pop rbp
  ret

L1:
  xor rax, rax
  xor rdx, rdx
  mov rax, QWORD PTR [rbp - 8] #
  mov rcx, 10                  #
  div rcx                      #
  add edx, 48                  #


  mov rdi, r10                 # str[i] = result from the above
  add rdi, rbx                 # 
  mov byte [rdi], dl           #
  sub rbx, 1                   # i--

  mov QWORD PTR [rbp-8], rax  # x /= 10
 
  cmp rax, 0
  je its+102

  cmp rbx, 0
  jne L1

  jmp its+102 #magic value determined by testing and changing until it works

sysinfo:
  push rbp
  mov rbp, rsp

  mov rax, 1
  mov rdi, 1
  lea rsi, usedmem
  mov rdx, 15
  syscall


  sub rsp, 128 # allocate for info struct
  # call sysinfo 
  mov rax, 99
  mov rdi, rbp
  sub rdi, 128
  syscall

  add rdi, 32
  mov rax, [rdi] # total memory
  add rdi, 8
  mov rsi, [rdi] # free memory
  add rdi, 24
  mov rdx, [rdi] # total swap memory

  sub rax, rsi
  sub rax, rdx

  xor rdx, rdx
  mov rsi, 1024
  div rsi
  div rsi

  mov rdi, rax
  call its
  
  mov rsi, rax
  mov rax, 1
  mov rdi, 1
  mov rdx, BUFSIZE+2
  syscall

  mov rax, 1
  mov rdi, 1
  lea rsi, slash
  mov rdx, 3
  syscall

  mov rsi, rbp
  sub rsi, 128
  add rsi, 32
  mov rax, [rsi]
  xor rdx, rdx
  mov rsi, 1024
  div rsi
  div rsi
  mov rdi, rax

  call its

  mov rsi, rax
  mov rax, 1
  mov rdi, 1
  mov rdx, BUFSIZE + 2
  syscall

  mov rax, 1
  mov rdi, 1
  lea rsi, newline
  mov rdx, 1
  syscall

  mov rsi, rbp
  sub rsi, 128
  
  mov rdi, [rsi]
  call its

  mov rsi, rax
  mov rax, 1
  mov rdi, 1
  mov rdx, BUFSIZE+2
  syscall 
  mov rax, 1
  mov rdi, 1
  lea rsi, newline
  mov rdx, 1
  syscall

  
  mov rsi, 256
  mov rax, 9
  mov rdi, 0
  mov rdx, 3
  mov r10, 34
  mov r8, -1
  mov r9, 0
  syscall
  mov QWORD PTR[rbp - 120], rax

  mov rax, 2
  lea rdi, path
  mov rsi, 0
  mov rdx, 0777
  syscall

  mov rdi, rax
  mov rax, 0
  mov rsi, QWORD PTR [rbp-120]
  mov rdx, 142
  syscall

  add QWORD PTR[rbp-120], 129

  mov rax, 1
  mov rdi, 1
  mov rsi, QWORD PTR[rbp-120]
  mov rdx, 255
  syscall

  add rsp, 128
  pop rbp
  ret
