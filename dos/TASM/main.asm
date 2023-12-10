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
	buffer db 200 DUP(0), '$'          ; буффер на 20 символов
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
	x_center dw 300
	y_center dw 400
	y_value dw 0
	x_value dw 50
	decision dw 1
	colour db 2 ;1=blue


	; тут настройки для квадрата
	; начальная точка
	xs dw 0
	ys dw 0
	; конечная точка
	xe dw 50
	ye dw 50
	; цвет квадрата
	color_square dw 14


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
_DATA ends




_TEXT segment ; .code
	include addition.asm ; подключаем файл с функциями, можно удалить эту строку и вставить содержимое включаемго файла
	include geometry.asm ; функции с фигурами
	include time.asm     ; хранит функции для работы со временем
	include os.asm       ; создание, чтение, запись, дозапись
	include res.asm ; режимы для графики


	assume cs: _TEXT, ds: _DATA, es: _DATA, ss:_STACK
.startup
	mov ax, @data        ; установка в ds адреса
	mov ds, ax           ; Для указания сегмента данных используется регистр DS

	; открыть существующий файл
	push offset file1
	call openFileR
	; jc error ; 1

	; прочитать фалй
	push ax
	call readFile
	; jc error

	call closeFile
	; jc error ; 2


	; создать файл
	push offset file3
	call createFile
	; jc error ; 3

	; записать что нибудь в файл
	push offset number ; то что будем записыват
	push 4  ; так передём в функцию сколько символов записать
	push bx ; так передаём в функцию дескриптор файла
	call writeFile
	; jc error

	call closeFile
	; jc error



	
	; открыть существующий файл
	push offset file2 ; так передаём название файла
	call openFileRW ; открыть для чтения записи
	; jc error
	mov bx, ax

	call appendToEndFile


	push offset m2
	push m2len
	push bx
	call writeFile

	call closeFile



	; mov ah, 00 ; subfunction 0
	; mov al, 18 ; select mode 18 ;640 x 480
	; int 10h    ; call graphics interrupt

	call setResulutionVGA40 ; одна из функций чтения файла

	; push 14 ; color ; https://s7a1k3r.narod.ru/4.html
	; push 25 ; x
	; push 25 ; y
	; push 50 ; width
	; push 50; height
	; call drawSquare
	; add sp, 10

	mov cx, 13
loop1:
	push cx
	push color_square ; color ; https://s7a1k3r.narod.ru/4.html
	push xs ; x
	push ys ; y
	push xe ; width
	push ye; height
	call drawSquare

	pop cx
	add xs, 50
	add xe, 50
	dec color_square
	loop loop1

	inc counter
	cmp counter, 5
	JE scip_loop

	add ys, 50
	add ye, 50
	mov xs, 0
	mov xe, 50
	mov cx, 13
	jmp loop1


scip_loop:

	; call drawCircle
	call drawThromb


; 	push si
; 	mov  si, 2*10
; 	mov  ah, 0
; 	int  1Ah
; 	mov  bx, dx
; 	add  bx, si
; delay_loop:
; 	int  1ah
; 	cmp  dx, bx
; 	jne  delay_loop
; 	pop  si
; 	pop dx

    ; call drawThromb
	; mov al, 0

	call startTime
	; push 13 ; color ; https://s7a1k3r.narod.ru/4.html
	; push 40 ; x
	; push 40 ; y
	; push 10 ; width
	; push 10 ; height
	; call drawSquare
	; add sp, 10
	; push 14 ; color ; https://s7a1k3r.narod.ru/4.html
	; push 50 ; x
	; push 50 ; y
	; push 100 ; width
	; push 100 ; height
	; call drawSquare
	; add sp, 10

	; call drawThromb






	; call setResulutionVGA40




	; mov cx,32000d    ; you can write 320 * 200/2 in your source if you want
	; cld
	; xor ax,ax
	; rep stosw     


    ; call clearScreen
	; call setResulutionVBE42
	;Draw pixel
	; mov ax, 0c09h    ;09h = Blue
	; mov cx, 2 
	; mov dx, 3     
	; xor bx, bx   
	; int 10h


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


 
 	call exit
end

