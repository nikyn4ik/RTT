; .386
; 16 - битная программа запускать на dosbox
.model small
.stack 200  ;стек (минимум 200 байт надо), но эта программа будет работать и так

_STACK  segment para stack
    db 1024 dup(?) ; тоже размер стека
_STACK  ends
; include class.asm



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
	XCords1 dw 160        ;COORDS OF PIXEL AT
	YCords1 dw 100        ;SCREEN CENTER.
	x_mouse       dw ?          ;MOUSE CLICK X.
	y_mouse       dw ?          ;MOUSE CLICK Y.
	hyphen  db '-$'
	clear   db '       $' ;CLEAR LINE.
	numstr  db '$$$$$$'    ;STRING FOR 5 DIGITS.
	numstr1 db 3 DUP (' '), 0Dh, 0Ah  ;STRING FOR 5 DIGITS.

	random dw ?
	randomX dw ?
	randomY dw ?
	randomColor dw ?
	randomFigure dw ?

	isNew db ?

	game_point db 0
	game_end_message db "Finish $" 
	score db 20 ; попыток 

	s1 dw 0
	s2 dw 0

	x1 dw 0 ; 
	y1 dw 0

	x2 dw 0
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
    mov si, offset numstr
    call number2string
    mov dx, offset numstr
    call printString


    ; call exit

	call setResulutionVGA40 ;
	call SetCursor ; mouse input
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
	mov  bx, 0          ;CHECK RIGHT BUTTON (USE 0 TO CHECK LEFT BUTTON).
	call GetMouseState
	and  bx, 00000001b  ;CHECK SECOND BIT (BIT 1).
	jz   DotGame        ;NO RIGHT CLICK. REPEAT.

	mov  x_mouse, cx          ;PRESERVE X AND Y BECAUSE
	mov  y_mouse, dx          ;CX DX WILL BE DESTROYED.                  

	; push randomColor
	call checkColorPixel

	cmp isNew, 1
	je ok1
	; call display_coords
	jmp DotGame

ok1: ; успех мы нажали на фигурку
	inc game_point
	; jmp ScoreLabel
	mov randomColor, 0

	mov AX, 2 ; скрываем мышку
	INT 33h
	; mov         ax,000Ch
 ;    mov         cx,0000h     ; удалить обработчик событий мыши
 ;    int         33h
    mov ax, 0B800h
    mov ax, 0A000h
    mov es, ax
    xor di, di  ; ES:0 is the start of the framebuffer
    xor ax, ax
    mov cx, 32000d
    cld
    rep stosw

	mov AX, 1 ; показываем мышку 
	INT 33h
	; call exit

	mov dl, score
	cmp game_point, dl ; тут количество фигур которое будет отображаться
	je stop_game
	mov isNew, 0 ; сброс чекпоинта


	jmp draw1 ; рисуем новую фигуру
	; jmp DotGame

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
	; cmp  bx, 01 ; check if left mouse was clicked
	; je   Check_X_Cords2
	; check if the player clicked the dot cords

	call exit
	
 	
_TEXT ends

end start



; call drawCircle
	; call drawCircle1
; ScoreLabel:
; 	inc [score]               
; 	;DISPLAY "SCORE!".
; 	mov ah, 9
; 	mov dx, offset msj
; 	int 21h

; 	jmp DotGame

	; if nothing happy



	; push offset file1
	; call openFile
	; jc errorOpen

	; push ax
	; call readFile
	; jc errorRead

	; call closeFile
	; jc errorClose
; error:
; 	mov dx, offset errorCreateStr
; 	call printString
; 	call exit


; printHelloWorld proc
; 	mov dx, offset m2
; 	printString
; printHelloWorld endp

; --- создание файла ---
	; mov cx, 0
	; call createFile
	; jc Error

; --- сохранить дескриптор файла в bx.
	; mov bx, ax

; --- запись в файл ----
	; push offset number ; то что будем записывать
	; push 8    ; сколько байт будем записывать
	; push bx            ; толкаем в стэк регистр хранящий дескриптор файла

	; call writeFile
	; jc Error
	; mov bx, ax
	; call closeFile

	; mov cx, 0
	; push offset outfile
	; call openFile
	; jc Error
	; mov bx, ax

	; call readFile
	; jc Error

	; call closeFile


	; jc Error    ; проверить флаг на ошибку; Перейти при наличии переноса CF = 1
	; mov bx, ax  ; в bx записываем дескриптор файла, bx понадобится для дальнейшего чтения записи и закрытия
	



	; mov dx, offset m1
	; call printString

; тут рассматриваю динамические массивы
	; mov dx, offset dynamic_array
	; call printString

	; mov dx, offset dynamic_array2
	; mov dynamic_array2[15], '$' ; помещаем конец строки в массив чтобы не показыал всякую ересь
	; call printString

	; jmp exit           ; Использование этого оператора позволяет нам перемещаться по коду. То есть фактически команда JMP меняет регистр IP

	; mov dl, sym1
	; call printSymbol




; тестирую первый цикл
; 	mov cx, 10
; p1:		; метка p1
; 	dec cx
; 	push cx
; 	mov bx, 1
; 	mov cx, 21
; 	mov dx, offset dynamic_array2
; 	mov dynamic_array2[15], '$'
; 	call printString
; 	; mov ah, 40h
; 	; int 21h
; 	pop cx
; 	jcxz Exit ; если регистор cx равен 0, то прыгай на exit
; 	jmp p1 ; если условие выше не сработало то прыгаем на метку p1

	


; тестирую второй цикл
; 	mov cl, 6 ; сколько будед итераций
; writeLoop:
; 	mov dx, offset number ; то что будем печатать 
; 	call printString
; loop writeLoop        ; она будет переводить нас на указанную метку до тех пор пока регистр CX не станет равный нулю.

	; открытие файла
	; AH 	3dH
	; AL 	Режим доступа (0 = чтение, 1 = запись, 2 = оба, и т.д.)
	; DS:DX 	адрес ASCII  Строки с нулевым символом в конце
	; Возврат
	; AX 	код ошибки если CF установлен к CY
	; 	Дескриптор файла, если нет ошибок




; 	mov cl, 10            ; настройка счётчик
; 	mov si, offset number ; адрес строки загружаем в si
; 	cld                   ; направление
; loop1:
; 	lodsb                 ; загрузить символ ; это специальная команда, которая загружает 1 байт в регистр AL по адресу DS:SI и изменяет регистр SI в зависимости от флага направления.
; 	mov dl, al            ; для вывода
; 	call printSymbol      ; выводим символ
; loop loop1


; Scip:
; 	std ; установка флага направления
; 	cld ; очистка флага направления



; 	mov ax, 'F'
; 	push ax
; 	mov ax, 'I'
; 	push ax
; 	mov ax, 'R'
; 	push ax
; 	mov ax, 'S'
; 	push ax
; 	mov ax, 'T'
; 	push ax ; Вот эта буква как раз в самом верху сейчас. Но в самом верху стека или внизу памяти. SP указывает на низ в памяти

; 	mov cx, 5 ; настраиваем счётчик
; 	mov bp, sp ; настраиваем bp ; 
; nLoop:
; 	mov dx, [bp] ; берём значение
; 	call printSymbol
; 	add bp, 2
; loop nLoop


; ; тестирую порты и звуки
; 	mov ax, @data       ; установка в ds адреса
; 	mov ds, ax 
; 	sound

; тестирую структуры
; 	mov dx, offset struct1.str1
; 	call printString
; 	mov dx, offset struct1.str2
; 	call printString

; ; тестирую классы
; 	mov dx, offset cyn.username
; 	call printString
; 	mov dx, offset cyn.age
; 	call printString

; 	mov ax, @data       ; установка в ds адреса
; 	mov ds, ax 

; ; тестирую методы
; 	call cyn method printchar ; метод без параметра
	; call cyn method printchar pascal, '&', '*'
	; call fun2 

	; call clear_screen


 
 	; call exit