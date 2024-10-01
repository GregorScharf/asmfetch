.ifndef _TYPE_CONVERSIONS_S
.set _TYPE_CONVERSIONS_S, 1

.globl its
.globl sti

.equ BUFSIZE, 19
.equ BITHACK, 10000
.include "utils.s"
.include "string.s"

# rdi is an unsigned long as the argument
its:
  push rbp
  mov rbp, rsp

  sub rsp, 72 # 24 because proper stack allignment
  mov QWORD PTR [rbp - 8], rdi
  mov QWORD PTR [rbp - 24], rsi
  mov QWORD PTR [rbp - 32], r8 
  mov QWORD PTR [rbp - 40], r10
  mov QWORD PTR [rbp - 48], rdx
  mov QWORD PTR [rbp - 56], r9
  mov QWORD PTR [rbp - 64], rbx


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

  mov rbx, BUFSIZE # i = BUFSIZE -1

  jmp itsL1

itsL1:
  xor rax, rax
  xor rdx, rdx
  mov rax, QWORD PTR [rbp - 8] #
  mov rcx, 10                  #
  div rcx                      #
  add dl, 48                   #


  mov rdi, r10                 # str[i] = result from the above
  add rdi, rbx                 #
  mov byte [rdi], dl           #
  sub rbx, 1                   # i--

  mov QWORD PTR [rbp-8], rax  # x /= 10
  cmp rax, 0
  je its_fixoffset

  cmp rbx, 0
  jne itsL1

  jmp its_fixoffset

leave_its: 
  mov rdi, QWORD PTR [rbp - 8]
  mov rsi, QWORD PTR [rbp - 24]
  mov r8, QWORD PTR [rbp - 32]
  mov rdx, QWORD PTR [rbp - 48]
  mov r9, QWORD PTR [rbp - 56]
  mov rbx, QWORD PTR [rbp - 64]


  mov rax, r10
  mov r10, QWORD PTR [rbp - 40]
  add rsp, 72
  pop rbp
  ret

its_fixoffset:
  xor rdx, rdx
  mov dl, byte[r10]
  cmp dl, 0
  je its_fixoffsetL1

  add r10, 1
  jmp leave_its

its_fixoffsetL1:
  add r10, 1
  jmp its_fixoffset


# rdi is the char* argument
sti:
  push rbp
  mov rbp, rsp
  sub rsp, 40 # 40 + 8 from rbp, 8 bytes wasted
  call strlen
  sub rax, 2

  cmp rax, 17
  jae error

  mov QWORD PTR [rbp - 8], rax
  mov QWORD PTR [rbp - 16], 0 # result value = 0
  mov QWORD PTR [rbp - 24], 0 # long expo = 0
  mov QWORD PTR [rbp - 32], 0 # long i = 0
  mov QWORD PTR [rbp - 40], rdi #save pointer to stack
  jmp stiL1

stiL1:
  cmp QWORD PTR [rbp-32], rax
  jle stiL2
  
  mov QWORD PTR [rbp-24], 0
  mov QWORD PTR [rbp-32], rax # i = length of str - 1
  add QWORD PTR [rbp-32], BITHACK
  jmp cont_sti

stiL2:
  mov rsi, rdi
  add rsi, QWORD PTR[rbp-32] # str[i]
  mov dl, byte [rsi]
  cmp dl, 47
  jle error

  cmp dl, 58
  jae error

  add QWORD PTR[rbp-32], 1
  jmp stiL1

cont_sti:
  cmp QWORD PTR [rbp-32], BITHACK-1 # i >= 0
  jae stiL3

  jmp leave_sti

stiL3:
  xor rdx, rdx

  mov rsi, QWORD PTR [rbp - 40]
  sub QWORD PTR[rbp-32], BITHACK
  add rsi, QWORD PTR [rbp - 32]
  add QWORD PTR[rbp-32], BITHACK
  mov dl, byte[rsi]
  sub dl, 48

  mov rdi, 10
  mov rsi, QWORD PTR[rbp-24]
  call pow

  mov rsi, rax
  mov rax, rdx # (u64)dl
  xor rdx, rdx
  mul rsi

  add QWORD PTR[rbp-16], rax

  sub QWORD PTR [rbp-32], 1 # i--;
  add QWORD PTR [rbp-24], 1 # expo++;

  jmp cont_sti

leave_sti:
  mov rax, QWORD PTR[rbp-16]
  add rsp, 40
  pop rbp
  ret

.endif
