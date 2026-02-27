.model tiny
.code 

locals @@
; подумать над названием буфера
; заносить туда строку с rx = val 
; потом печатать этот буфер
; пушить в стек все регистры, чтобы их не потерять

org 100h

Start:
    mov ax, 0FBA2h
    mov bx, 3346h

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
    
    mov ax, 0b800h
    mov es, ax
    
    mov di, (160 * 8 + 80)

    mov ah, 0Bh
    mov bl, 0A2h
    mov dx, 0
    lea si, Sp_equ_str

    @@cicle:
    mov cx, 5

    @@p:
        lodsb
        stosw
        loop @@p

    call get_asci_code_reg
    inc dx
    cmp dx, 12
    jne @@cicle
    
    mov ax, 4c00h
    int 21h

;============================================================
; Start: bx - смещение в буфере
; 
;============================================================

Buffer dw 2000 dup(0)
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
; Start: в стеке лежат все регистры в порядке (sp, ax, bx, cx, dx, si, di, bp, ds, es, ss, cs)
;        dx - номер регистра в стеке, di - место в буфере, es - сегмент буфера
; Destr: bx, al, di, es
;=================================================================================================
get_asci_code_reg proc
    push dx 

    push di
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
    pop di
    add di, 150

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



end Start