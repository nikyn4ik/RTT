
; создание процедур ; занимает меньше времени и больше памяти
printString PROC ; напечатать массив байт
    ; ARG string:WORD
    ; MOV dx, [string]
    ; print string
    MOV ah, 09h
    int 21h

    ; new line
	MOV dl, 10
	MOV ah, 02h
	INT 21h
	MOV dl, 13
	MOV ah, 02h
	INT 21h
    RET
printString ENDP

printSymbol proc ; напечатать символ
	mov ah, 02h
	int 21h
    ; new line
	MOV dl, 10
	MOV ah, 02h
	INT 21h
	MOV dl, 13
	MOV ah, 02h
	INT 21h
	RET
printSymbol endp


openFile proc   ; дескриптор файла при открытии вернется в регистр AX
	mov ah, 3dh ; функция открытия файла
	mov al, 0   ; читать
	mov dx, offset FileName ; имя файла
	int 21h     ; выполнить
	RET         ; вернуть управление в точку запуска
openFile endp

readFile proc   ; Код ошибки если CF установлен к CY; если ошибок не было то в AX будет количество прочитанных байт
	mov ah, 3fh ; функция чтения файла
	mov cx, 14h ; сколько байт прочитать
	mov dx, offset Buffer ; То что будем читать
	int 21h     ; выполнить
	call printString		
	ret
readFile endp

writeFile proc

	ret
writeFile endp
; в BX дескриптор файла, т.е то что было при открытии нужно вернуть в bx -> mov bx, ax
closeFile proc
	mov ah, 3eh ; функция закрытия файла
	int 21h
	RET
closeFile endp


fun1 PROC  
	mov dl,'-'
	mov ah,02h
	int 21h
	mov dl,'>'
	mov ah,02h
	int 21h
	ret
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
	ret
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



