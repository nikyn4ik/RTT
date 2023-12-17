
drawSquare proc
	push bp
	mov bp, sp


	mov cx, [bp+10]  ; получаем из буфера точку x, записываем в cx
	mov dx, [bp+8]   ; получаем из буфера точку y, записываем в dx
	mov al, [bp+12]  ; в al запишем цвет который отправили
	mov ah, 0ch      ; функция рисования пикселя

	mov si, [bp+6]  ; в si запишем ширину
	add si, [bp+10] ; добавим к ширине точку старта: width + xstart
	mov di, [bp+4]  ; в si запишем высоту
	add di, [bp+8] 	; добавим к высоте точку старта: height + ystart

	colcount:
	inc cx ; увеличиваем на 1 точку старта

	int 10h ; нарисовать
	cmp cx, si   ;  пока точка старта не станет равна точке конца
	JNE colcount ; пока не равно выполняется

	
	mov cx, [bp+10]  ; сбросить cx в началоо т.е. x = точке старта x
	inc dx           ; увеличиваем y ; плоскость в компьютерах идет: слева на прова, и сверху в низ
	cmp dx, di   ; сравниваем y и вторую точку, которая конец
	JNE colcount ; если не равно то продолжаем цикл

	mov sp, bp
	pop bp
	ret 10 ; размер каждого параметра в ms-dos равен 2 байтам: 16 битам
	; в эту функцию передали 5 параметров, значит всего нужно вернуть 10 байт
drawSquare endp



drawTriangle proc
	push bp
	mov bp, sp

	mov cx, [bp+10]    ; x начало
	mov di, cx         ; сохраняем значение x начала в di
	mov si, cx         ; сохраняем значение x начала в si
	add si, [bp+6]     ; x точка старта + ширина = конечная точка по оси x; тут мы записали число до которого будем рисовать пиксели по оси x
	mov dx, [bp+8]     ; y точка начала
	mov al, [bp+4]     ; в al запишем цвет
	mov ah, 0ch        ; функция нарисовать пиксель
	mov bx, 0          ; в bx записали ноль
looph:
	int 10h	; нарисовать пиксель
	inc cx  ; увеличить координату x
	cmp cx, si ; пока x меньше конечной точки
	JB looph


	push ax    ; кладём в стэк значение регистра ax ; потому что этот регистр хранит функцию которая рисует пиксель и цвет пикселя
	mov ax, dx ; запишем в ax координату y
	mov bl, 2  ; запишем в bl 2
	div bl     ; ah содержит остаток от деления ax на bl
	; TEST dx, 4
	cmp ah, 0
	JZ evn ; если остаток от деления 0
	JNZ odd ; не ноль
evn:
	add di, 1  ; увеличиваем на 1 di который хранит самую левую точку равностороннего треугольник x
	dec si     ; уменьшаем si на 1 который хранит самую правую точку равностороннего треугольник x
odd:
	dec dx     ; уменьшаем y - поднимаемся вверх
	mov cx, di ; изменяем стартовую точку x

	pop ax ; достать последнее записанное в стэк число и записать его в ax

	cmp si, cx ; если стартовая точка равна конечной точке, или мы дошли до вершины треугольника то выходим
	JE quit

	jmp looph ; иначе начинаем цикл заного


quit:
	mov sp, bp
	pop bp
	ret 8
drawTriangle endp




drawThromb proc ; рисуется также как и треугольник; он состоит из 2 треугольников которые вырастают из одной общей стороны
	push bp
	mov bp, sp

	mov cx, [bp+10] ; координата центра x
	mov dx, [bp+8]  ; координата центра y
	mov si, 0
	mov di, [bp+6]  ; половина диаметра по оси x

	push 0
	push di
	push si

	mov al, [bp+4]  ; цвет помещам в регистр al
	mov ah, 0ch     ; нарисовать  пиксель


@@right_and_left:
	push cx
	sub cx, si
	int 10h
	pop cx

	push cx
	add cx, si
	int 10h
	pop cx

	inc si
	cmp si, di
	jne @@right_and_left


	cmp [bp-2], 0
	je @@decrease
	jne @@increase

@@decrease:
	dec dx
	jmp @@next_step
@@increase:
	inc dx
	jmp @@next_step
	
@@next_step:
	push ax
	push bx
	mov ax, dx
	mov bl, 2
	div bl
	cmp ah, 0
	jz @@evn
	jnz @@odd
@@evn:
	dec di
@@odd:
	mov si, [bp+14]
	mov [bp+14], si
	pop bx
	pop ax



	cmp si, di
	je @@quit


	jmp @@right_and_left



@@quit:
	cmp [bp-2], 1
	jne @@two
	je @@stop
@@two:
	mov [bp-2], 1
	mov si, [bp-6]
	mov di, [bp-4]
	mov dx, [bp+8]
	jmp @@right_and_left


@@stop:
	mov sp, bp
	pop bp
	RET 10
drawThromb endp






Plot proc
	push bp
	mov bp, sp

	mov Ah, 0Ch		; Функция отрисовки точки
	mov al, [bp+4]  ; Цвет
	int 10h			; Нарисовать точку

	mov sp, bp
	pop bp
	ret 2
Plot endp

drawCircle3 proc
	push bp
	mov bp, sp

    mov xx, 0 ; в xx поместить 0
	mov ax, radius ; в ax поместить radius
    mov yy, ax ; в yy поместить ax
    mov delta, 2 ; в delta поместить 2
	mov ax, 2 ;	в ах поместить 2
	mov dx, 0 ; в dх поместить 0
	imul yy ; dx:ax = ax * yy ; imul умножение со знаком
	sub delta, ax ; delta = delta - ax 
	mov eror, 0 ; в error помещаем 0
	jmp ccicle ; прыгаем без условий на метку ccicle

finally: 
	; завершение программы
	mov sp, bp
	pop bp
	ret 2 
ccicle:
	mov ax, yy ; в ax помещаем yy
	cmp ax, 0 ; сравниваем ax с нулём 
	jl  finally ; если ax меньше 0 то прыгаем на метку 	finally

	; первая точка сверху справа окружности
    mov cx, xx0 ; поместить в cx, xx0
	add cx, xx  ; прибавить к cx xx; cx = cx + xx
	mov x1, cx  ; поместить в x1, cx
	mov dx, yy0 ; поместить в dx, yy0
	sub dx, yy  ; вычесть из dx, yy
	mov y1, dx  ; поместить в y1 dx
	push [bp+4] ; поместить в стек цвет для отрисовки - параметр функции
	call Plot   ; вызвать отрисовку пикселей

	; первая точка снизу справа окружности
	mov cx, xx0 ; поместить в xx0
	add cx, xx  ; добавить к cx, xx
	mov x2, cx  ; поместить в x2, cx
	mov dx, yy0 ; поместить в dx, yy0
	add dx, yy  ; прибавить к dx, yy
	mov y2, dx  ; поместить в y2, dx
	push [bp+4] ; поместить в стек цвет для отрисовки - параметр функции
	call Plot   ; вызвать отрисовку пикселей


qright1:           ; тут происходит заполнение окружности цветом между точкми x1, y1 и x2, y2 т.е.заполняется правая половина от центра вправо
	inc y1
	mov cx, x1
	mov dx, y1
	push [bp+4]
	call Plot

	cmp dx, y2
	jae qright2    ; если dx больше или равен y2 то завершаем цикл и прыгаем на qright2
	jmp qright1

qright2: ; то есть когда мы встаём на эту метку мы заполнили только одну линию вертикальную


	; первая точка сверху справа окружности
	mov cx, xx0
	sub cx, xx
	mov x1, cx
	mov dx, yy0
	sub dx, yy
	mov y1, dx
	push [bp+4]
	call Plot

	; первая точка снизу справа окружности
	mov cx, xx0
	sub cx, xx
	mov x2, cx
	mov dx, yy0
	add dx, yy
	mov y2, dx
	push [bp+4]
	call Plot


qleft1: ; в этом цикле мы заполняем растояние между этими двумя точками но только от центра влево
	inc y1
	mov cx, x1
	mov dx, y1
	push [bp+4]
	call Plot

	cmp dx, y2
	jae qleft2
	jmp qleft1

qleft2: ; то есть когда мы встаём на эту метку мы заполнили только одну линию вертикальную


	mov ax, delta ; помещаем в ax delta
	mov eror, ax  ; помещаем в eror ax
	mov ax, yy    ; помещаем в ax yy
	add eror, ax  ; прибавляем к eror ax
	mov ax, eror  ; в ax помещаем eror
	mov dx, 0     ; в dx помещаем 0
	mov bx, 2     ; в bx помещаем 2
	imul bx       ; знаковое умножение ax на bx
	sub ax, 1     ; уменьшаем ax на 1
	mov eror, ax  ; помещаем в eror ax
	cmp delta, 0  ; сравниваем delta и 0
	jg sstep      ; если delta больше 0 прыгаем на sstep в отличии от ja может работать с отрицательными числами
	je sstep      ; если delta равен 0 прыгаем на sstep
	cmp eror, 0   ; сравниваем eror, 0
	jg  sstep     ; если eror больше 0 то прыгаем на sstep
	inc xx        ; увеличиваем xx на 1
	mov ax, 2     ; помещаем в ax 2
	mov dx, 0     ; помещаем в dx 0
	imul xx       ; знаковое умножение. умножаем ax на xx
	add ax, 1     ; в dx:ax будет результат ax*xx 
	add delta, ax ; к delta прибавляем ax
    jmp ccicle    ; прыгаем в самое начало возле метки finally
sstep:
	mov ax, delta ; поместиь в ax delta
	sub ax, xx    ; вычесть из ax xx
	mov bx, 2     ; поместиь в bx 2
	mov dx, 0     ; поместиь в dx 0
	imul bx       ; знаковое умножение. ax * bx результат запишется в dx:ax
	sub ax, 1     ; вычесть из ax 1
	mov eror, ax  ; поместиь в eror ax
	cmp delta, 0  ; сравниваем delta и 0
	jg tstep      ; если delta больше 0 то прыгаем на tstep. JG может работать с отрицательными числами
	cmp eror, 0   ; сравниваем eror, 0
	jg tstep      ; если eror больше 0 то прыгаем на tstep. JG может работать с отрицательными числами
	inc xx        ; увеличиваем xx на 1
	mov ax, xx    ; поместить в ax xx
	sub ax, yy    ; вычесть из ax yy
	mov bx, 2     ; поместить в bx 2
	mov dx, 0     ; поместить в dx 0
	imul bx       ; dx:ax = ax*bx ;знаковое умножение
	add delta, ax ; прибавить к delta ax
    dec yy        ; уменьшить на 1 yy
	jmp ccicle    ; прыгнуть на метку с самого начала после метки finally
tstep:
	dec yy        ; уменьшить yy
    mov ax, 2     ; поместить в ax 2
	mov dx, 0     ; поместить в dx 0
	imul yy       ; умножить ax на yy результат в dx:ax ; знаковое умножение
	mov bx, 1     ; поместить в bx 1
	sub bx, ax    ; вычесть из bx ax
	add delta, bx ; добавить к delta bx
	jmp ccicle    ; прыгаем в самое начало на метку ccicle после метки finally
drawCircle3 endp

