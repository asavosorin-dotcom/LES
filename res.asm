.model tiny
.code 

locals @@
; подумать над названием буфера
; заносить туда строку с rx = val 
; потом печатать этот буфер
; пушить в стек все регистры, чтобы их не потерять

org 100h

Start:
    mov ax, 3509h
	int 21h

	mov old09Ofs, bx
	mov bx, es
	mov old09seg, es

    call make_save_buffer

    xor ax, ax
    mov es, ax

    mov bx, 4 * 09h

    cli
    mov es:[bx], offset My_int_9
    mov ax, cs
    mov es:[bx + 2], ax
    sti

    int 09h

    mov ax, 3100h
	mov dx, offset EOP
	shr dx, 4
	inc dx
    add dx, 55
	int 21h

    mov ax, 0FBA2h
    mov bx, 3346h

My_int_9 proc
    push ax bx es

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


    cmp al, 21h ; ctrl + D

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

    mov ax, cs
    mov es, ax
    
    lea di, draw_buffer
    add di, (160 * 4 + 80)

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
        mov cx, 5
        mov al, [bx]
        mov word ptr es:[di], ax
        add di, 4

        ;вот тут писать символ рамки
        @@p:
            lodsb
            stosw
            loop @@p
        call get_asci_code_reg
        ; тут тоже символ рамки, надо перенести из функции команду на смещение

        add di, 2
        mov al, [bx + 2]
        mov word ptr es:[di], ax

        add di, 136
        inc dx
        cmp dx, 12
        jne @@cicle

    lea si, frame
    add si, 6   

    call print_frame_string

    lea si, draw_buffer
    call print_buffer

    @@old_9:
    add sp, 22
    pop es bx ax 
    db 0eah
	old09Ofs dw 0
	old09seg dw 0

    iret

endp

; My_int_8 proc
;     push ax bx es

;     ;сравнить два буфера

;     pop es bx ax 
;     db 0eah
;     old08Ofs dw 0 
;     old08Ofs dw 0
; endp

    ; mov ax, 4c00h
    ; int 21h


;============================================================
; Start: bx - смещение в буфере
; 
;============================================================

save_buffer dw 2000 dup(0)
draw_buffer dw 2000 dup(0)
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

;=================================================================================================
; Start: di - нужное значение координаты начала рамки, si - нужный символ
; Destr: di, si
; Note: изменение di эквивалентно переносу строки
;=================================================================================================
print_frame_string proc
    push di
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
    pop di
    add di, 160d
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
    xor di, di

    mov cx, 2000d
    
    @@print:
        lodsw
        stosw
        loop @@print 

    ret
endp

copy_draw_buffer proc
    mov ax, cs 
    mov ds, ax 

    mov ax, 0B800h
    mov es, ax
 
    lea si, draw_buffer
    xor di, di



endp

;=================================================================================================
; Destr: di, si, ax, cx, es
; Notes: копирует видеопамять в save_buffer
;=================================================================================================

make_save_buffer proc
    
    lea di, save_buffer 
    xor si, si 

    mov ax, 0B800h
    mov ds, ax 

    mov ax, cs
    mov es, ax

    mov cx, 2000d

    @@cicle:
        lodsw 
        stosw
        loop @@cicle

    mov ax, cs
    mov ds, ax
    ret    
endp

EOP:
end Start