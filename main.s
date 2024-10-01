.intel_syntax noprefix
.globl _start

.include "type_conversions.s"


newline:
  .asciz "\n"
slash:
  .asciz " / "
usedmem:
  .asciz "Memory: "
path:
  .asciz "/proc/meminfo"
cpu_path:
  .asciz "/proc/cpuinfo"
MiB:
  .asciz " MiB"
Uptime:
  .asciz "Uptime: "
Hours:
  .asciz "h "
Minutes:
  .asciz "m "
Kernel:
  .asciz "Kernel: "
OS:
  .asciz "OS: "
Space:
  .asciz " "
model_name:
  .asciz "model name"

_start:
  call getmem
  call uptime
  call get_kernel
  call get_cpu
  mov rax, 60
  mov rdi, 0
  syscall


get_cpu:
  push rbp
  mov rbp, rsp
  
  sub rsp, 24

  
  mov rax, 9
  mov rdi, 0
  mov rsi, 256 
  mov rdx, 3
  mov r10, 34
  mov r8, -1
  mov r9, 0
  syscall

  mov QWORD PTR [rbp-8], rax
  mov QWORD PTR [rbp-16], rax

  mov rax, 2
  lea rdi, cpu_path
  mov rsi, 0
  mov rdx, 0777
  syscall

  mov rdi, rax
  mov rax, 0
  mov rsi, QWORD PTR [rbp-8]
  mov rdx, 255
  syscall

  mov rdi, rsi
  lea rsi, model_name
  call searchstr

  mov rdi, QWORD PTR [rbp-8]
  call print

  add rsp, 24

  pop rbp
  ret

uptime:
  push rbp
  mov rbp, rsp
  sub rsp, 112

  mov rax, 99
  mov rdi, rbp
  sub rdi, 112
  syscall

  mov rax, [rdi]
  xor rdx, rdx
  mov rbx, 3600
  div rbx
  
  mov rdi, rax
  call its

  lea rdi, newline
  call print

  lea rdi, Uptime
  call print

  mov rdi, rax
  call print

  lea rdi, Hours
  call print

  mov rax, rdx
  xor rdx, rdx
  mov rbx, 60
  div rbx
  mov rdi, rax
  call its

  mov rdi, rax
  call print

  lea rdi, Minutes
  call print

  lea rdi, newline
  call print

  add rsp, 112
  pop rbp
  ret

get_kernel:
  push rbp
  mov rbp, rsp
  sub rsp, 390
 
  lea rdi, Kernel
  call print

  mov rax, 63
  mov rdi, rbp
  sub rdi, 390
  syscall

  mov rsi, rdi
  add rdi, 130
  call print
  sub rdi, 130

  lea rdi, newline
  call print

  lea rdi, OS
  call print

  mov rdi, rsi
  add rdi, 65
  call print
  sub rdi, 65

  add rdi, 195
  call getVersion

  lea rdi, Space
  call print

  mov rdi, rax
  call print

  lea rdi, newline
  call print

  add rsp, 390
  pop rbp
  ret

getVersion:
  push rbp
  mov rbp, rsp
  sub rsp, 40
  mov QWORD PTR [rbp-8], 0
  mov QWORD PTR [rbp-16], 0

  jmp getVersionL1

getVersionL1:
  xor rdx, rdx
  mov dl, byte[rdi]
  cmp dl, 126
  jne getVersionL2

  jmp getVersionL3

getVersionL2:
  add rdi, 1
  jmp getVersionL1

getVersionL3:
  add QWORD PTR [rbp-8], 1

  add rdi, 1
  cmp QWORD PTR [rbp-8], 2
  jne getVersionL1

  add rdi, 1
  mov QWORD PTR [rbp-16], rdi
  jmp getVersionL4

getVersionL4:
  xor rdx, rdx
  mov dl, byte[rdi]
  cmp dl, 126
  jne getVersionL5
  
  mov dl, 0
  mov byte [rdi], dl
  mov rax, QWORD PTR [rbp-16]

  add rsp, 40
  pop rbp
  ret

getVersionL5:
  add rdi, 1
  jmp getVersionL4
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
  mov QWORD PTR [rbp-16], rax # wont get modified, used to free at the end
 
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
  mov QWORD PTR [rbp-8], rax

  mov rax, 11
  mov rdi, QWORD PTR [rbp-16]
  mov rsi, 256
  syscall

  mov rax, QWORD PTR [rbp-8]
  
  
  add rsp, 16
  pop rbp
  ret



getmem:
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


