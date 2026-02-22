.286
.model tiny
.code
org 100h

Start:	
		; int 09h ;experiment

		mov ax, 3509h
		int 21h

		mov old09Ofs, bx
		mov bx, es
		mov old09seg, es

		push es bx

		push 0
		pop es

		mov bx, 4 * 09h
		cli ; don't forget important

		mov es:[bx], offset New09 ;change name
		; <---------------------------------------------------??????????\

		mov ax, cs 
		mov es:[bx+2], ax
		pop bx es 
		sti ; it's too important	

		int 09h;experimentSz
; ===================================================

		; mov old09Ofs, bx
		; mov bx, es
		; mov old09seg, es

		; db 0eah
		; old09Ofs dw 0
		; old09seg dw 0
; ===================================================

		mov ax, 3100h
		mov dx, offset EOP
		shr dx, 4
		inc dx
		int 21h


New09 	proc

		push ax bx es

		push 0b800h
		pop es
		mov bx, (80d*5 + 40d) * 2
		mov ah, 4eh

		in al, 60h
		mov es:[bx], ax

; ===================================================
		in al, 61h
		or al, 80h
		out 61h, al 
		and al, not 80h
		out 61h, al 

		mov al, 20h
		out 20h, al
; ===================================================
		pop es bx ax

		; ; push bx
		db 0eah
		; jmp  
		old09Ofs dw 0
		old09seg dw 0

		iret
				
		endp

EOP:
end		Start