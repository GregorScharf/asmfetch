.intel_syntax noprefix
.globl _start

.equ BUFSIZE, 19

.equ BITHACK, 10000

newline:
  .asciz "\n"
slash:
  .asciz " / "
usedmem:
  .asciz "Used memory : "
path:
  .asciz "/proc/meminfo"

# rdi is the base
# rsi is the exponent
pow:
  push rbp
  mov rbp, rsp
  sub rsp, 24
  mov QWORD PTR[rbp-8], rdi
  mov QWORD PTR [rbp- 16], 0
  mov QWORD PTR[rbp-24], rdx
  mov rax, rdi
  sub rsi, 1
  jmp powL1

powL1:
  cmp QWORD PTR[rbp-16], rsi
  jle powL2

  jmp leave_pow
  

powL2:
  mul QWORD PTR [rbp-8]
  add QWORD PTR[rbp-16], 1

  jmp powL1

leave_pow:
  xor rdx, rdx
  mov rbx, 10
  div rbx

  mov rdx, QWORD PTR[rbp-24]
  add rsi, 1

  add rsp, 24
  pop rbp
  ret


_start:
  call sysinfo

  mov rax, 60
  mov rdi, 0
  syscall

# rdi is an unsigned long as the argument
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

  mov rbx, BUFSIZE # i = BUFSIZE -1

  jmp itsL1

itsL1:
  xor rax, rax
  xor rdx, rdx
  mov rax, QWORD PTR [rbp - 8] #
  mov rcx, 10                  #
  div rcx                      #
  add rdx, 48                  #


  mov rdi, r10                 # str[i] = result from the above
  add rdi, rbx                 #
  mov byte [rdi], dl           #
  sub rbx, 1                   # i--

  mov QWORD PTR [rbp-8], rax  # x /= 10
 
  cmp rax, 0
  je leave_its

  cmp rbx, 0
  jne itsL1

  jmp leave_its

leave_its:
  mov rax, r10
  add rsp, 24
  pop rbp
  ret


# rdi is the char* argument
strlen:
  push rbp
  mov rbp, rsp
  sub rsp, 8
  mov QWORD PTR[rbp -8], 0 # long n = 0
  jmp strlenL1
  

strlenL1:
  mov rsi, rdi
  add rsi, QWORD PTR[rbp-8]
  mov dl, byte[rsi]
  cmp dl, 0
  jne strlenL2

  jmp leave_strlen

leave_strlen:
  mov rax, QWORD PTR [rbp-8]
  add rsp, 8
  pop rbp
  ret
strlenL2:
  add QWORD PTR[rbp-8], 1
  jmp strlenL1

# rdi is the char* argument
sti:
  push rbp
  mov rbp, rsp
  sub rsp, 40 # 40 + 8 from rbp, 8 bytes wasted
  call strlen
  sub rax, 1

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

error:
  mov rax, 60
  mov rdi, -1
  syscall


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

  sub rax, rsi
  mov QWORD PTR[rbp-128], rax
 #########################################################
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
  mov rdx, 136
  syscall

  add QWORD PTR[rbp-120], 129

  mov rdi, QWORD PTR[rbp-120]

  call sti

  xor rdx, rdx
  mov rbx, 1000
  mul rbx
########################################################

  mov rsi, rax
  mov rax, QWORD PTR[rbp-128]
  sub rax, rsi

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

  add rsp, 128
  pop rbp
  ret
