.model tiny
.code 

org 100h

Start:
    ; mov ax, 3509h
    ; int 21h

    ; mov old09Ofs, bx
    ; ; mov bx, es
    ; mov old09seg, es
    mov al, 07h
    add al, '0'

    mov cl, al
    mov ch, 4ch
    or ch, 80h

    mov bx, 0b800h
    mov es, bx

    mov bx, (160 * 5 + 80)
    mov es:[bx], cx
    
    mov ax, 4c00h
    int 21h
end Start