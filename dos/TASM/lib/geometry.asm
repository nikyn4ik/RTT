
drawSquare proc
	push bp
	mov bp, sp


	mov cx, [bp+10]  ; x start
	mov dx, [bp+8]   ; y start
	mov al, [bp+12]  ; color 
	mov ah, 0ch      ; put pixel

	mov si, [bp+6] ; x end - bp+6
	add si, [bp+10]
	mov di, [bp+4] ; y end - bp+4
	add di, [bp+8]

	colcount:
	inc cx

	int 10h
	cmp cx, si   ; x end
	JNE colcount

	
	mov cx, [bp+10]  ; reset to start of col
	inc dx           ; next row
	cmp dx, di   ; y end
	JNE colcount

	mov sp, bp
	pop bp
	ret 10
drawSquare endp



drawCircle1 proc
	push bp
	mov bp, sp
	; x^2 + y^2 = r^2
	; y = sqrt( r^2 - x^2 )
	
	mov cx, 100       ; x
	mov dx, 400       ; y

	mov al, 13        ; color 
	mov ah, 0ch       ; put pixel

	mov di, 50  ; len
	; y = ax + b

@@loop2: ; @@ not work in this version
	int 10h


	cmp cx, 450
	je @@quit2
	jmp @@loop2

@@quit2:


	push cx
	push dx


	mov sp, bp
	pop bp
	RET
drawCircle1 endp


drawCircle proc
	; mov ax,13h 
	; int       10h                 ;mode 13h 
	push      0a000h 
	pop       es                  ;es in video segment 
	mov       dx,50               ;Xc 
	mov       di,50               ;Yc 
	mov       al,04h              ;Colour 
	mov       bx,50                ;Radius 
	call      Circle              ;Draw circle 


;*** Circle 
; dx= x coordinate center 
; di= y coordinate center 
; bx= radius 
; al= colour 
Circle:
	mov       bp,0                ; X coordinate 
	mov       si,bx               ; Y coordinate 
c00:
	call      _8pixels            ; Set 8 pixels 
	sub       bx,bp               ; D=D-X 
	inc       bp                  ; X+1 
	sub       bx,bp               ; D=D-(2x+1) 
	jg        c01                 ; >> no step for Y 
	add       bx,si               ; D=D+Y 
	dec       si                  ; Y-1 
	add       bx,si               ; D=D+(2Y-1) 
c01: 
	cmp       si,bp               ; Check X>Y 
	jae       c00                 ; >> Need more pixels 
	ret 
_8pixels:
	call      _4pixels            ; 4 pixels 
_4pixels:
	xchg      bp, si               ; Swap x and y 
	call      _2pixels            ; 2 pixels 
_2pixels:
	neg       si 
	push      di 

	add       di, si 
	push ax
	push dx
	mov ax, di
	mov dx, 640
	; imul di,320 
	imul dx

	mov di, ax

	pop dx
	pop ax
	add di, dx 
	mov es:[di+bp], al 
	sub di, bp 
	stosb 
	
	pop di 



	ret
drawCircle endp


drawTriangle proc
	push bp
	mov bp, sp

	mov cx, [bp+10]      ; x start
	mov di, cx
	mov si, cx         ; end gate si =>
	add si, [bp+6]     ; x start + width = end 
	mov dx, [bp+8]     ; y start
	mov al, [bp+4]        ; color 
	mov ah, 0ch      ; put pixel
	mov bx, 0
looph:
	int 10h	
	inc cx
	cmp cx, si
	JB looph
	; push 1
	; call delay

	push ax    ; save ax
	mov ax, dx ; dx содержит координату y
	mov bl, 2  ; bl делитель
	div bl     ; ah содержит остаток от деления ax на bl
	; TEST dx, 4
	cmp ah, 0
	JZ evn
	JNZ odd
evn:
	add di, 1  ; start gate x >
	dec si     ; end gate x <
odd:
	dec dx     ; next start point y
	mov cx, di ; next start point x

	pop ax ; save ax

	cmp si, cx
	JE quit

	jmp looph


quit:
	mov sp, bp
	pop bp
	ret 8
drawTriangle endp




drawThromb proc
	push bp
	mov bp, sp

	mov cx, [bp+10] ; координата центра x
	mov dx, [bp+8] ; координата центра y
	mov si, 0
	mov di, [bp+6] ; половина диаметра по оси x

	push 0
	push di
	push si

	mov al, [bp+4] ; цв
	mov ah, 0ch


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
	mov Ah, 0Ch		;Функция отрисовки точки
	mov al, 1		;Цвет
	int 10h			;Нарисовать точку
	ret
Plot endp

drawCircle3 proc
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
	ret
ccicle:
	mov ax, yy
	cmp ax, 0
	jl  finally
	mov cx, xx0
	add cx, xx
	mov dx, yy0
	add dx, yy
	call Plot
    mov cx, xx0
	add cx, xx
	mov dx, yy0
	sub dx, yy
	call Plot
	mov cx, xx0
	sub cx, xx
	mov dx, yy0
	add dx, yy
	call Plot
	mov cx, xx0
	sub cx, xx
	mov dx, yy0
	sub dx, yy
	call Plot


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

drawRandomFigure proc
	; push bp
	; mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push es
	push ss


	push 640
	call getRandom
	mov ax, random
	mov randomX, ax

	push 480
	call getRandom
	mov ax, random
	mov randomY, ax

	push 16
	call getRandom
	mov ax, random
	mov randomColor, ax


	push randomX ; x
	push randomY ; y
	push 20  ; xd
	push randomColor  ; color
	call drawThromb

	pop ss
	pop es
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	; mov sp, bp
	; pop bp
	ret
drawRandomFigure endp