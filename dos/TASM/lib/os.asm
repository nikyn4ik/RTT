; создание процедур ; занимает меньше времени и больше памяти
; в регистр dx должна быть помещена строка, примерно так: mov dx, offset [название строки]
printString PROC ; напечатать массив байт
    MOV ah, 09h
    int 21h

    ; перевод на новую строку
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
    ; перевод на новую строку
	MOV dl, 10
	MOV ah, 02h
	INT 21h
	MOV dl, 13
	MOV ah, 02h
	INT 21h
	RET
printSymbol endp

createFile proc
	push bp
	mov bp, sp

    mov ah, 3Ch
    mov al, 0         ; если файл не создаётся: нужно перед вызовом сделать mov cx, 0
    mov dx, [bp+4]    ; название файла
    int 21h

    mov sp, bp
    pop bp

    RET 2
createFile endp


openFileR proc   ; дескриптор файла при открытии вернется в регистр AX
	push bp
	mov bp, sp

	mov ah, 3Dh
	mov al, 0     ; чтение
	mov dx, [bp+4]

	int 21h
	
	mov sp, bp
	pop bp
	RET 2        ; вернуть управление в точку запуска
openFileR endp


openFileRW proc   ; дескриптор файла при открытии вернется в регистр AX
	push bp
	mov bp, sp

	mov ah, 3Dh
	mov al, 2      ; чтение и запись
	mov dx, [bp+4]

	int 21h
	
	mov sp, bp
	pop bp
	RET 2        ; вернуть управление в точку запуска
openFileRW endp


readFile proc   ; Код ошибки если CF установлен к CY; если ошибок не было то в AX будет количество прочитанных байт
	push bp
	mov bp, sp
	mov buffer[buffer_len-1], '$' 
	mov ah, 3Fh
	mov bx, [bp+4]
	xor cx, cx
	mov cx, buffer_len
	lea dx, buffer
	int 21h
	call printString
	call clearBuffer
	mov sp, bp
	pop bp
	RET	2
readFile endp


writeFile proc
	push bp        ; Кладём bp в стэк. Для сохранения указателя на стек используется регистр bp,
	mov bp, sp     ; bp записываем указатель на стек

	mov ah, 40h    ; команда записи в файл
	mov bx, [bp+4] ; дескриптор файла тоже из стэка, куда записывать данные из буфера
	mov cx, [bp+6] ; берем из стэка количество символов, которые нужно заполнить
	mov dx, [bp+8] ; то что будем записывать в файл

	int 21h        ; записать

	mov sp, bp
	pop bp
	RET 6
writeFile endp


appendToEndFile proc
	; bx должен содержать в себе дескриптор файла
	mov ah, 42h  ; "lseek"
	mov al, 2    ; позиция относительно конца файла
	; 0 = смещение относительно начала файла
	; 1 = смещение относительно текущей позиции файла (cx:dx назначен)
	; 2 = смещение относительно конца файла (cx:dx назначен)
	mov cx, 0    ; offset MSW
	mov dx, 0    ; offset LSW
	int 21h
	ret
appendToEndFile endp


appendToStartFile proc
	; Начинает с начала файла перезаписывая всё на своём пути
	mov ah, 42h  ; "lseek" Для изменения текущей позиции чтения-записи используется системный вызов lseek().
	mov al, 0    ; смещение относительно начала файла
	; 0 = смещение относительно начала файла
	; 1 = смещение относительно текущей позицифайла (cx:dx назначен)
	; 2 = смещение относительно конца файла (cx:dx назначен)
	mov cx, 0    ; смещение относительно верхнего слова 
	mov dx, 0    ; смещение относительно нижнего слова 
	int 21h
	ret
appendToStartFile endp


; в BX дескриптор файла, т.е то что было при открытии нужно вернуть в bx -> mov bx, ax
closeFile proc
	mov ah, 3Eh ; функция закрытия файла
	int 21h
	RET
closeFile endp