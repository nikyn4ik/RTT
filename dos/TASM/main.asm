; .386
; 16 - битная программа запускать на dosbox
.model small
.stack 200  ;стек (минимум 200 байт надо), но эта программа будет работать и так

_STACK  segment para stack
    db 1024 dup(?) ; тоже размер стека
_STACK  ends


_DATA segment; .data, DATASEG
	buffer db 200 DUP(0), '$'          ; буффер на 200 символов
	buffer_len equ $-buffer
	results db 'results.txt', 0 


	; для цикла
	counter dw 0


	eror dw ?
	xx dw ?
	yy dw ?
	xx0 dw ?
	yy0 dw ?
	delta dw ?
	radius dw ?

	; mouse
	XCords1 dw 160        ; где будет находится
	YCords1 dw 100        ; курсор при запуске
	x_mouse dw ?          ; сюда запишем координату X клика мыши. ; ? - означает что переменная не инициализорованна
	y_mouse dw ?          ; сюда запишем координату Y клика мыши. ; dw - размер переменной 2 байта

	numstr1 db 3 DUP (' '), 0Dh, 0Ah  ; строка состоящая из 3 пробелов и символов перевода строки

	random dw ?
	randomX dw ?
	randomY dw ?
	randomColor dw ?
	randomFigure dw ?

	isNew db ?

	game_point db 0
	game_end_message db "Finish $" 
	score db 20 ; попыток 

	s1 dw 0 ; певая запись времени
	s2 dw 0 ; вторая запись времени

	x1 dw 0 ; эти переменные используются для закрашивания окружности ; первая точка
	y1 dw 0

	x2 dw 0 ; вторая точка
	y2 dw 0

_DATA ends




_TEXT segment ; .code
	include addition.asm ; подключаем файл с функциями, можно удалить эту строку и вставить содержимое включаемго файла
	include geometry.asm ; функции с фигурами
	include time.asm     ; хранит функции для работы со временем
	include os.asm       ; создание, чтение, запись, дозапись
	include res.asm      ; режимы для графики
	include keyboard.asm ; все по работе с клавой
	include mouse.asm    ; мышь

	assume cs: _TEXT, ds: _DATA, es: _DATA, ss:_STACK
start: ; .startup
	mov ax, @data        ; установка в ds адреса
	mov ds, ax           ; Для указания сегмента данных используется регистр DS




	; ставим временну метку в s1
    mov ah, 2Ch ; команда для доступа к времени после неё в cl - запишется сколько сейчас минут, в dh - сколько сейчас секунд
    int 21h
    mov dl, 0
    xchg dh, dl

    xor ax, ax
    xor bx, bx
    mov al, cl
    mov bl, 60
    mul bl
    add ax, dx

    mov s1, ax


	call setResulutionVGA40 ;
	call SetCursor ; Инициализировать мышь
draw1:
	push 620
	call getRandom
	mov ax, random
	mov randomX, ax

	push 460
	call getRandom
	mov ax, random
	mov randomY, ax

	push 15
	call getRandom
	mov ax, random
	inc ax
	mov randomColor, ax

	push 4
	call getRandom
	mov ax, random
	mov randomFigure, ax

	; mov randomColor, 2
	; jmp f3 ; (заменяем метку на которую хотим прыгать, например, если круг, то f3)
	cmp randomFigure, 0
	je f0 ; прыгнуть на метку с ромбом

	cmp randomFigure, 1
	je f1 ; прыгнуть на метку с квадратом

	cmp randomFigure, 2
	je f2 ; прыгнуть на метку с треугольником

	cmp randomFigure, 3
	je f3 ; прыгнуть на метку с кргом

f0: ; ромб
	push randomX ; x
	push randomY ; y
	push 5  ; половина диагонали по оси y
	push randomColor  ; color
	call drawThromb ; вызвать процедуру рисования ромба
	jmp fexit ; прыгнуть без условия на fexit

f1: ; квадрат
	push randomColor ; color ; https://s7a1k3r.narod.ru/4.html
	push randomX ; x
	push randomY ; y
	push 10 ; width
	push 10; height
	call drawSquare ; вызвать процедуру рисования квадрата
	jmp fexit ; прыгнуть без условия на fexit

f2: ; треугольник
	push randomX ; start point x
	push randomY ; start point y
	push 10  ; width
	push randomColor   ; color
	call drawTriangle ; вызвать процедуру рисования треугольника
	jmp fexit ; прыгнуть без условия на fexit

f3: ; круг
	mov radius, 5 ; Радиус нашего круга.
	mov ax, randomX
	mov xx0, ax    ; Номер строки, в котором будет находится центр круга
	mov ax, randomY
	mov yy0, ax    ; Номер столбца, в котором будет находится центр круга
	push randomColor
	call DrawCircle3  ; вызвать процедуру рисования круга


fexit:


; проверяем нажали ли мы клавишу или нет и записываем координаты мыши в x_mouse, y_mouse
DotGame:
	mov  bx, 0          ; Проверка на нажатие левой кнопки мыши (1 для проверки правой кноп).
	call GetMouseState
	and  bx, 00000001b  ; Проверка первого бита (бит 0).
	jz  DotGame        ; пока не кликнули левой кнопкой. повтор.

	mov  x_mouse, cx          ; сохраняем X и Y, потому что
	mov  y_mouse, dx          ; CX DX будут изменены                 

	call checkColorPixel

	cmp isNew, 1
	je ok1
	jmp DotGame

ok1: ; успех мы нажали на фигурку
	inc game_point
	mov randomColor, 0

	mov AX, 2 ; скрываем мышку
	INT 33h
    mov ax, 0B800h
    mov ax, 0A000h
    mov es, ax
    xor di, di  ; ES:0  это начало framebufferа
    xor ax, ax
    mov cx, 32000d
    cld
    rep stosw

	mov AX, 1 ; показываем мышку 
	INT 33h

	mov dl, score
	cmp game_point, dl ; тут количество фигур которое будет отображаться
	je stop_game
	mov isNew, 0 ; сброс чекпоинта


	jmp draw1 ; рисуем новую фигуру

stop_game:
    mov ah, 2Ch
    int 21h
    mov dl, 0
    xchg dh, dl

    xor ax, ax
    xor bx, bx

    mov al, cl
    mov bl, 60
    mul bl
    add ax, dx
    mov s2, ax

    mov ax, s2
    sub ax, s1
    mov si, offset numstr1
    call num2str

	; открыть существующий файл
	push offset results ; так передаём название файла
	call openFileRW ; открыть для чтения записи
	; jc error
	mov bx, ax
	call appendToEndFile
	push offset numstr1
	push 5
	push bx
	call writeFile
	call closeFile



	mov dx, offset game_end_message
	call printString
	call waitKey ; для задержки т.е. 

	call exit
	
 	
_TEXT ends

end start

