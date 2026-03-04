.model tiny
.code 

locals @@

; ОТДЕБАЖИТЬ ВЫВОД РАМКИ !!!!!!!!!

; подумать над названием буфера
; заносить туда строку с rx = val 
; потом печатать этот буфер
; пушить в стек все регистры, чтобы их не потерять

; чекать только рамку, а не весь экран, возможная причина поломки таймера 
org 100h

Start:
    mov ax, 3509h
	int 21h

    ; int 1Ch

	mov old09Ofs, bx
	mov bx, es
	mov old09seg, es

    mov ax, 3508h
    int 21h 

	mov old08Ofs, bx
	mov bx, es
	mov old08seg, es

    call make_save_buffer

    xor ax, ax
    mov es, ax

    mov bx, 4 * 09h

    cli
    mov es:[bx], offset My_int_9
    mov ax, cs
    mov es:[bx + 2], ax

    sub bx, 4

    mov es:[bx], offset My_int_8
    mov es:[bx + 2], ax

    sti

    int 08h
    ; int 09h
    ; mov cx, 5
    ; @@11:
    ; push cx
    ; call copy_draw_buffer
    ; pop cx
    ; loop @@11 

    mov ax, 3100h
	mov dx, offset EOP
	shr dx, 4
	inc dx
    add dx, 55
	int 21h

    mov ax, 0FBA2h
    mov bx, 3346h

My_int_9 proc
    push ax bx es ds

    push sp
    push ax 
    push bx
    push cx
    push si 
    push di     
    push bp 
    push ds     
    push es 
    push ss 
    push cs 
    
    xor ax, ax ;!!!!!!!!!  

; ===================================================
    mov ax, 40h
    mov es, ax 
    mov al, es:[17h]
    test al, 4h
; ===================================================

    je @@old_9

    in al, 60h

    cmp al, 1fh ; ctrl + s
    pushf

    cmp al, 21h ; ctrl + f

    pushf
; ===================================================
	in al, 61h
	or al, 80h
	out 61h, al 
	and al, not 80h
	out 61h, al 
	mov al, 20h
	out 20h, al
; ===================================================
    popf

    jne @@draw
    lea si, save_buffer 
    call print_buffer
    popf 
    jmp @@old_9

    @@draw:
    popf
    jne @@old_9

    ; call copy_draw_buffer

    mov ax, cs
    mov es, ax
    
    lea di, draw_buffer
    ; add di, (160 * 4 + 80) ###########

    mov ax, cs
    mov ds, ax

    mov ah, 0Bh
    ; mov bl, 0A2h
    mov dx, 0

    lea si, frame
    call print_frame_string
    mov bx, si
    lea si, Sp_equ_str

    @@cicle:
        ; push di
        mov cx, 5
        mov al, [bx]
        mov word ptr es:[di], ax    
        add di, 4

        @@p:
            lodsb
            stosw
            loop @@p

        call get_asci_code_reg

        add di, 2
        mov al, [bx + 2]
        mov word ptr es:[di], ax
        add di, 2

        ; add di, 134
        inc dx
        cmp dx, 12
        ; pop di 
        ; add di, 160d
        jne @@cicle

    lea si, frame
    add si, 6   

    call print_frame_string

    lea si, draw_buffer
    call print_buffer ; debug

    @@old_9:
    add sp, 22
    pop ds es bx ax 
    db 0eah
	old09Ofs dw 0
	old09seg dw 0

    iret

endp

My_int_8 proc
    ; cli
    ; sti
    push ax bx cx dx di si es ds bp
    pushf

    call copy_draw_buffer
    ; mov bx, 1

    ; push bp

    mov al, 20h
    out 20h, al
    
    popf
    pop bp ds es si di dx cx bx ax 

    db 0eah
    old08Ofs dw 0 
    old08seg dw 0

    iret
endp

    ; mov ax, 4c00h
    ; int 21h


;============================================================
; Start: bx - смещение в буфере
; 
;============================================================

save_buffer dw 351 dup(0)
draw_buffer dw 351 dup(0)
Sp_equ_str db 'sp = '   
Ax_equ_str db 'ax = '
Bx_equ_str db 'bx = '
Сx_equ_str db 'cx = '
Dx_equ_str db 'dx = '
Si_equ_str db 'si = '
Di_equ_str db 'di = '
Bp_equ_str db 'bp = '
Ds_equ_str db 'ds = '
Es_equ_str db 'es = '
Ss_equ_str db 'ss = '
Cs_equ_str db 'cs = '

;===================================================================================================
; Start: di - нужное значение координаты начала рамки, si - нужный символ
; Destr: di, si
; Note: /*изменение di эквивалентно переносу строки*/ di должен идти по порядку в уменьшенном буфере
;===================================================================================================
print_frame_string proc
    ; push di
    ; lea si, frame
    mov al, [si] 
    ; mov es, cs
    
    stosw
    inc si
    mov cx, 11  
    mov al, [si]
    repne stosw

    inc si
    mov al, [si]
    inc si
    stosw
    mov al, [si]
    ; pop di
    ; add di, 160d
    ret
endp

frame db 0c9h, 0cdh, 0bbh, 0c7h, 00h, 0c7h, 0c8h, 0cdh, 0bch 
; c9 cd bb
; c7 00 c7
; c8 cd bc

;=================================================================================================
; Start: в стеке лежат все регистры в порядке (sp, ax, bx, cx, dx, si, di, bp, ds, es, ss, cs)
;        dx - номер регистра в стеке, di - место в буфере, es - сегмент буфера
; Destr: al, di, es
;=================================================================================================
get_asci_code_reg proc
    push dx 
    push bx

    ; push di
    push bp
    mov bp, sp
    add bp, 28

    xor bx, bx
    ; mov ax, cs
    ; mov es, ax

    shl dx, 1
    sub bp, dx ; bp -> value of register

    mov bl, [bp + 1]
    call print_byte

    mov bl, [bp]
    call print_byte

    pop bp
    ; pop di

    pop bx
    pop dx
    ret
endp

;=================================================================================================
; Start: в bl шестнадцатиричная цифра, es:di - адрес для печати числа, ah - стиль
; Destr: bl, dx, al, di, es
; Note: в bl преобразует младшие 4 бита в ASCI код hex и печатает в буфер
;=================================================================================================

print_hex_symb proc
    cmp bl, 09h
    jg @@letter

    add bl, '0'
    jmp @@letter_end

    @@letter:
    add bl, 'A'
    sub bl, 0Ah
    @@letter_end:
    mov al, bl
    stosw

    ret
endp
;=================================================================================================
; Start: в bl - байт для печати, es:di - адрес для печати числа
; Destr: bl, dx, al, di, es
; Note: выводит bl в буфер в виде ASCI кода
;=================================================================================================
print_byte proc
    mov dl, bl
    and bl, 0f0h ; старшие 4 бита
    shr bl, 4   

    call print_hex_symb

    mov bl, dl
    and bl, 0fh ; младшие 4 бита

    call print_hex_symb
    ret
endp
;=================================================================================================
; Start: si - адрес начала буфера
; Note: print draw_buffer
;=================================================================================================

print_buffer proc
    mov ax, 0b800h
    mov es, ax 

    mov ax, cs 
    mov ds, ax 

    ; lea si, draw_buffer
    ; xor di, di ############################
    mov di, (160 * 4 + 80)

    mov cx, 182d ; 13 * 14
    xor bx, bx

    @@print:
        lodsw
        stosw
        inc bx 
        cmp bx, 13
        je @@enter
        loop @@print 

        @@enter:
            xor bx, bx
            ; add si, 134d
            add di, 134d
            loop @@print

    ret
endp

;=================================================================================================
; Start: si - адрес начала буфера
; Reg: di - индекс байта в видеопамяти, bx - индекс в save_buffer
; Note: print draw_buffer
;=================================================================================================

copy_draw_buffer proc
    push bp

    mov ax, cs 
    mov ds, ax 

    mov ax, 0B800h
    mov es, ax
 
    lea si, draw_buffer
    lea bx, save_buffer
    mov di, (160 * 4 + 80) 
    ; xor di, di

    xor bp, bp ; counter
    mov cx, 182d

    @@cicle:
        mov ax, ds:[si]     
        mov dx, es:[di]

        inc bp
        cmp bp, 13
        jne @@after_enter
        xor bp, bp
        add di, 134d
        @@after_enter:

        cmp ax, dx
        jne @@no_equ
        add di, 2
        add si, 2
        add bx, 2
        ; add si, 134d
        loop @@cicle
        jmp @@end

    @@no_equ:
        mov word ptr ds:[si], dx
        mov word ptr ds:[bx], dx
        add di, 2
        add si, 2
        add bx, 2
        loop @@cicle

    @@end:
    pop bp
    ret
endp

;=================================================================================================
; Destr: di, si, ax, cx, es
; Notes: копирует видеопамять в save_buffer
;=================================================================================================

make_save_buffer proc
    
    lea di, save_buffer 
    mov si, 720d

    mov ax, 0B800h
    mov ds, ax 

    mov ax, cs
    mov es, ax

    mov cx, 182d
    xor bx, bx

    @@cicle:
        lodsw 
        stosw
        inc bx 
        cmp bx, 13d
        je @@enter
        loop @@cicle
        jmp @@end
        @@enter:
            xor bx, bx
            add si, 134d
            loop @@cicle

    @@end:
    mov ax, cs
    mov ds, ax
    ret    
endp

EOP:
end Start