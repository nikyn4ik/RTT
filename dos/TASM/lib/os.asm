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







; printNumber proc
; 	push ax
; 	push bx
; 	push cx
; 	push dx

; 	; amount iterations that happens into first loop 
; 	xor cx, cx

; 	.next_iter:
; 		mov bx, 10 ; mov ebx 10
; 		xor dx, dx ; mov null edx
; 		div bx ; div on ebx eax
; 		add dx, '0' ; convert to asci
; 		push dx ; res push into stack
; 		inc cx ; ecx++ 

; 		cmp ax, 0
; 		je .print_iter ; if eax == 0

; 		jmp .next_iter
; 	.print_iter:
; 		;print msg, len

; 		cmp cx, 0
; 		je .close

; 		pop ax
; 		mov [ss1], ax
; 		push cx ; that no erace increments
; 		print ss1, 4
; 		pop cx ; that no erace increments
; 		dec cx
; 		jmp .print_iter
		
; 	.close:
; 		mov [ss2], byte 0xa 
; 		print ss2, 2

; 		;print byte '\n', 1
; 		pop dx
; 		pop cx
; 		pop bx
; 		pop ax
; 		ret

; printNumber endp







createFile proc
	push bp
	mov bp, sp

    mov ah, 3Ch
    mov al, 0         ; <<<< THIS IS AN ERROR: NEEDS TO BE CX=0
    mov dx, [bp+4]
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
	push bp        ; Сохраняем bp. Для сохранения указателя на стек используется регистр bp,
	mov bp, sp     ; bp записываем указатель на стек
	; mov dl, [bp+6]     
	; add dl, '0'   
	; call printSymbol
	; mov dx, [bp+8]                 
	; call printString
	mov ah, 40h    ; команда записи в файл
	mov bx, [bp+4] ; дескриптор файла тоже из стэка, куда записывать данные из буфера
	mov cx, [bp+6] ; берем из стэка количество символов, которые нужно заполнить
	mov dx, [bp+8] ; то что будем записывать в файл

	int 21h        ; записать

	mov sp, bp
	pop bp
	; call exit
	RET 6
writeFile endp


appendToEndFile proc
	; bx have to handle file
	mov ah, 42h  ; "lseek"
	mov al, 2    ; position relative to end of file
	; 0 = offset from beginning of file
	; 1 = offset from current position (cx:dx is signed)
	; 2 = offset from end of file (ditto)
	mov cx, 0    ; offset MSW
	mov dx, 0    ; offset LSW
	int 21h
	ret
appendToEndFile endp


appendToStartFile proc
	; Начинает с начала файла перезаписывая всё на своём пути
	mov ah, 42h  ; "lseek"
	mov al, 0    ; position relative to end of file
	; 0 = offset from beginning of file
	; 1 = offset from current position (cx:dx is signed)
	; 2 = offset from end of file (ditto)
	mov cx, 0    ; offset MSW
	mov dx, 0    ; offset LSW
	int 21h
	ret
appendToStartFile endp


; в BX дескриптор файла, т.е то что было при открытии нужно вернуть в bx -> mov bx, ax
closeFile proc
	mov ah, 3Eh ; функция закрытия файла
	int 21h
	RET
closeFile endp