   ; a short program to check how
; set and get pixel color works
name "pixel"
org  100h   
PUTC    MACRO   char
        PUSH    AX
        MOV     AL, char
        MOV     AH, 0Eh
        INT     10h     
        POP     AX
ENDM
;;;;;
; first and second number:
num1 dw ?
num2 dw ? 
num3 dw ?
start:
lea dx, msg1
mov ah, 09h    ; output string at ds:dx
int 21h  
; get the multi-digit signed number
; from the keyboard, and store
; the result in cx register:
call scan_num
; store first number:
mov num1, cx ;x coordinate
; new line:
putc 0Dh
putc 0Ah  
lea dx, msg2
mov ah, 09h
int 21h  
; get the multi-digit signed number
; from the keyboard, and store
; the result in cx register:
call scan_num
; store second number:
mov num2, cx  
putc 0Dh
putc 0Ah  
lea dx, msg3
mov ah, 09h
int 21h  
; get the multi-digit signed number
; from the keyboard, and store
; the result in cx register:
call scan_num
; store third number:
mov num3, cx 
mov si,num1 ;x coordinate
mov di,num2 ;y coordinate
mov bp,num3 ;radius
mov ah, 0   ; set display mode function.
mov al, 13h ; mode 13h = 320x200 pixels, 256 colors.
int 10h     ; set it!   
mov sp,0 ;center point
         ;radius
          ;first point
mov bx,1  ;(1-r) condition
sub bx,bp ;same as above  
jmp x1
x1:
cmp bx,0  ;condition compare 
JL condt1
jmp condt2
condt1:
            ;increment x by 1
add bx,1;value for P(k+1)
mov ax,2 
add sp,1
mul sp
add bx,ax 
cmp sp,bp
jae done
mov cx, sp ;1(x,y)
add cx,si  ; column
mov dx, bp
add dx,di  ; row
mov al, 15  ; white
mov ah, 0ch ; put pixel
int 10h
xor al, al  ; al = 0
mov cx, 10  ; column
mov dx, 20  ; row
mov ah, 0dh ; get pixel
int 10h
; pause the screen for dos compatibility:  
mov cx, bp ;2(y,x)
add cx,si  ; column
mov dx, sp
add dx,di  ; row
mov al, 15  ; white
mov ah, 0ch ; put pixel
int 10h
xor al, al  ; al = 0
mov cx, 10  ; column
mov dx, 20  ; row
mov ah, 0dh ; get pixel
int 10h
  ;3  (-x,-y)
mov ax,-1
mul sp
add ax,si
mov cx, ax ; column
mov ax,-1
mul bp
add ax,di
mov dx,ax  ; row
mov al, 15  ; white
mov ah, 0ch ; put pixel
int 10h
xor al, al  ; al = 0
mov cx, 10  ; column
mov dx, 20  ; row
mov ah, 0dh ; get pixel
int 10h 
;4  (-y,-x)
mov ax,-1
mul bp
add ax,si 
mov cx, ax ; column
mov ax,-1
mul sp
add ax,di
mov dx,ax  ; row
mov al, 15  ; white
mov ah, 0ch ; put pixel
int 10h
xor al, al  ; al = 0
mov cx, 10  ; column
mov dx, 20  ; row
mov ah, 0dh ; get pixel  
int 10h  
mov cx, sp ;5(x,-y)
add cx,si  ; column
mov ax,-1
mul bp
add ax,di
mov dx,ax  ; row
mov al, 15  ; white
mov ah, 0ch ; put pixel
int 10h
xor al, al  ; al = 0
mov cx, 10  ; column
mov dx, 20  ; row
mov ah, 0dh ; get pixel
int 10h
mov cx, bp ;6(y,-x)
add cx,si  ; column
mov ax,-1
mul sp
add ax,di
mov dx,ax  ; row
mov al, 15  ; white
mov ah, 0ch ; put pixel
int 10h
xor al, al  ; al = 0
mov cx, 10  ; column
mov dx, 20  ; row
mov ah, 0dh ; get pixel
int 10h 
;7  (-y,x)
mov ax,-1
mul bp
add ax,si 
mov cx, ax ; column
mov dx, sp
add dx,di  ; row
mov al, 15  ; white
mov ah, 0ch ; put pixel
int 10h
xor al, al  ; al = 0
mov cx, 10  ; column
mov dx, 20  ; row
mov ah, 0dh ; get pixel
int 10h
;8(-x,y)
mov ax,-1
mul sp
add ax,si 
mov cx, ax ; column
mov dx, bp
add dx,di  ; row
mov al, 15  ; white
mov ah, 0ch ; put pixel
int 10h
xor al, al  ; al = 0
mov cx, 10  ; column
mov dx, 20  ; row
mov ah, 0dh ; get pixel
int 10h
jmp x1
condt2: 
mov ax,2
sub bp,1
mul bp
sub bx,ax
mov ax,2
add sp,1
mul sp
add bx,ax
add bx,1 
cmp sp,bp
jae done
mov cx, sp ;1(x,y)
add cx,si  ; column
mov dx, bp
add dx,di  ; row
mov al, 15  ; white
mov ah, 0ch ; put pixel
int 10h
xor al, al  ; al = 0
mov cx, 10  ; column
mov dx, 20  ; row
mov ah, 0dh ; get pixel
int 10h
; pause the screen for dos compatibility:  
mov cx, bp ;2(y,x)
add cx,si  ; column
mov dx, sp
add dx,di  ; row
mov al, 15  ; white
mov ah, 0ch ; put pixel
int 10h
xor al, al  ; al = 0
mov cx, 10  ; column
mov dx, 20  ; row
mov ah, 0dh ; get pixel
int 10h
 ;3  (-x,-y)
mov ax,-1
mul sp
add ax,si
mov cx, ax ; column
mov ax,-1
mul bp
add ax,di
mov dx,ax  ; row
mov al, 15  ; white
mov ah, 0ch ; put pixel
int 10h
xor al, al  ; al = 0
mov cx, 10  ; column
mov dx, 20  ; row
mov ah, 0dh ; get pixel
int 10h 
;4  (-y,-x)
mov ax,-1
mul bp
add ax,si 
mov cx, ax ; column
mov ax,-1
mul sp
add ax,di
mov dx,ax  ; row
mov al, 15  ; white
mov ah, 0ch ; put pixel
int 10h
xor al, al  ; al = 0
mov cx, 10  ; column
mov dx, 20  ; row
mov ah, 0dh ; get pixel  
int 10h  
mov cx, sp ;5(x,-y)
add cx,si  ; column
mov ax,-1
mul bp
add ax,di
mov dx,ax  ; row
mov al, 15  ; white
mov ah, 0ch ; put pixel
int 10h
xor al, al  ; al = 0
mov cx, 10  ; column
mov dx, 20  ; row
mov ah, 0dh ; get pixel
int 10h
mov cx, bp ;6(y,-x)
add cx,si  ; column
mov ax,-1
mul sp
add ax,di
mov dx,ax  ; row
mov al, 15  ; white
mov ah, 0ch ; put pixel
int 10h
xor al, al  ; al = 0
mov cx, 10  ; column
mov dx, 20  ; row
mov ah, 0dh ; get pixel
int 10h 
;7  (-y,x)
mov ax,-1
mul bp
add ax,si 
mov cx, ax ; column
mov dx, sp
add dx,di  ; row
mov al, 15  ; white
mov ah, 0ch ; put pixel
int 10h
xor al, al  ; al = 0
mov cx, 10  ; column
mov dx, 20  ; row
mov ah, 0dh ; get pixel
int 10h
;8(-x,y)
mov ax,-1
mul sp
add ax,si 
mov cx, ax ; column
mov dx, bp
add dx,di  ; row
mov al, 15  ; white
mov ah, 0ch ; put pixel
int 10h
xor al, al  ; al = 0
mov cx, 10  ; column
mov dx, 20  ; row
mov ah, 0dh ; get pixel
int 10h
jmp x1
 done:    
int 20h
SCAN_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI      
        MOV     CX, 0
        ; reset flag:
      MOV     CS:make_minus, 0
next_digit:
        ; get char from keyboard
        ; into AL:
        MOV     AH, 00h
        INT     16h
        ; and print it:
        MOV     AH, 0Eh
       
