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

		mov ax,data		
		mov ds,ax		;设置数据段地址
		
		mov ax,table
		mov es,ax		;设置输出结果段地址

		mov si,0		;设置数据偏移地址--年份  	ds:[si]
		mov di,84		;设置数据偏移地址--收入		ds:[di]
		mov bx,168		;设置数据偏移地址--员工数量	ds:[bx]
		mov bp,0		;设置table的偏移地址		es:[bp]


		mov cx,21


		;处理年份
		;通过栈来复制数据
inputTable:	push ds:[si]
		pop es:[bp]
		push ds:[si+2]
		pop es:[bp+2]

		

comment     /* 通过寄存器把年份复制到table的位置中
		push cx
		push si
		push bp

		mov cx,2
setYear:	mov ax,ds:[si]
		mov es:[bp],ax
		inc si
		inc bp
		loop setYear

		pop bp
		pop si
		pop cx
*/

		;处理收入
		;由于收入是dd类型的数据，所以可以判断为16位除法，所以需要使用ax,dx两个寄存器参与运算
		;注意高低位的问题	
		mov ax,ds:[di]
		mov dx,ds:[di+2]
		mov es:[bp+5],ax
		mov es:[bp+7],dx

		;处理员工数量
		;通过栈来复制员工数量
		push ds:[bx]
		pop es:[bp+0AH]
		
		div word ptr ds:[bx]
		mov es:[bp+0DH],ax		;将商即ax中的值保存在table的0DH中

	
		;循环21次，每次年份，收入，员工数，平均工资的数据保存位置偏移地址变化
		add si,4
		add di,4
		add bx,2
		add bp,16

		loop inputTable


		mov ax,4C00H
		int 21H



code ends



end start

