INF		equ	20000000

        section .text
        global sztokfisz

sztokfisz:                      ; rdi - balls, rsi - bitmap, rdx - h, rcx - w, r8 - count
        push rbp
        push rbx
        mov rbp, rsp
        mov [spheres], rdi
        mov [count], r8
        mov rbx, rsi            ; first bitmap cell address
        mov r10, rdx            ; height
        mov r11, rcx            ; width
        mov rcx, 0
row_loop:
        cmp rcx, r10
        je row_done
        mov rdx, 0
col_loop:
        cmp rdx, r11
        je col_done
        mov rdi, rcx            ; x coordinate
        mov rsi, rdx            ; y coordinate
        call count_color
        mov [rbx], eax
        inc rdx
        inc rbx                 ; next bitmap cell
        jmp col_loop
col_done:
        inc rcx
        jmp row_loop
row_done:
        pop rbx
        pop rbp
        ret

; -----------------------------------------------------------------------------

count_color:                          ; rdi - x, rsi - y
        push rbp
        mov rbp, rsp
        push rcx
        push rdx
        mov rdx, [spheres]
        mov rcx, [count]
		mov rax, INF
        cvtsi2ss xmm3, rax            ; z coordinate of nearest ball
        mov r8d, 0                    ; color of nearest ball
sphere_loop:
        mov r9, [rdx]
        cvtsi2ss xmm0, rdi            ; xmm0 = x
        cvtsi2ss xmm1, dword [r9]     ; xmm1 = x0
        subss xmm0, xmm1              ; xmm0 = x - x0
        mulss xmm0, xmm0              ; xmm0 = (x - x0)^2
        cvtsi2ss xmm1, rsi            ; xmm1 = y
        cvtsi2ss xmm2, dword [r9+4]   ; xmm2 = y0
        subss xmm1, xmm2              ; xmm1 = y - y0
        mulss xmm1, xmm1              ; xmm1 = (y - y0)^2
        addss xmm0, xmm1              ; xmm0 = (x - x0)^2 + (y - y0)^2
        sqrtss xmm0, xmm0             ; xmm0 = d = sqrt ((x - x0)^2 + (y - y0)^2)
        cvtsi2ss xmm1, dword [r9+12]  ; xmm1 = r
        movss xmm4, xmm0              ; xmm4 = d
        cmpless xmm0, xmm1
        movmskps eax, xmm0
        cmp eax, 0
        je next_sphere                ; if distance 'd' is greater than r
        mulss xmm1, xmm1              ; xmm1 = r^2
        subss xmm1, xmm4              ; xmm1 = r^2 - d 
        sqrtss xmm1, xmm1             ; xmm1 = sqrt (r^2 - d)
        cvtsi2ss xmm0, dword [r9+8]   ; xmm0 = z0
        subss xmm0, xmm1              ; xmm0 = z = z0 - sqrt (r^2 - d)
        movss xmm4, xmm0              ; xmm4 = z
        cmpless xmm4, xmm3
        movmskps eax, xmm4
        cmp eax, 0
        je next_sphere                ; if min < z
        movss xmm3, xmm0              ; min = z
        mov r8b, byte [r9+16]         ; set new color
next_sphere:
        add rdx, 8
        loop sphere_loop
        mov eax, r8d
        pop rdx
        pop rcx
        pop rbp
        ret

; -----------------------------------------------------------------------------

        section .bss
spheres resb 8
count   resb 8
