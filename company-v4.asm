 ;�γ����1
 assume cs:codesg, ds:datasg, ss:stacksg

 datasg segment
 	db '1975', '1976', '1977', '1978', '1979', '1980', '1981', '1982', '1983'
 	db '1984', '1985', '1986', '1987', '1988', '1989', '1990', '1991', '1992'
 	db '1993', '1994', '1995'
 	;���ϱ�ʾ21���21���ַ���
 	dd 16, 22, 382, 1356, 2390, 8000, 16000, 24486, 50065, 87479, 140417, 197514
 	dd 345980, 590827, 803530, 1183000, 1843000, 2759000, 3753000, 4649000, 5937000
 	;���ϱ�ʾ21�깫˾�����21��dword������
 	dw 3, 7, 9, 13, 28, 38, 130, 220, 476, 778, 1001, 1442, 2258, 2793, 4037, 5635, 8226
 	dw 11542, 14430, 15257, 17800
 	;���ϱ�ʾ21�깫˾��Ա������21��word������
 datasg ends

 tablesg segment
 	          ;'0123456789ABCDEF'
 	db 21 dup ('year summ ne ?? ')
 tablesg ends

 ;ջ�Σ����ѭ���б���cx
 stacksg segment
 	db 128 dup (0)
 stacksg ends

 stringsg segment
 	db 10 dup ('0'), 0
 stringsg ends

 codesg segment
 start:	;��ʼ��ջ
 	mov ax, stacksg
 	mov ss, ax
 	mov sp, 128

 	call input_table
 	call clear_screen
 	call output_table

 	mov ax, 4c00h
 	int 21h

 ;-------------------------------------------------------------------
 show_year:	;��ds:[si]��ʼ���ĸ��ַ������д��es:[di]��ʼ���ڴ���
 	;���õ��ļĴ���ѹ��ջ
 	push cx
 	push ax
 	push bx
 	push bp
 	push di

 	add di, 3 * 2	;����޸���ݿ�ʼ��
 	mov bx, 0	;bx����ָʾ��ʾ���ڴ��λ�ã�ÿ�μ�2��
 	mov bp, 0	;bp����ָʾԭ���ݵ�λ�ã�ÿ�μ�1��
 	mov cx, 4	;ѭ���Ĵ���ʾ4���ַ�
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
 isShortDiv:;[dx][ax]��ʮ����д��es:[bx]�� bx�ݼ� �ĳ���ʵ��
 	mov cx, dx
 	jcxz shortDiv
 	call long_div
 	jmp isShortDiv
	
 divRet:	ret

 shortDiv:
 	mov cx, 10
 	div cx			;�����ǳ�����cpu����
 	add dx, 30h
 	mov es:[bx], dl
 	mov dx, 0
 	dec bx
 	mov cx, ax
 	jcxz divRet
 	jmp shortDiv
 ;-------------------------------------------------------------------
 input_string:
 	;��dx��ax��������ʮ���Ƶ���ʽд��stringsg�Ķ���
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
 show_string:	;��ds:[si]��ʼ��Ϊ����ַ���д��es:[di]��
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
 show_sum:	;��ʮ������ʽ��ʾds:[si+5]��ʼ���ĸ��ֽڵ����ݣ���ֵ��ʾ��
 	push ax
 	push bx
 	push dx
 	push ds
 	push si
 	push di
 	mov ax, ds:[si+5]
 	mov dx, ds:[si+7]
 	call input_string	;������֮��string����ʮ���Ƶ��ַ���
 			;����֮��bxָ��string�е�һ����������ַ�
 	mov ax, stringsg
 	mov ds, ax			
 	mov si, 0		;ds:[si]

 	add di, 15 * 2	;es:[di] ����޸������뿪ʼ��
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
 	call input_string 	;������֮��string����ʮ���Ƶ��ַ���
 			;����֮��bxָ��string�е�һ����������ַ�

 	mov ax, stringsg
 	mov ds, ax			

 	add di, 30 * 2	;es:[di] ����޸Ĺ�Ա����ʼ��
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
 	call input_string 	;������֮��string����ʮ���Ƶ��ַ���
 			;����֮��bxָ��string�е�һ����������ַ�

 	mov ax, stringsg
 	mov ds, ax			

 	add di, 45 * 2	;es:[di] ����޸��˾����뿪ʼ��
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
 	;Ҫ��ʾ�����ݶ���ds:[si]��ʼ��16*21�ֽ���
 	mov ax, tablesg
 	mov ds, ax
 	mov si, 0		;ds:[si]
	
 	mov ax, 0B800h
 	mov es, ax
 	mov di, 160 * 3;es:[di]��ʼ��ʾ

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
 	mov ax, 0700h	;ax��NULL��ascii��

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
 	mov si, 0		;��������������ڴ����ʼ��ַ
 	mov di, 21 * 4 * 2	;��Ա���������ڴ����ʼ��ַ

 	mov bx, tablesg
 	mov es, bx
 	mov bx, 0		;����Ŀ���ڴ����ʼ��ַ

 	mov cx, 21
 transfer:	;�ƶ����
 	push ds:[si+0]
 	pop es:[bx+0]
 	push ds:[si+2]
 	pop es:[bx+2]
 	;�ƶ�����
 	mov ax, ds:[si+84]
 	mov dx, ds:[si+86]
 	mov es:[bx+5], ax
 	mov es:[bx+7], dx
 	;�ƶ�Ա������
 	push ds:[di+0]
 	pop es:[bx+10]

 	;����ƽ�����벢�ƶ�
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
