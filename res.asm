.model tiny
.code 

locals @@
; подумать над названием буфера
; заносить туда строку с rx = val 
; потом печатать этот буфер
; пушить в стек все регистры, чтобы их не потерять

org 100h

Start:
    mov ax, 0FFA2h
    
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

    mov cx, 5
    lea si, Ax_equ_str

    @@p:
        lodsb
        stosw
        loop @@p

    mov dx, 2
    call get_asci_code_reg

    mov cx, 5
    lea si, Bx_equ_str

    @@pb:
        lodsb
        stosw
        loop @@p

    mov dx, 4
    call get_asci_code_reg

    mov ax, 4c00h
    int 21h

;============================================================
; Start: bx - смещение в буфере
; 
;============================================================

Buffer dw 2000 dup(0)
Ax_equ_str db 'ax = '
Bx_equ_str db 'bx = '

;=================================================================================================
; Start: в стеке лежат все регистры в порядке (sp, ax, bx, cx, dx, si, di, bp, ds, es, ss, cs)
;        dx - номер регистра в стеке, di - место в буфере, es - сегмент буфера
; Destr: bx, dx, al, di, es
;=================================================================================================
get_asci_code_reg proc
    
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
    add di, 160
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