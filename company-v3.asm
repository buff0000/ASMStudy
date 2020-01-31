assume cs:code,ds:data,ss:stack

data segment

		db	'1975','1976','1977','1978','1979','1980','1981','1982','1983'
		db	'1984','1985','1986','1987','1988','1989','1990','1991','1992'
		db	'1993','1994','1995'
		;�����Ǳ�ʾ21���21���ַ��� year


		dd	16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
		dd	345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
		;�����Ǳ�ʾ21�깫˾�������21��dword����	sum

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
		;��ʼ���Դ�ε�ַ��ƫ�Ƶ�ַ
		mov bx,0B800H
		mov es,bx
		mov bx,0

		mov dx,0100H		;01��ɫ��00���ַ�

		mov cx,2000		;25��*80��

clearScreen:	mov es:[bx],dx		;dx�����ֽڣ�һ�����ַ���һ�����ַ�����
		add bx,2
		loop clearScreen
		ret

;========================================================
		;��ʼ��table�ڴ����ݵĶε�ַ��ƫ�Ƶ�ַ
output_table:	mov bx,table
		mov ds,bx
		mov si,0
		
		;��ʼ���Դ�Ķε�ַ��ƫ�Ƶ�ַ
		mov bx,0B800H
		mov es,bx
		mov di,160*3		;��ʾλ��--��

		;ѭ������
		mov cx,21

outputTable:	call show_year
		call show_summ
	;	call show_ne
	;	call show_average
		add di,160		;����
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
		;����Ա��������������ax,dx��
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

		add di,25*2		;��ʾ����λ��

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
		;��10
short_div:	mov cx,10
		div cx
		add dl,30H		;���ּ���30�������Ӧ��ASCII��
		mov es:[di+0],dl
		mov byte ptr es:[di+1],00000010B	;������ɫ

		mov cx,ax		;����cx��ֵΪ�̣����Ϊ0����jcxz��ת
		jcxz shortDivRet
		
		mov dx,0		;������0
		sub di,2		;��ʾλ�������ƣ���ȡ���ݵ�λ���Ǹ���ʮ����... ...���������ƶ�	
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
		add di,3*2		;��ʾλ��--��
		
showYear:	mov al,ds:[si]		;ȡ��table�е����ݸ��Ƶ��Դ���
		mov es:[di],al
		add di,2		;�����Դ�����һ���ַ�����ռһ���ֽڣ�����ƫ��λ�ü�2��
		inc si			;ȡ��һ������ַ�
		loop showYear
		
		pop di
		pop si
		pop es
		pop ds
		pop cx
		pop ax

		ret
;========================================================
		;��ʼ��������Դ�Ķε�ַ��ƫ�Ƶ�ַ
input_table: 	mov bx,data
		mov ds,bx
		mov si,0

		;��ʼ���������table�Ķε�ַ��ƫ�Ƶ�ַ
		mov bx,table
		mov es,bx
		mov di,0		

		mov bx,21*4+21*4		;Ա����ƫ��λ�ã�21*2(���ƫ��) ���� 21*2(����ƫ��)
		mov cx,21		;ѭ������


		;ͨ��ջ��������ݵ�table��
inputTable:	push ds:[si+0]
		pop es:[di+0]
		push ds:[si+2]
		pop es:[di+2]

		
		;���ñ������������룬16λ������ax��dx��Ҫ����
		mov ax,ds:[si+21*4+0]
		mov dx,ds:[si+21*4+2]

		;�����������Ƶ�table�У��Ա���ʾ
		mov es:[di+5],ax
		mov es:[di+7],dx

		;���������Ƶ�table�У���ǰ��bx�������Ա����ƫ��λ��
		push ds:[bx]
		pop es:[di+10]

		div word ptr es:[di+10]
		mov es:[di+13],ax

		add di,16		;��һ������λ��
		add si,4		;��һ�����λ��
		add bx,2		;��һ��Ա����λ��


		loop inputTable
	
		ret


code ends



end start

