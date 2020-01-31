 ;课程设计1
 assume cs:codesg, ds:datasg, ss:stacksg

 datasg segment
 	db '1975', '1976', '1977', '1978', '1979', '1980', '1981', '1982', '1983'
 	db '1984', '1985', '1986', '1987', '1988', '1989', '1990', '1991', '1992'
 	db '1993', '1994', '1995'
 	;以上表示21年的21个字符串
 	dd 16, 22, 382, 1356, 2390, 8000, 16000, 24486, 50065, 87479, 140417, 197514
 	dd 345980, 590827, 803530, 1183000, 1843000, 2759000, 3753000, 4649000, 5937000
 	;以上表示21年公司收入的21个dword型数据
 	dw 3, 7, 9, 13, 28, 38, 130, 220, 476, 778, 1001, 1442, 2258, 2793, 4037, 5635, 8226
 	dw 11542, 14430, 15257, 17800
 	;以上表示21年公司雇员人数的21个word型数据
 datasg ends

 tablesg segment
 	          ;'0123456789ABCDEF'
 	db 21 dup ('year summ ne ?? ')
 tablesg ends

 ;栈段，多层循环中保存cx
 stacksg segment
 	db 128 dup (0)
 stacksg ends

 stringsg segment
 	db 10 dup ('0'), 0
 stringsg ends

 codesg segment
 start:	;初始化栈
 	mov ax, stacksg
 	mov ss, ax
 	mov sp, 128

 	call input_table
 	call clear_screen
 	call output_table

 	mov ax, 4c00h
 	int 21h

 ;-------------------------------------------------------------------
 show_year:	;将ds:[si]开始的四个字符的年份写入es:[di]开始的内存中
 	;将用到的寄存器压入栈
 	push cx
 	push ax
 	push bx
 	push bp
 	push di

 	add di, 3 * 2	;这儿修改年份开始列
 	mov bx, 0	;bx用来指示显示器内存的位置（每次加2）
 	mov bp, 0	;bp用来指示原数据的位置（每次加1）
 	mov cx, 4	;循环四次显示4个字符
 showYear:
 	mov al, ds:[si+bp]
 	mov es:[di+bx], al
 	inc bp
 	add bx, 2
 	loop showYear
	
 	pop di
 	pop bp
 	pop bx
 	pop ax
 	pop cx

 	ret
 ;===================================================================
 ;-------------------------------------------------------------------
 long_div:	
 	mov cx, 10
 	push ax
 	mov bp, sp

 	mov ax, dx
 	mov dx, 0
 	div cx
 	push ax
 	mov ax, ss:[bp]
 	div cx
 	mov cx, dx
 	pop dx

 	add sp, 2
 	add cx, 30h
 	mov es:[bx], cl
 	dec bx

 	ret
 ;-------------------------------------------------------------------
 isShortDiv:;[dx][ax]以十进制写入es:[bx]中 bx递减 的除法实现
 	mov cx, dx
 	jcxz shortDiv
 	call long_div
 	jmp isShortDiv
	
 divRet:	ret

 shortDiv:
 	mov cx, 10
 	div cx			;除法非常消耗cpu性能
 	add dx, 30h
 	mov es:[bx], dl
 	mov dx, 0
 	dec bx
 	mov cx, ax
 	jcxz divRet
 	jmp shortDiv
 ;-------------------------------------------------------------------
 input_string:
 	;将dx，ax的内容以十进制的形式写入stringsg的段中
 	push ax
 	push cx
 	push dx
 	push ds
 	push es
 	push si
 	push di

 	mov bx, stringsg
 	mov es, bx
 	mov bx, 9
 	call isShortDiv

 	pop di 
 	pop si 
 	pop es
 	pop ds
 	pop dx
 	pop cx
 	pop ax	

 	ret
 ;-------------------------------------------------------------------
 show_string:	;将ds:[si]开始不为零的字符串写入es:[di]中
 	push bx
 	push cx
 	push ds
 	push es
 	push si
 	push di

 showString:	mov ch, 0
 	mov cl, ds:[bx+1]
 	jcxz show_string_ret
 	mov es:[di], cl 
 	add di, 2
 	inc bx
 	jmp showString
 show_string_ret:
 	pop di
 	pop si
 	pop es
 	pop ds
 	pop cx
 	pop bx
 	ret
 ;-------------------------------------------------------------------
 show_sum:	;以十进制形式显示ds:[si+5]开始的四个字节的内容（数值显示）
 	push ax
 	push bx
 	push dx
 	push ds
 	push si
 	push di
 	mov ax, ds:[si+5]
 	mov dx, ds:[si+7]
 	call input_string	;这句结束之后string中是十进制的字符了
 			;结束之后bx指向string中第一个有意义的字符
 	mov ax, stringsg
 	mov ds, ax			
 	mov si, 0		;ds:[si]

 	add di, 15 * 2	;es:[di] 这儿修改总收入开始列
 	call show_string

 	pop di
 	pop si
 	pop ds
 	pop dx
 	pop bx
 	pop ax
 	ret
 ;-------------------------------------------------------------------
 show_num:	
 	push ax
 	push bx
 	push dx
 	push ds
 	push si
 	push di

 	mov ax, ds:[si+10]
 	mov dx, 0
 	call input_string 	;这句结束之后string中是十进制的字符了
 			;结束之后bx指向string中第一个有意义的字符

 	mov ax, stringsg
 	mov ds, ax			

 	add di, 30 * 2	;es:[di] 这儿修改雇员数开始列
 	call show_string

 	pop di
 	pop si
 	pop ds
 	pop dx
 	pop bx
 	pop ax
 	ret
 ;-------------------------------------------------------------------
 show_salary:	
 	push ax
 	push bx
 	push dx
 	push ds
 	push si
 	push di

 	mov ax, ds:[si+13]
 	mov dx, 0
 	call input_string 	;这句结束之后string中是十进制的字符了
 			;结束之后bx指向string中第一个有意义的字符

 	mov ax, stringsg
 	mov ds, ax			

 	add di, 45 * 2	;es:[di] 这儿修改人均收入开始列
 	call show_string

 	pop di
 	pop si
 	pop ds
 	pop dx
 	pop bx
 	pop ax
 	ret
 ;-------------------------------------------------------------------
 output_table:
 	;要显示的内容都在ds:[si]开始的16*21字节内
 	mov ax, tablesg
 	mov ds, ax
 	mov si, 0		;ds:[si]
	
 	mov ax, 0B800h
 	mov es, ax
 	mov di, 160 * 3;es:[di]开始显示

 	mov cx, 21
 outputTable:
 	call show_year
 	call show_sum
 	call show_num
 	call show_salary
 	add si, 16
 	add di, 160
 	loop outputTable
 	ret
 ;===================================================================
 ;-------------------------------------------------------------------
 clear_screen:
 	push ax
 	push ds
 	push si
 	push cx

 	mov ax, 0B800h
 	mov ds, ax
 	mov si, 0		;ds:[si]
 	mov ax, 0700h	;ax是NULL的ascii码

 	mov cx, 2000
 clearScreen:
 	mov ds:[si], ax
 	add si, 2
 	loop clearScreen

 	pop cx
 	pop si
 	pop ds
 	pop ax
 	ret
 ;===================================================================
 ;-------------------------------------------------------------------
 input_table:
 	push ax
 	push bx
 	push cx
 	push dx
 	push ds
 	push es
 	push si
 	push di

 	mov bx, datasg
 	mov ds, bx
 	mov si, 0		;年份与收入所在内存的起始地址
 	mov di, 21 * 4 * 2	;雇员人数所在内存的起始地址

 	mov bx, tablesg
 	mov es, bx
 	mov bx, 0		;数据目的内存的起始地址

 	mov cx, 21
 transfer:	;移动年份
 	push ds:[si+0]
 	pop es:[bx+0]
 	push ds:[si+2]
 	pop es:[bx+2]
 	;移动收入
 	mov ax, ds:[si+84]
 	mov dx, ds:[si+86]
 	mov es:[bx+5], ax
 	mov es:[bx+7], dx
 	;移动员工数量
 	push ds:[di+0]
 	pop es:[bx+10]

 	;计算平均收入并移动
 	div word ptr es:[bx+10]
 	mov es:[bx+13], ax

 	add si, 4
 	add di, 2
 	add bx, 16
 	loop transfer

 	pop di 
 	pop si
 	pop es
 	pop ds
 	pop dx
 	pop cx
 	pop bx
 	pop ax
 	ret
 ;===================================================================

 codesg ends

 end start
