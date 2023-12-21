; создание процедур ; занимает меньше времени и больше памяти
; в регистр dx должна быть помещена строка, примерно так: mov dx, offset [название строки]
printString PROC ; напечатать строку
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

createFile proc ; создание файла
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

; открыть для чтения
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

; открыть для чтения записи
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

; прочитать файл
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

; записать в файл
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

; добавить в конец файла
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

; добавить в начала файла
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


; закрыть файл
; в BX дескриптор файла, т.е то что было при открытии нужно вернуть в bx -> mov bx, ax
closeFile proc
	mov ah, 3Eh ; функция закрытия файла
	int 21h
	RET
closeFile endp

; сгенерировать случайное число
getRandom proc
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx


    xor ax, ax ; обнуление ax
    xor ah, ah ; обнуление ah
    mov es, ax
    mov ax, es:[46Ch] ; системный таймер

    cmp [bp+4], 4
    je get_remainder

    cmp [bp+4], 15 ; условие для псевдорандомности - запутывание чисел таймера
    je get_remainder
    jne confuse
confuse:
    ; rol ax, 2
    ; ror ax, 2
    mul ax
    mov al, ah
    mov ah, dl 

get_remainder:
    xor dx, dx
    mov bx, [bp+4]
    div bx


    cmp [bp+4], 4
    je get_end

    cmp [bp+4], 15
    je get_end
    jne dx_below_30
dx_below_30:
    cmp dx, 30
    jbe below
    jnbe get_end

below:
    add dx, 30

get_end:
    mov random, dx

    pop dx
    pop cx
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret 2
getRandom endp



;------------------------------------------
; Конверитируем число в строку 
; Алгоритм : разбить число на цифры, сохранить из в стэк, затем перевернуть их 
; чтобы записать в одну строку.
; параметры : AX = число которое конвертируем.
;             SI = указатель на строку, в которую запишем конвертируемое число, т.е. в эту строку мы запишем символы бывшего числа.
; регистры которые изменятся : AX, BX, CX, DX, SI.

num2str proc ; то число которое мы будем преобразовывать в строку уже записано в ax тут мы будем делить ax на bx
	mov  bx, 10  ; чтобы преобразовать число в строку мы должны разобрать его по числам, для это го будем число делить на 10
	mov  cx, 0   ; счётчик чисел в числе пример: 635 6,3,5 = 3 цифры в числе 635
_cycle1:       
	mov  dx, 0   ; так как результат запишется по адресу DX:AX то мы обнуляем dx
	div  bx      ; DX:AX / 10 = AX:целая часть DX:остаток. 
	; В остатке как раз и будет одна цифра из числа 635: 635%10=5 635/10=63 -> в dx=5, ax=63; 
	push dx      ; сохраняем цифру 5 в стэк чтобы потом записать его в строку.
	inc  cx      ; увеличиваем счётчик в cx. Этот счётчик нужен именно для цикла loop.
	cmp  ax, 0   ; если регист ax
	jne  _cycle1  ; не равен нули цикл продолжается

; здесь мы берем цифры из стэка которые записали выше
_cycle2:  ; это цикл работает пока cx не станет равен нулю. Сам цикл loop подразумевает что cx с каждой итерацией уменьшается
	pop  dx ; достайм из стэка последнюю цифру которую туда записывали
	add  dl, 48  ; это такой способ конвертировать цифру в символ: 2 -> '2'
	mov  [ si ], dl ; как вы помните перед вызовом этой функции в si мы поместили адрес первого символа строки. 
	; Теперь на этот адрес помещаем символ
	inc  si ; смещаемя на второй адрес строки
	loop _cycle2  ; пока cx не станет нулю

	ret ; возвращаем управление в точку вызова
num2str endp    


exit proc
	mov ah, 04ch ; функция DOS выхода из программы
	mov al, 0h 	; код возврата
	int 21h ; Вызов DOS остановка программы
exit endp

clearBuffer proc ; очистка экрана в текстовом режиме
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


clearScreen proc ; очистка экрана в графическом режиме
    mov ax, 0B800h
    mov ax, 0A000h
    mov es, ax
    xor di, di               ; ES:0  это начало фрэймбуфера
    xor ax, ax
    mov cx, 32000d
    cld
    rep stosw
    ret
clearScreen endp