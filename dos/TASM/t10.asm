.model small
.stack 100h
.data   
	XCords1 dw 160        ;COORDS OF PIXEL AT
	YCords1 dw 100        ;SCREEN CENTER.
	score   dw 0
	x       dw ?          ;MOUSE CLICK X.
	y       dw ?          ;MOUSE CLICK Y.
	msj     db 'score!$'
	hyphen  db '-$'
	clear   db '       $' ;CLEAR LINE.
	numstr  db '$$$$$'    ;STRING FOR 4 DIGITS.
.code

	include mouse.asm
.startup      





	mov  ax, @data
	mov  ds, ax

	;DotGame:
	;enter graphics mode
	mov  ax, 13h
	int  10h
	
	call SetCursor ; mouse input
	call DotOne

DotGame:
	mov  bx, 1          ;CHECK RIGHT BUTTON (USE 0 TO CHECK LEFT BUTTON).
	call GetMouseState
	and  bx, 00000010b  ;CHECK SECOND BIT (BIT 1).
	jz   DotGame        ;NO RIGHT CLICK. REPEAT.

	mov  x, cx          ;PRESERVE X AND Y BECAUSE
	mov  y, dx          ;CX DX WILL BE DESTROYED.                  
	call display_coords

	;cmp  bx, 01 ; check if left mouse was clicked
	;je   Check_X_Cords
	 ;check if the player clicked the dot cords

	Check_X_Cords:
	mov  cx, x
	cmp  cx, XCords1
	je   Check_Y_Cords

	jmp  DotGame       ;WRONG COLUMN. REPEAT.

	Check_Y_Cords:
	mov  dx, y
	cmp  dx, YCords1
	je   ScoreLabel

	jmp  DotGame       ;WRONG ROW. REPEAT.

ScoreLabel:
	inc [score]               
	;DISPLAY "SCORE!".
	  mov ah, 9
	  mov dx, offset msj
	  int 21h
	jmp DotGame       ;REPEAT.

	mov ax, 04ch
	int 21h
	end