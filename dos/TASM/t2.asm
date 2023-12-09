; Program: graph.asm
.MODEL small
.STACK 256

.DATA

.CODE

jmp start
;=========================================
; Basic program to draw a circle
;=========================================
 mode db 18 ;640 x 480
 x_center dw 300
 y_center dw 200
 y_value dw 0
 x_value dw 100
 decision dw 1
 colour db 2 ;1=blue
;=========================================
start:
 mov ah,00 ;subfunction 0
 mov al,mode ;select mode 18 
 int 10h ;call graphics interrupt
;==========================
 mov bx, x_value
 sub decision, bx
 mov al,colour ;colour goes in al
 mov ah,0ch
 
drawcircle:
 mov al,colour ;colour goes in al
 mov ah,0ch
 
 mov cx, x_value ;Octonant 1
 add cx, x_center ;( x_value + x_center,  y_value + y_center)
 mov dx, y_value
 add dx, y_center
 int 10h
 
 mov cx, x_value ;Octonant 4
 neg cx
 add cx, x_center ;( -x_value + x_center,  y_value + y_center)
 int 10h
 
 mov cx, y_value ;Octonant 2
 add cx, x_center ;( y_value + x_center,  x_value + y_center)
 mov dx, x_value
 add dx, y_center
 int 10h
 
 mov cx, y_value ;Octonant 3
 neg cx
 add cx, x_center ;( -y_value + x_center,  x_value + y_center)
 int 10h
 
 mov cx, x_value ;Octonant 7
 add cx, x_center ;( x_value + x_center,  -y_value + y_center)
 mov dx, y_value
 neg dx
 add dx, y_center
 int 10h
 
 mov cx, x_value ;Octonant 5
 neg cx
 add cx, x_center ;( -x_value + x_center,  -y_value + y_center)
 int 10h

 mov cx, y_value ;Octonant 8
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
 jmp drawcircle

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
 jmp drawcircle


 
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

END Start
