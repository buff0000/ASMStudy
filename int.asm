assume cs:code, ds:data, ss:stack

data segment
	db 128 dup(0)
data ends

stack segment stack
	db 128 dup(0)
stack ends

code segment
	start:	mov ax,stack
		mov ss,ax
		mov sp,128

		call cpy_new_int0	;中断处理程序
		call set_new_int0	;设备中断位置
		int 0			;发生中断

		mov ax,4C00H
		int 21H


;=================================================
set_new_int0:
		mov bx,0
		mov es,bx
		
		cli 
		mov word ptr es:[0*4],7E00H
		mov word ptr es:[0*4+2],0
		sti
		ret

;=================================================
new_int0:	push bx
		push cx
		push dx
		push es

		mov bx,0B800H
		mov es,bx

		mov bx,0
		mov cx,2000
		mov dl,'!'
		mov dh,00000010B

show_asc:	mov es:[bx],dx
		add bx,2
		loop show_asc

		pop es
		pop dx
		pop cx
		pop bx
		iret

new_int0_end:	nop

;=================================================
cpy_new_int0:
		mov bx,cs
		mov ds,bx
		mov si, OFFSET new_int0

		mov bx,0
		mov es,bx
		mov di,7E00H

		mov cx,OFFSET new_int0_end - new_int0
		cld
		rep movsb

		ret

code ends

end start
