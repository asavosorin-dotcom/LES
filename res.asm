.model tiny
.code 

locals @@
; создать буфер для вывода 
; заносить туда строку с rx = val 
; потом печатать этот буфер
; пушить в стек все регистры, чтобы их не потерять

org 100h

Start:
    mov ax, 0B800h
    mov es, ax
    
    mov di, (160 * 8 + 80)

    mov ah, 0Bh
    mov bl, 0A2h

    call print_byte

    mov ax, 4c00h
    int 21h

;============================================================
; Start: bx - смещение в буфере
; 
;============================================================

Buffer dw 2000 dup(0)

;=================================================================================================
; Start: в стеке лежат все регистры в порядке (sp, ax, bx, cx, dx, si, di, bp, ds, es, ss, cs, ip)
;        dx - номер регистра в стеке, di - место в буфере
; Destr: bx, dx, al, di, es
;=================================================================================================
get_asci_code_reg proc
    
    push bp
    mov bp, sp
    add bp, 4

    xor bx, bx
    mov ax, cs
    mov es, ax

    shl dx, 1
    add bp, dx ; bp -> value of register

    mov bl, [bp]
    call print_byte

    mov bl, [bp + 1]
    call print_byte

    pop bp
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