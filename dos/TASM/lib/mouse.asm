;---------------------------------------        
SetCursor proc 
	;initialize the mouse
	mov ax, 0h
	int 33h
	;show mouse
	mov ax, 1h
	int 33h
	; get mouse place and status
	; mov ax, 3h
	; int 33h
	ret
SetCursor endp 

;---------------------------------------              
;DRAW ONE PIXEL AT XCORDS1,YCORDS1.
; DotOne proc 
; 	mov  ah, 0ch       ;SERVICE TO DRAW PIXEL.
; 	mov  al, 14        ;YELLOW.
; 	mov  bh, 0         ;VIDEO PAGE.
; 	mov  cx, XCords1
; 	mov  dx, YCords1
; 	int  10h           ;BIOS SCREEN SERVICES.
; 	ret
; DotOne endp 
;---------------------------------------              
;GET MOUSE CURSOR STATE.   
;RETURN : BX : BIT 0 = 0 : LEFT BUTTON PRESSED.
;                    = 1 : LEFT BUTTON RELEASED.
;            : BIT 1 = 0 : RIGHT BUTTON PRESSED.
;                    = 1 : RIGHT BUTTON RELEASED.
;         CX = SCREEN COLUMN.
;         DX = SCREEN ROW.

GetMouseState proc 
	mov  ax, 3       ;SERVICE TO GET MOUSE STATE. Определить состояние мыши
	int  33h
	ret
GetMouseState endp 

;------------------------------------------
;CONVERT A NUMBER IN STRING.
;ALGORITHM : EXTRACT DIGITS ONE BY ONE, STORE
;THEM IN STACK, THEN EXTRACT THEM IN REVERSE
;ORDER TO CONSTRUCT STRING (STR).
;PARAMETERS : AX = NUMBER TO CONVERT.
;             SI = POINTING WHERE TO STORE STRING.
;DESTROYED : AX, BX, CX, DX, SI.

number2string proc 
	call dollars ;FILL STRING WITH $.
	mov  bx, 10  ;DIGITS ARE EXTRACTED DIVIDING BY 10.
	mov  cx, 0   ;COUNTER FOR EXTRACTED DIGITS.
cycle1:       
	mov  dx, 0   ;NECESSARY TO DIVIDE BY BX.
	div  bx      ;DX:AX / 10 = AX:QUOTIENT DX:REMAINDER.
	push dx      ;PRESERVE DIGIT EXTRACTED FOR LATER.
	inc  cx      ;INCREASE COUNTER FOR EVERY DIGIT EXTRACTED.
	cmp  ax, 0   ;IF NUMBER IS
	jne  cycle1  ;NOT ZERO, LOOP. 
;NOW RETRIEVE PUSHED DIGITS.
cycle2:  
	pop  dx        
	add  dl, 48  ;CONVERT DIGIT TO CHARACTER.
	mov  [ si ], dl
	inc  si
	loop cycle2  

	ret
number2string endp       

num2str proc 
	; call dollars ;FILL STRING WITH $.
	mov  bx, 10  ;DIGITS ARE EXTRACTED DIVIDING BY 10.
	mov  cx, 0   ;COUNTER FOR EXTRACTED DIGITS.
_cycle1:       
	mov  dx, 0   ;NECESSARY TO DIVIDE BY BX.
	div  bx      ;DX:AX / 10 = AX:QUOTIENT DX:REMAINDER.
	push dx      ;PRESERVE DIGIT EXTRACTED FOR LATER.
	inc  cx      ;INCREASE COUNTER FOR EVERY DIGIT EXTRACTED.
	cmp  ax, 0   ;IF NUMBER IS
	jne  _cycle1  ;NOT ZERO, LOOP. 
;NOW RETRIEVE PUSHED DIGITS.
_cycle2:  
	pop  dx        
	add  dl, 48  ;CONVERT DIGIT TO CHARACTER.
	mov  [ si ], dl
	inc  si
	loop _cycle2  

	ret
num2str endp    
;------------------------------------------
;FILLS VARIABLE "NUMSTR" WITH '$'.
;USED BEFORE CONVERT NUMBERS TO STRING, BECAUSE
;THE STRING WILL BE DISPLAYED.
;PARAMETER : SI = POINTING TO STRING TO FILL.
;DESTROYED : BL, CX, DI.

dollars proc              
	mov  cx, 5
	mov  di, offset numstr
dollars_loop:      
	mov  bl, '$'
	mov  [ di ], bl
	inc  di
	loop dollars_loop

	ret
dollars endp       

;------------------------------------------

display_coords proc 
;SEND CURSOR TO START OF UPPER LEFT.
	mov  ah, 2   ;SERVICE TO SET CURSOR POSITION.
	mov  bh, 0   ;VIDE PAGE.
	mov  dl, 0   ;X.
	mov  dh, 0   ;Y.
	int  10h
;CLEAR LINE.
	mov  ah, 9
	mov  dx, offset clear
	int  21h
;SEND CURSOR TO START OF UPPER LEFT.
	mov  ah, 2   ;SERVICE TO SET CURSOR POSITION.
	mov  bh, 0   ;VIDE PAGE.
	mov  dl, 0   ;X.
	mov  dh, 0   ;Y.
	int  10h
;CONVERT X TO STRING.
	mov  ax, x_mouse ;AX = PARAMETER FOR NUMBER2STRING.                                              
	mov  si, offset numstr
	call number2string                                              
;DISPLAY X.
	mov  ah, 9
	mov  dx, offset numstr
	int  21h
;"-".
	mov  ah, 9
	mov  dx, offset hyphen
	int  21h 
;CONVERT Y TO STRING.
	mov  ax, y_mouse ;AX = PARAMETER FOR NUMBER2STRING.                                              
	mov  si, offset numstr
	call number2string                                              
;DISPLAY Y.  
	mov  ah, 9
	mov  dx, offset numstr
	int  21h         
	ret
display_coords endp



checkColorPixel proc
	push bp
	mov bp, sp

	mov ah, 0Dh
	mov cx, [x_mouse] 
	mov dx, [y_mouse]
	int 10H ; AL = COLOR
	cmp al, byte ptr randomColor
	je noblack
	jmp next
noblack:
	mov isNew, 1
	jmp next
next:
	mov sp, bp
	pop bp
	ret

checkColorPixel endp