
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




drawThromb proc
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

    mov xx, 0
	mov ax, radius
    mov yy, ax
    mov delta, 2
	mov ax, 2
	mov dx, 0
	imul yy
	sub delta, ax
	mov eror, 0
	jmp ccicle

finally: 

	mov sp, bp
	pop bp
	ret 2
ccicle:
	mov ax, yy
	cmp ax, 0
	jl  finally

    mov cx, xx0
	add cx, xx
	mov x1, cx
	mov dx, yy0
	sub dx, yy
	mov y1, dx
	push [bp+4]
	call Plot

	mov cx, xx0
	add cx, xx
	mov x2, cx
	mov dx, yy0
	add dx, yy
	mov y2, dx
	push [bp+4]
	call Plot


qright1:
	inc y1
	mov cx, x1
	mov dx, y1
	push [bp+4]
	call Plot

	cmp dx, y2
	jae qright2
	jmp qright1

qright2:



	mov cx, xx0
	sub cx, xx
	mov x1, cx
	mov dx, yy0
	sub dx, yy
	mov y1, dx
	push [bp+4]
	call Plot

	mov cx, xx0
	sub cx, xx
	mov x2, cx
	mov dx, yy0
	add dx, yy
	mov y2, dx
	push [bp+4]
	call Plot


qleft1:
	inc y1
	mov cx, x1
	mov dx, y1
	push [bp+4]
	call Plot

	cmp dx, y2
	jae qleft2
	jmp qleft1

qleft2:


	mov ax, delta
	mov eror, ax
	mov ax, yy
	add eror, ax
	mov ax, eror
	mov dx, 0
	mov bx, 2
	imul bx
	sub ax, 1
	mov eror, ax
	cmp delta, 0
	jg sstep
	je sstep
	cmp eror, 0
	jg  sstep
	inc xx
	mov ax, 2
	mov dx, 0
	imul xx
	add ax, 1
	add delta, ax
    jmp ccicle
sstep:
	mov ax, delta
	sub ax, xx
	mov bx, 2
	mov dx, 0
	imul bx
	sub ax, 1
	mov eror, ax
	cmp delta, 0
	jg tstep
	cmp eror, 0
	jg tstep
	inc xx
	mov ax, xx
	sub ax, yy
	mov bx, 2
	mov dx, 0
	imul bx
	add delta, ax
    dec yy
	jmp ccicle
tstep:
	dec yy
    mov ax, 2
	mov dx, 0
	imul yy
	mov bx, 1
	sub bx, ax
	add delta, bx
	jmp ccicle
drawCircle3 endp

