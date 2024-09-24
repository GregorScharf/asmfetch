.intel_syntax noprefix
.globl _start

.extern  malloc

my_memset:
        push    rbp
        mov     rbp, rsp
        mov     QWORD PTR [rbp-8], rdi
        mov     eax, esi
        mov     DWORD PTR [rbp-16], edx
        mov     BYTE PTR [rbp-12], al
        jmp     .L2
.L3:
        mov     eax, DWORD PTR [rbp-16]
        movsx   rdx, eax
        mov     rax, QWORD PTR [rbp-8]
        add     rdx, rax
        movzx   eax, BYTE PTR [rbp-12]
        mov     BYTE PTR [rdx], al
        sub     DWORD PTR [rbp-16], 1
.L2:
        cmp     DWORD PTR [rbp-16], 0
        jne     .L3
        nop
        nop
        pop     rbp
        ret
intToStr:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 32
        mov     QWORD PTR [rbp-24], rdi
        mov     edi, 19
        call    malloc
        mov     QWORD PTR [rbp-16], rax
        mov     rax, QWORD PTR [rbp-16]
        mov     edx, 19
        mov     esi, 32
        mov     rdi, rax
        call    my_memset
        mov     DWORD PTR [rbp-4], 18
.L5:
        mov     rcx, QWORD PTR [rbp-24]
        movabs  rdx, -3689348814741910323
        mov     rax, rcx
        mul     rdx
        shr     rdx, 3
        mov     rax, rdx
        sal     rax, 2
        add     rax, rdx
        add     rax, rax
        sub     rcx, rax
        mov     rdx, rcx
        mov     eax, edx
        lea     ecx, [rax+48]
        mov     eax, DWORD PTR [rbp-4]
        movsx   rdx, eax
        mov     rax, QWORD PTR [rbp-16]
        add     rax, rdx
        mov     edx, ecx
        mov     BYTE PTR [rax], dl
        sub     DWORD PTR [rbp-4], 1
        mov     rax, QWORD PTR [rbp-24]
        movabs  rdx, -3689348814741910323
        mul     rdx
        mov     rax, rdx
        shr     rax, 3
        mov     QWORD PTR [rbp-24], rax
        cmp     QWORD PTR [rbp-24], 0
        jne     .L5
        mov     rax, QWORD PTR [rbp-16]
        leave
        ret
_start:
        push    rbp
        mov     rbp, rsp
        mov     edi, 12
        call    intToStr
        mov     eax, 0
        pop     rbp
        ret
