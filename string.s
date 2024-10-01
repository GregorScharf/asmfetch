
.ifndef _STRING_S
.set _STRING_S, 1


.equ str_BITHACK, 10000000

# rdi is the char* argument
strlen:
  push rbp
  mov rbp, rsp
  sub rsp, 16
  mov QWORD PTR[rbp -8], 0 # long n = 0
  mov QWORD PTR [rbp-16], rsi
  jmp strlenL1
  

strlenL1:
  mov rsi, rdi
  add rsi, QWORD PTR[rbp-8]
  mov dl, byte[rsi]
  cmp dl, 0
  jne strlenL2

  jmp leave_strlen

leave_strlen:
  mov rsi, QWORD PTR [rbp-16]
  mov rax, QWORD PTR [rbp-8]
  add rax, 1
  add rsp, 16
  pop rbp
  ret
strlenL2:
  add QWORD PTR[rbp-8], 1
  jmp strlenL1


  # arg1: rdi : char pointer
  # arg2: rsi : char pointer
  # returns position of arg2 in arg1 and return 14453223489456 if not found
searchstr:
  push rbp
  mov rbp, rsp
  sub rsp, 64

  mov QWORD PTR [rbp-64], rdx

  mov QWORD PTR [rbp - 8], rdi # save original pointers to restore at the end TODO
  mov QWORD PTR [rbp - 16], rsi

  mov rax, 14453223489456
  mov QWORD PTR [rbp-56], rax

  call strlen
  mov QWORD PTR [rbp-24], rax # get the lenghts 
  mov rdi, rsi
  call strlen
  mov QWORD PTR [rbp-32], rax # 

  mov QWORD PTR [rbp-40], 0 # i = 0
  mov QWORD PTR [rbp-48], 0 # j = 0

  # if strlen(arg2) > strlen(arg1) -> return early
  mov rax, QWORD PTR [rbp-24]
  mov rdi, QWORD PTR [rbp-32]
  cmp rax, rdi
  jl searchstr_error


  jmp searchstrL1

  add rsp, 56
  pop rbp
  ret

searchstrL1:
  mov rax, QWORD PTR [rbp-24] # i < length(arg1)
  sub rax, 1
  cmp QWORD PTR [rbp-40], rax
  jle searchstrL2

  jmp searchstr_error

searchstrL2:
  mov rdi, QWORD PTR[rbp-8]
  mov rsi, QWORD PTR[rbp-16]
  add rdi, QWORD PTR [rbp-40]
  add rsi, QWORD PTR [rbp-48]
  xor rax, rax
  xor rdx, rdx
  mov dl, byte[rdi]
  mov al, byte[rsi]
  cmp dl, al
  je searchstrL3

  jmp searchstrL4

searchstrL3:
  add QWORD PTR [rbp-40], 1 # i++
  add QWORD PTR [rbp-48], 1 # j++


  mov rdi, QWORD PTR [rbp-40] # first equal position = i - j
  sub rdi, QWORD PTR [rbp-48] # 
  mov QWORD PTR [rbp-56], rdi # 

  mov rdi, QWORD PTR [rbp-32]
  mov rsi, QWORD PTR [rbp-48]
  cmp rdi, rsi
  je searchstr_success

  jmp searchstrL1

searchstr_success:
  mov rax, QWORD PTR [rbp-56]
  mov rdi, QWORD PTR [rbp-8]
  mov rsi, QWORD PTR [rbp-16]
  mov rdx, QWORD PTR [rbp-64]
  add rsp, 64
  pop rbp
  ret

searchstrL4:
  add QWORD PTR [rbp-40], 1 # i++

  mov rax, 14453223489456
  mov QWORD PTR [rbp-56], rax

  mov rax, QWORD PTR [rbp-24]
  cmp QWORD PTR [rbp-40], rax
  jl searchstrL1

  jmp searchstr_error


searchstr_error:
  mov rax, 14453223489456 
  mov rdi, QWORD PTR [rbp-8]
  mov rsi, QWORD PTR [rbp-16]
 
  mov rdx, QWORD PTR [rbp-64]
  add rsp, 64
  pop rbp
  ret


.endif
