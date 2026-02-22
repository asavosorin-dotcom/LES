.286
.model tiny
.code
org 100h

Start:	
		; int 09h ;experiment
		push 0
		pop es

		mov bx, 4 * 09h
		cli ; don't forget important
		mov es:[bx], offset New09 ;change name
		; <---------------------------------------------------??????????
		mov ax, cs 
		mov es:[bx+2], ax ; положили сегмент
		sti ; it's too important

		; int 09h ;experiment

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

		mov al, 20h ; так совпало
		out 20h, al
; ===================================================

		pop es bx ax
		iret
		endp

EOP:
end		Start