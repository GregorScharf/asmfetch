.ifndef _UTILS_S
.set _UTILS_S, 1

# rdi as argument pointer
print:
  push rbp 
  mov rbp, rsp
  sub rsp, 40
  mov QWORD PTR[rbp-32], rdi
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


  mov rdi, QWORD PTR[rbp-32]
  mov rax, QWORD PTR[rbp-24]
  mov rsi, QWORD PTR[rbp-16]
  mov rdx, QWORD PTR[rbp-8]


  add rsp, 40
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



.endif


