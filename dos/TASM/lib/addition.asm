; .386

; это тестовые функции некоторые будут использоваться в основной программе

fun1 PROC  
	mov dl,'-'
	mov ah,02h
	int 21h
	mov dl,'>'
	mov ah,02h
	int 21h
	RET
fun1 ENDP


; функция с параметрами
fun2 proc
	ARG @@a1:byte
	ARG @@a2:byte
	mov dl, @@a1
	mov ah, 02h
	int 21h
	mov dl, @@a2
	mov ah, 02h
	int 21h
	RET
fun2 endp

; in 	регистр,ном_порта   	ввод значения из порта ввода-вывода
; out 	ном_порта,регистр  	вывод значения в порт ввода-вывода 


; создание макросов ; занимает больше времени и меньше памяти
sound macro
	in al, 61h ; получить текущее значение
	or al, 02h ; установить второй бит
	out 61h, al ; вывести значение в порт
	mov cx, 9000h ; количество циклов
delay:
	loop delay   ; ждать
	and al, 0fdh ; очистить второй бит
	out 61h, al  ; вывести в порт

endm




;Clearing screen
clearScreen proc
    ; MOV AH, 0 
    ; MOV AL, 2 
    mov ax, 02
    INT 10H 
    RET
clearScreen endp

exit proc
	mov ah, 04ch ; функция DOS выхода из программы
	mov al, 0h 	; код возврата
	int 21h ; Вызов DOS остановка программы
exit endp



clearBuffer proc
	push ax
	push bx
	push cx
	push dx

	mov cx, buffer_len
	mov bx, offset buffer
l1:		
	mov al, [bx]
	mov al, 0
	mov [bx], al
	inc bx
	loop l1

	pop dx
	pop cx
	pop bx
	pop ax
	ret
clearBuffer endp

GetMouseState proc 
	mov  ax, 3       ;SERVICE TO GET MOUSE STATE.
	int  33h
	ret
GetMouseState endp 









getRandomNums proc


	ret
getRandomNums endp