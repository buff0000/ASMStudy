assume cs:code,ds:data,ss:stack

data segment

		db	'1975','1976','1977','1978','1979','1980','1981','1982','1983'
		db	'1984','1985','1986','1987','1988','1989','1990','1991','1992'
		db	'1993','1994','1995'
		;以上是表示21年的21个字符串 year


		dd	16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
		dd	345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
		;以上是表示21年公司总收入的21个dword数据	sum

		dw	3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
		dw	11542,14430,15257,17800

data ends

table segment
			;0123456789ABCDEF
	db	21 dup ('year summ ne ?? ')
table ends

stack segment stack
	db	128 dup (0)
stack ends



code segment

	start:	mov ax,stack
		mov ss,ax
		mov sp,128

		call input_table

		call clear_screen

		call output_table


		mov ax,4C00H
		int 21H

;========================================================
clear_screen:
		;初始化显存段地址和偏移地址
		mov bx,0B800H
		mov es,bx
		mov bx,0

		mov dx,0100H		;01蓝色，00空字符

		mov cx,2000		;25行*80列

clearScreen:	mov es:[bx],dx		;dx两个字节，一个是字符，一个是字符属性
		add bx,2
		loop clearScreen
		ret

;========================================================
		;初始化table内存数据的段地址和偏移地址
output_table:	mov bx,table
		mov ds,bx
		mov si,0
		
		;初始化显存的段地址和偏移地址
		mov bx,0B800H
		mov es,bx
		mov di,160*3		;显示位置--行

		;循环次数
		mov cx,21

outputTable:	call show_year
		call show_summ
	;	call show_ne
	;	call show_average
		add di,160		;换行
		add si,16

		loop outputTable

		ret

;========================================================
show_average:	push ax
		push bx
		push cx
		push dx
		push ds
		push es
		push si
		push di

		mov ax,ds:[si+13]
		mov dx,0
	
		add di, 40*2
		
		call short_div
	
		pop di
		pop si
		pop es
		pop ds
		pop dx
		pop cx
		pop bx
		pop ax

		ret


;========================================================
show_ne:	
		;设置员工数量，保存在ax,dx中
		mov ax,ds:[si+10]
		mov dx,0
		
		add di,30*2
		
		call short_div

		ret


;========================================================
show_summ:
		push ax
		push bx
		push cx
		push dx
		push ds
		push es
		push si
		push di

			;0123456789ABCDEF
			;year summ ne ?? 

		mov ax,ds:[si+5]
		mov dx,ds:[si+7]

		add di,25*2		;显示的列位置

		call short_div


		pop di
		pop si
		pop es
		pop ds
		pop dx
		pop cx
		pop bx
		pop ax

		ret
;========================================================
		;除10
short_div:	mov cx,10
		div cx
		add dl,30H		;数字加上30等于其对应的ASCII码
		mov es:[di+0],dl
		mov byte ptr es:[di+1],00000010B	;设置颜色

		mov cx,ax		;设置cx的值为商，如果为0，则jcxz跳转
		jcxz shortDivRet
		
		mov dx,0		;余数清0
		sub di,2		;显示位置向左移，获取数据的位置是个，十，百... ...所以向左移动	
		jmp short_div

shortDivRet:	ret

;========================================================
show_year:	push ax
		push cx
		push ds
		push es
		push si
		push di

		mov cx,4
		add di,3*2		;显示位置--例
		
showYear:	mov al,ds:[si]		;取出table中的数据复制到显存中
		mov es:[di],al
		add di,2		;由于显存中有一个字符属性占一个字节，所以偏移位置加2，
		inc si			;取下一个年份字符
		loop showYear
		
		pop di
		pop si
		pop es
		pop ds
		pop cx
		pop ax

		ret
;========================================================
		;初始化数据来源的段地址和偏移地址
input_table: 	mov bx,data
		mov ds,bx
		mov si,0

		;初始化输出数据table的段地址和偏移地址
		mov bx,table
		mov es,bx
		mov di,0		

		mov bx,21*4+21*4		;员工数偏移位置，21*2(年份偏移) 加上 21*2(收入偏移)
		mov cx,21		;循环次数


		;通过栈来复制年份到table中
inputTable:	push ds:[si+0]
		pop es:[di+0]
		push ds:[si+2]
		pop es:[di+2]

		
		;设置被除数，即收入，16位除法，ax和dx都要设置
		mov ax,ds:[si+21*4+0]
		mov dx,ds:[si+21*4+2]

		;将被除数复制到table中，以备显示
		mov es:[di+5],ax
		mov es:[di+7],dx

		;将除数复制到table中，在前边bx保存的是员工数偏移位置
		push ds:[bx]
		pop es:[di+10]

		div word ptr es:[di+10]
		mov es:[di+13],ax

		add di,16		;下一行数据位置
		add si,4		;下一个年份位置
		add bx,2		;下一个员工数位置


		loop inputTable
	
		ret


code ends



end start

