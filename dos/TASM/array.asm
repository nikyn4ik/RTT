MODEL SMALL
STACK 256
DATASEG
	Data1 DB 10h DUP (1)
CODESEG
Start:
	mov ax,@data 		; установка в ds адpеса
	mov ds,ax 		; сегмента данных
	mov dx,offset Data1  	; указатель на массив символов             
Exit:
	mov ah,04Ch 	; функция DOS выхода из пpогpаммы
	mov al,0h 	; код возвpата
	int 21h 	; Вызов DOS остановка пpогpаммы

End Start
