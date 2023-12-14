; .386
.model small
.stack 200

_STACK  segment para stack
        db      1024 dup(?)
_STACK  ends
; include class.asm



_DATA segment; .data, DATASEG
	m1 db "Start reading: $"
	m1len equ $-m1                  ; способ получить длину m1 в байтах

	m2 db "Hello World!", 0Dh, 0Ah
	m2len equ $-m2

	kiril db 13, 10, "Введите какое-нибудь число: $"
	number db "f1234567890", 0Dh, 0Ah
	number_len equ $-number
	Data1 DB 48h,45h,4Ch,4Ch,4Fh,'$' ; создали массив $ - нуль терминатор
	sym1 db 03h
	dynamic_array DB 10h DUP (1)     ; динамический массив содержащий 10h значений
	dynamic_array2 db 10h DUP (38h)

	; для открытия файла
	; FileName db '1.asm', 0h
	OkStr db 'OK', '$'
	errorOpenStr db 'The Error happen on opening file', '$'
	errorReadStr db 'error on reading file', '$'
	errorWriteStr db 'error on writing file', '$'
	errorCloseStr db 'the Error on closig file', '$'
	errorCreateStr db 'The error happen on creating file', '$'
	successStr db 'All right', '$'
	buffer db 200 DUP(0), '$'          ; буффер на 200 символов
	buffer_len equ $-buffer


	; struct1 strstr{} ; создание объектов структуры
	; struct2 strstr{} ; создание объектов структуры

	; cyn firstclass{} ; создание объекта класса
	handle1 db 0

	filename db 'out.txt', 0
	inHandle dw ?

	; это используется для тестов с файлами, это переменные в которых хранится название файлов
	file1 db 'file1.txt', 0
	file2 db 'file2.txt', 0
	file3 db 'file3.txt', 0
	file4 db 'file4.txt', 0

	; для отрисовки ромба
	x_center dw 50
	y_center dw 75
	y_value dw 0
	x_value dw 10
	decision dw 1
	colour db 2 ; blue


	; тут настройки для квадрата
	xs dw 0 	; начальная точка (xs, ys)
	ys dw 0
	xe dw 50 	; конечная точка (xe, ye)
	ye dw 50

	color_square dw 14 	; цвет квадрата


	; для цикла
	counter dw 0


	; это используется для работы со временм, из этого много уберется, когда приведу программу в нормальный вид
	;возможные цвета символов и фона
    Black           equ     0
    Blue            equ     1
    Green           equ     2
    Cyan            equ     3
    Red             equ     4
    Magenta         equ     5
    Brown           equ     6
    LightGray       equ     7
    ;возможные цвета символов
    DarkGray        equ     8
    LightBlue       equ     9
    LightGreen      equ     10
    LightCyan       equ     11
    LightRed        equ     12
    LightMagenta    equ     13
    Yellow          equ     14
    White           equ     15

    BkColor         equ     Cyan                    ;цвет фона
    FrColor         equ     LightRed                ;цвет символа
    Color           db      BkColor*16+FrColor

    MsgTime         db      '00:00:00 '
    MsgDate         db      '00/00/0000'
    MsgLen          dw      $-MsgTime
    ;позиция начала вывода строки
    X               db      0
    Y               db      0
    ;параметры видеорежима
    VideoMode       db      ?
    VideoPage       db      ?
    ;Дата и время
    Day             db      ?
    Month           db      ?
    Year            dw      ?
    Hours           db      ?
    Minutes         db      ?
    Seconds         db      ?

    CrLf            db      0Dh, 0Ah, '$'


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
	score   dw 0
	x_mouse       dw ?          ;MOUSE CLICK X.
	y_mouse       dw ?          ;MOUSE CLICK Y.
	msj     db 'score!$'
	hyphen  db '-$'
	clear   db '       $' ;CLEAR LINE.
	numstr  db '$$$$$$'    ;STRING FOR 4 DIGITS.

	random dw ?
	randomX dw ?
	randomY dw ?
	randomColor dw ?
	randomFigure dw ?

	HelloString   DB   'HELLO1!',0dh,0ah,0

	isNew db ?

	game_point db 0

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



	; без знака
	; 8bit 
	; mov cl, -3 ; #1
	; mov bh, 2 ; #2
	; mov al, bh
	; mul cl ; #2 * #1 -> res in ax

	; ; умножение
	; mov ax, 200
	; mul ax ; АХ*АХ —> DX:AX
	; mov dx, ax
	; add dx, '0'



	; call getRandom
	; call exit


	; call printSymbol
	; call exit

	; ; открыть существующий файл
	; push offset file1
	; call openFileR
	; ; jc error ; 1

	; ; прочитать фалй
	; push ax
	; call readFile
	; ; jc error

	; call closeFile
	; ; jc error ; 2


	; ; создать файл
	; push offset file3
	; call createFile
	; ; jc error ; 3

	; ; записать что-нибудь в файл
	; push offset number ; то что будем записыват
	; push 4             ; так передём в функцию сколько символов записать
	; push bx            ; так передаём в функцию дескриптор файла
	; call writeFile
	; ; jc error

	; call closeFile
	; ; jc error



	
	; ; открыть существующий файл
	; push offset file2 ; так передаём название файла
	; call openFileRW ; открыть для чтения записи
	; ; jc error
	; mov bx, ax

	; call appendToEndFile


	; push offset m2
	; push m2len
	; push bx
	; call writeFile

	; call closeFile




	
	; mov ah, 00 ; subfunction 0
	; mov al, 18h ; select mode 18 ;640 x 480
	; int 10h    ; call graphics interrupt
	; mov ax, 13h 
	; int 10h                 ;mode 13h 

	; call DotOne

; проверяем нажали ли мы клавишу или нет и записываем координаты мыши в x_mouse, y_mouse

	; call drawRandomFigure

draw1:
	call setResulutionVGA40 ;
	call SetCursor ; mouse input

	push 620
	call getRandom
	mov ax, random
	mov randomX, ax

	push 460
	call getRandom
	mov ax, random
	mov randomY, ax

	push 16
	call getRandom
	mov ax, random
	mov randomColor, ax

	push 4
	call getRandom
	mov ax, random
	mov randomFigure, ax


	cmp randomFigure, 1
	je f0

	cmp randomFigure, 2
	je f1

	cmp randomFigure, 3
	je f2

f0:
	push randomX ; x
	push randomY ; y
	push 5  ; половина диагонали по оси y
	push randomColor  ; color
	call drawThromb
	jmp fexit
f1:
	push randomColor ; color ; https://s7a1k3r.narod.ru/4.html
	push randomX ; x
	push randomY ; y
	push 10 ; width
	push 10; height
	call drawSquare
	jmp fexit
f2:
	push randomX ; start point x
	push randomY ; start point y
	push 10  ; width
	push randomColor   ; color
	call drawTriangle

fexit:

	; push 16
	; call getRandom
	; mov ax, random

	; mov si, offset numstr
	; call number2string
	; mov dx, offset numstr
	; call printString


	; mov radius, 20 ; Радиус нашего круга.
	; mov xx0, 180    ; Номер строки, в котором будет находится центр круга
	; mov yy0, 180    ; Номер столбца, в котором будет находится центр круга
	; call DrawCircle3



; проверяем нажали ли мы клавишу или нет и записываем координаты мыши в x_mouse, y_mouse
DotGame:
	mov  bx, 0          ;CHECK RIGHT BUTTON (USE 0 TO CHECK LEFT BUTTON).
	call GetMouseState
	and  bx, 00000001b  ;CHECK SECOND BIT (BIT 1).
	jz   DotGame        ;NO RIGHT CLICK. REPEAT.

	mov  x_mouse, cx          ;PRESERVE X AND Y BECAUSE
	mov  y_mouse, dx          ;CX DX WILL BE DESTROYED.                  
	; call display_coords
	; push randomColor
	call checkColorPixel

	cmp isNew, 1
	je ok1
	jmp DotGame

ok1: ; успех мы нажали на фигурку
	inc game_point
	cmp game_point, 10
	je stop_game
	mov isNew, 0 ; сброс чекпоинта
	jmp draw1 ; рисуем новую фигуру
	; jmp DotGame

stop_game:
	call waitKey ; для задержки т.е. 
	; cmp  bx, 01 ; check if left mouse was clicked
	; je   Check_X_Cords
	; check if the player clicked the dot cords

; ScoreLabel:
; 	inc [score]               
; 	;DISPLAY "SCORE!".
; 	mov ah, 9
; 	mov dx, offset msj
; 	int 21h
; 	jmp DotGame       ; REPEAT.
	; call drawCircle
	; call drawCircle1




	; if nothing happy
	call exit


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
 	
_TEXT ends

end start

