.model small ; модель памяти
; https://devotes.narod.ru/Books/3/ch03_03b.htm - модели памяти


; SMALL — код размещается в одном сегменте, 
; а данные и стек — в другом (для их описания могут применяться разные сегменты, но объединенные в одну группу). 
; Эту модель памяти также удобно использовать для создания программ на ассемблере;

; эта упрощенная директива создания сегмента стэка
.stack 200 ; указывам размер стэка


; Стандартные директивы сегментации
; Стандартно сегменты на языке Assembler описываются с помощью  директивы SEGMENT.
; Синтаксическое описание сегмента представляет собой следующую конструкцию
; <имя сегмента> SEGMENT [тип выравнивания] [тип комбинирования]
;         [класс сегмента] [тип размера сегмента]
; <тело сегмента>
; <имя сегмента>  ENDS

; Стандартные директивы сегментации
_STACK segment para public 'stack'
	db 1024 dup(?) ; выделяет 200 байт для системного стека.
_STACK ends

; Стандартные директивы сегментации
_DATA segment; .data, DATASEG
	buffer db 200 DUP(0), '$'          ; буффер на 200 символов
	buffer_len equ $-buffer
	results db 'results.txt', 0 

	; круг
	eror dw ?
	xx dw ?
	yy dw ?
	xx0 dw ?
	yy0 dw ?
	delta dw ?
	radius dw ?

	; мышь
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

	game_point db 0 ; счётчик пройденных уровней
	game_end_message db "Finish $" 
	score db 20 ; максимальное число попыток

	s1 dw 0 ; певая запись времени
	s2 dw 0 ; вторая запись времени

	x1 dw 0 ; эти переменные используются для закрашивания окружности ; первая точка
	y1 dw 0

	x2 dw 0 ; для закрашивания 
	y2 dw 0

_DATA ends




; Стандартные директивы сегментации
_TEXT segment ; .code - это упрощенная директива сегментации
	include geometry.asm ; отрисовка геометрических фигур
	include os.asm       ; работа с файлами, преобразование числа в строку, генератор случайных чисел
	include res.asm      ; фключение графического режима
	include keyboard.asm ; тут функция - нажмите любую клавишу чтобы выйти (waitKey)
	include mouse.asm    ; мышь, проверка кликнутого пикселя


	; С помощью директивы ASSUME можно сообщить транслятору, какой сегмент, 
	; к какому сегментному регистру «привязан», или, говоря боле точно, 
	; в каком сегментном регистре хранится адрес сегмента..
	assume cs:_TEXT,ds:_DATA,es:_DATA,ss:_STACK
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
	; jmp f0 ; (заменяем метку на которую хотим прыгать, например, если круг, то f3)
	cmp randomFigure, 0
	je f0 ; прыгнуть на метку с ромбом

	cmp randomFigure, 1
	je f1 ; прыгнуть на метку с квадратом

	cmp randomFigure, 2
	je f2 ; прыгнуть на метку с треугольником

	cmp randomFigure, 3
	je f3 ; прыгнуть на метку с кргом

f0: ; ромб
	push randomX ; x начальная точка
	push randomY ; y начальная точка
	push 7  ; половина диагонали по оси x
	push randomColor  ; цвет
	call drawThromb ; вызвать процедуру рисования ромба
	jmp fexit ; прыгнуть без условия на fexit

f1: ; квадрат
	push randomColor ; цвет ; https://s7a1k3r.narod.ru/4.html
	push randomX ; x начальная точка
	push randomY ; y начальная точка
	push 14      ; ширина
	push 14      ; высота
	call drawSquare ; вызвать процедуру рисования квадрата
	jmp fexit ; прыгнуть без условия на fexit

f2: ; треугольник
	push randomX       ; начальная точка x
	push randomY       ; начальная точка y
	push 14            ; ширина
	push randomColor   ; цвет
	call drawTriangle  ; вызвать процедуру рисования треугольника
	jmp fexit          ; прыгнуть без условия на fexit

f3: ; круг
	mov radius, 7     ; Радиус нашего круга.
	mov ax, randomX
	mov xx0, ax       ; Номер строки, в котором будет находится центр круга
	mov ax, randomY
	mov yy0, ax       ; Номер столбца, в котором будет находится центр круга
	push randomColor  ; цвет
	call DrawCircle3  ; вызвать процедуру рисования круга


fexit:


; проверяем нажали ли мы клавишу или нет и записываем координаты мыши в x_mouse, y_mouse
DotGame:
	mov  bx, 0              ; Проверка на нажатие левой кнопки мыши (1 для проверки правой кноп).
	call GetMouseState
	and  bx, 1              ; Проверка первого бита (бит 0).
	jz  DotGame             ; пока не кликнули левой кнопкой. повтор.

	mov  x_mouse, cx        ; сохраняем X и Y, потому что
	mov  y_mouse, dx        ; CX DX будут изменены                 

	call checkColorPixel

	cmp isNew, 1
	je ok1
	jmp DotGame

ok1:                         ; успех мы нажали на фигурку
	inc game_point
	mov randomColor, 0

	call hideMouse ; скрыть мышь
	
	call clearScreen ; очистить экран

	call showMouse ; показать мышь


	mov dl, score
	cmp game_point, dl ; тут количество фигур которое будет отображаться
	je stop_game ; если game_point равен dl, то прыгаем на stop_game, иначе записыаем isNew 0 и отрисовываем новую картинку
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


