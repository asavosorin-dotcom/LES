.286
.model tiny
.code
org 100h

Start:
	mov cx, 0FFffh
	mov bx, 1000h

	aaaa:
	inc bx 
	loop aaaa
	
	mov cx, 0FFffh
	jmp aaaa

	mov ax, 3100h
	mov dx, offset EOP
	shr dx, 4
	inc dx
	int 21h

EOP:
end		Start