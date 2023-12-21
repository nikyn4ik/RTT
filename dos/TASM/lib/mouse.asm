;---------------------------------------        
SetCursor proc 
	; Инициализация мыши
	mov ax, 0h
	int 33h
	; Показать мышь
	mov ax, 1h
	int 33h
	; получить положением мыши и статус
	; mov ax, 3h
	; int 33h
	ret
SetCursor endp 

       
;---------------------------------------              
; Полуить положение курсора   
; возврат : BX : бит 0 = 0 : нажата левая кнопка мыши.
;                      = 1 : отпущена левая кнопка мыши.
;            :   бит 1 = 0 : нажата правая кнопка мыши..
;                      = 1 : отпущена правая кнопка мыши.
;         CX = x.
;         DX = y.
GetMouseState proc 
	mov  ax, 3       ;Эта функция позволяет определить где пользователь кликнул мышкой. Определить состояние мыши
	int  33h
	ret
GetMouseState endp 





checkColorPixel proc
	push bp
	mov bp, sp

	mov ah, 0Dh ; функция получения цвета по координатам
	mov cx, [x_mouse] 
	mov dx, [y_mouse]
	int 10H ; AL = цвет
	cmp al, byte ptr randomColor ; такой приём позволяет сравнить 8бит регистр с 16 битной переменной, т.е. мы как бы преобразуем randomColor в 8 бит
	je noblack
	jmp next
noblack:
	mov isNew, 1
	jmp next
next:
	mov sp, bp
	pop bp
	ret

checkColorPixel endp


hideMouse proc
	mov AX, 2                
	INT 33h                  ; скрываем мышку
	ret
hideMouse endp


showMouse proc
	mov AX, 1                
	INT 33h                  ; показываем мышку 
	ret
showMouse endp