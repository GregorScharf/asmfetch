.intel_syntax noprefix
.globl _start

.equ BUFSIZE, 19

.equ BITHACK, 10000

newline:
  .asciz "\n"
slash:
  .asciz " / "
usedmem:
  .asciz "Memory: "
path:
  .asciz "/proc/meminfo"
MiB:
  .asciz " MiB"


# rdi as argument pointer
print:
  push rbp 
  mov rbp, rsp
  sub rsp, 24
  mov QWORD PTR[rbp-24], rax
  mov QWORD PTR[rbp-16], rsi
  mov QWORD PTR[rbp-8], rdx

  call strlen
  mov rdx, rax
  add rdx, 1

  mov rax, 1 
  mov rsi, rdi
  mov rdi, 1
  syscall

  mov rax, QWORD PTR[rbp-24]
  mov rsi, QWORD PTR[rbp-16]
  mov rdx, QWORD PTR[rbp-8]

  add rsp, 24
  pop rbp
  ret


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
  mov rax, r10
  add rsp, 24
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

error:
  mov rax, 60
  mov rdi, -1
  syscall

get_cached:
  push rbp
  mov rbp, rsp
  sub rsp, 16

  mov rax, 9
  mov rdi, 0
  mov rsi, 256
  mov rdx, 3
  mov r10, 34
  mov r8, -1
  mov r9, 0
  syscall

  mov QWORD PTR [rbp-8], rax
  mov QWORD PTR [rbp-16], rax # wont get modified, used to free at the end TODO!
 
  mov rax, 2 # open /proc/meminfo
  lea rdi, path
  mov rsi, 0
  mov rdx, 0777
  syscall # rax now contains the file descriptor

  mov rdi, rax
  mov rax, 0
  mov rsi, QWORD PTR[rbp-8]
  mov rdx, 136
  syscall

  add QWORD PTR[rbp-8], 120

  mov rsi, QWORD PTR[rbp-8]
  add rsi, 16
  mov QWORD PTR [rsi], 0

  jmp get_cachedL1

 get_cachedL1:
  xor rdx, rdx
  mov rsi, QWORD PTR[rbp-8]
  mov dl, byte[rsi]
  cmp dl, 32
  je get_cachedL2

  jmp get_cached_cont1

get_cachedL2:
  xor rdx, rdx

  mov dl, 0
  mov byte [rsi], dl

  add QWORD PTR[rbp-8], 1
  jmp get_cachedL1

get_cached_cont1:

  mov rdi, QWORD PTR[rbp-8]
  add rdi, 1
  call sti

  mov rdx, 1000
  mul rdx

  add rsp, 16
  pop rbp
  ret



sysinfo:
  push rbp
  mov rbp, rsp

  lea rdi, usedmem
  call print

  sub rsp, 128 # allocate for info struct

  # call sysinfo 
  mov rax, 99
  mov rdi, rbp
  sub rdi, 112
  syscall

  add rdi, 32
  mov rax, [rdi] # total memory
  mov QWORD PTR[rbp-120], rax

  add rdi, 8
  mov rsi, [rdi] # free memory
  sub rax, rsi

  mov QWORD PTR[rbp-128], rax
  call get_cached # rdi has a char* to that memory, rax holds the byte value
  sub QWORD PTR [rbp-128], rax

  mov rax, QWORD PTR[rbp-128]
  xor rdx, rdx
  mov rbx, 1024
  div rbx
  xor rdx, rdx
  div rbx

  mov rdi, rax
  call its

  mov rdi, rax
  call print

  lea rdi, MiB
  call print

  lea rdi, slash
  call print

  mov rax, QWORD PTR[rbp-120]
  mov rbx, 1024
  xor rdx, rdx
  div rbx
  xor rdx, rdx
  div rbx

  mov rdi, rax
  call its

  mov rdi, rax
  call print

  lea rdi, MiB
  call print
  
  add rsp, 128
  pop rbp
  ret
