model small
stack 512


include class.asm



.data
	m1 db "Welcome friends. The message is print successfully $"
	msglen equ $-m1

	kiril db 13, 10, "Введите какое-нибудь число: $"
	number db "1234567890 $"
	Data1 DB 48h,45h,4Ch,4Ch,4Fh,'$' ; создали массив
	sym1 db 03h
	dynamic_array DB 10h DUP (1)
	dynamic_array2 db 10h DUP (38h)

	; для открытия файла
	FileName db '1.asm', 0h
	OkStr db 'OK', '$'
	ErrorStr db 'ERROR', '$'

	Buffer db 14h dup (0), '$'            ; буффер на 20 символов

	struct1 strstr{} ; создание объектов структуры
	struct2 strstr{} ; создание объектов структуры

	cyn firstclass{} ; создание объекта класса

.code
	include addition.asm ; подключаем файл с функциями, можно удалить эту строку и вставить содержимое включаемго файла

.startup
	mov ax, @data       ; установка в ds адреса
	mov ds, ax          ; Для указания сегмента данных используется регистр DS

	jmp Scip

	call openFile
	jc Error    ; проверить флаг на ошибку; Перейти при наличии переноса CF = 1
	mov bx, ax  ; в bx записываем дескриптор файла, который открывали, bx понадобится для правильного закрытия файла
	
	call readFile ; вызываем функцию чтения файла
	jc Error    ; проверить флаг на ошибку; Перейти при наличии переноса CF = 1
	


	call closeFile
	mov dx, offset OkStr
	jmp write








Error:
	mov dx, offset ErrorStr

Write:
	call printString
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
	mov cx, 10
p1:		; метка p1
	dec cx
	push cx
	mov bx, 1
	mov cx, 21
	mov dx, offset dynamic_array2
	mov dynamic_array2[15], '$'
	call printString
	; mov ah, 40h
	; int 21h
	pop cx
	jcxz exit ; если регистор cx равен 0, то прыгай на exit
	jmp p1 ; если условие выше не сработало то прыгаем на метку p1

	


	; тестирую второй цикл
	mov cl, 6 ; сколько будед итераций
writeLoop:
	mov dx, offset number ; то что будем печатать 
	call printString
loop writeLoop        ; она будет переводить нас на указанную метку до тех пор пока регистр CX не станет равный нулю.

	; открытие файла
	; AH 	3dH
	; AL 	Режим доступа (0 = чтение, 1 = запись, 2 = оба, и т.д.)
	; DS:DX 	адрес ASCII  Строки с нулевым символом в конце
	; Возврат
	; AX 	код ошибки если CF установлен к CY
	; 	Дескриптор файла, если нет ошибок




	mov cl, 10            ; настройка счётчик
	mov si, offset number ; адрес строки загружаем в si
	cld                   ; направление
loop1:
	lodsb                 ; загрузить символ ; это специальная команда, которая загружает 1 байт в регистр AL по адресу DS:SI и изменяет регистр SI в зависимости от флага направления.
	mov dl, al            ; для вывода
	call printSymbol      ; выводим символ
loop loop1


Scip:
	std ; установка флага направления
	cld ; очистка флага направления



	mov ax, 'F'
	push ax
	mov ax, 'I'
	push ax
	mov ax, 'R'
	push ax
	mov ax, 'S'
	push ax
	mov ax, 'T'
	push ax ; Вот эта буква как раз в самом верху сейчас. Но в самом верху стека или внизу памяти. SP указывает на низ в памяти

	mov cx, 5 ; настраиваем счётчик
	mov bp, sp ; настраиваем bp ; 
nLoop:
	mov dx, [bp] ; берём значение
	call printSymbol
	add bp, 2
loop nLoop


	; тестирую порты и звуки
	mov ax, @data       ; установка в ds адреса
	mov ds, ax 
	sound

	; тестирую структуры
	mov dx, offset struct1.str1
	call printString
	mov dx, offset struct1.str2
	call printString

	; тестирую классы
	mov dx, offset cyn.username
	call printString
	mov dx, offset cyn.age
	call printString

	mov ax, @data       ; установка в ds адреса
	mov ds, ax 

	; тестирую методы
	call cyn method printchar ; метод без параметра

	; call cyn method printchar pascal, '&', '*'
	; call fun2 

exit:
	mov ah, 04ch ; функция DOS выхода из программы
	mov al, 0h 	; код возврата
	int 21h ; Вызов DOS остановка программы

end

