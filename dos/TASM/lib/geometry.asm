
drawSquare proc
	push bp
	mov bp, sp


	mov cx, [bp+10]  ; x start
	mov dx, [bp+8]   ; y start
	mov al, [bp+12]  ; color 
	mov ah, 0ch      ; put pixel

	colcount:
	inc cx
	int 10h
	cmp cx, [bp+6]   ; x end
	JNE colcount

	mov cx, [bp+10]  ; reset to start of col
	inc dx           ; next row
	cmp dx, [bp+4]   ; y end
	JNE colcount

	mov sp, bp
	pop bp
	ret 10
drawSquare endp



drawCircle proc
	; mov ax,13h 
	; int       10h                 ;mode 13h 
	push      0a000h 
	pop       es                  ;es in video segment 
	mov       dx,160              ;Xc 
	mov       di,100              ;Yc 
	mov       al,04h              ;Colour 
	mov       bx,50               ;Radius 
	call      Circle              ;Draw circle 
	mov       ah,0 
	int       16h                 ;Wait for key 
	mov       ax,3 
	int       10h                 ;Mode 3 
	mov       ah,4ch 
	int       21h                 ;Terminate 

;*** Circle 
; dx= x coordinate center 
; di= y coordinate center 
; bx= radius 
; al= colour 
Circle:
	mov       bp,0                ;X coordinate 
	mov       si,bx               ;Y coordinate 
c00:
	call      _8pixels            ;Set 8 pixels 
	sub       bx,bp               ;D=D-X 
	inc       bp                  ;X+1 
	sub       bx,bp               ;D=D-(2x+1) 
	jg        c01                 ;>> no step for Y 
	add       bx,si               ;D=D+Y 
	dec       si                  ;Y-1 
	add       bx,si               ;D=D+(2Y-1) 
c01: 
	cmp       si,bp               ;Check X>Y 
	jae       c00                 ;>> Need more pixels 
	ret 
_8pixels:
	call      _4pixels            ;4 pixels 
_4pixels:
	xchg      bp,si               ;Swap x and y 
	call      _2pixels            ;2 pixels 
_2pixels:
	neg       si 
	push      di 

	add       di,si 
	; imul di,320 
	add       di, dx 
	mov       es:[di+bp],al 
	sub       di,bp 
	stosb 
	
	pop       di 



	ret
drawCircle endp


drawTriangle proc

	ret
drawTriangle endp


drawThromb proc
	jmp start
start:
	mov bx, x_value
	sub decision, bx
	mov al, colour  ; colour goes in al
	mov ah, 0ch

drawcircle1:
	mov al, colour  ; colour goes in al
	mov ah, 0ch

	mov cx, x_value ; Octonant 1
	add cx, x_center ;( x_value + x_center,  y_value + y_center)
	mov dx, y_value
	add dx, y_center
	int 10h

	mov cx, x_value ; Octonant 4
	neg cx
	add cx, x_center ;( -x_value + x_center,  y_value + y_center)
	int 10h

	mov cx, y_value ; Octonant 2
	add cx, x_center ;( y_value + x_center,  x_value + y_center)
	mov dx, x_value
	add dx, y_center
	int 10h

	mov cx, y_value ; Octonant 3
	neg cx
	add cx, x_center ;( -y_value + x_center,  x_value + y_center)
	int 10h

	mov cx, x_value ; Octonant 7
	add cx, x_center ;( x_value + x_center,  -y_value + y_center)
	mov dx, y_value
	neg dx
	add dx, y_center
	int 10h

	mov cx, x_value ; Octonant 5
	neg cx
	add cx, x_center ;( -x_value + x_center,  -y_value + y_center)
	int 10h

	mov cx, y_value ; Octonant 8
	add cx, x_center ;( y_value + x_center,  -x_value + y_center)
	mov dx, x_value
	neg dx
	add dx, y_center
	int 10h

	mov cx, y_value ;Octonant 6
	neg cx
	add cx, x_center ;( -y_value + x_center,  -x_value + y_center)
	int 10h

	inc y_value

condition1:
	cmp decision,0
	ja condition2
	mov cx, y_value
	mov ax, 2
	imul cx
	add cx, 1
	inc cx
	add decision, cx
	mov bx, y_value
	mov dx, x_value
	cmp bx, dx
	ja readkey
	jmp drawcircle1

condition2:
	dec x_value
	mov cx, y_value
	sub cx, x_value
	mov ax, 2
	imul cx
	inc cx
	add decision, cx
	mov bx, y_value
	mov dx, x_value
	cmp bx, dx
	ja readkey
	jmp drawcircle1



;==========================
readkey:
	mov ah,00
	int 16h ;wait for keypress
;==========================
endd:
	mov ah,00 ;again subfunc 0
	mov al,03 ;text mode 3
	int 10h ;call int
	mov ah,04ch
	mov al,00 ;end program normally
	int 21h 
	ret
drawThromb endp
