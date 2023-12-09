TITLE MP3
.model small
.stack 100h
.data 
x  dw 0     
nwln db 13,10,"$" 
y  dw 0     
coordsx db "X: $"
coordsy db "Y: $"   

.code     

printf proc
    mov dx,bx
    mov ah,09h
    int 21h
    ret
printf endp

newline proc
    lea dx,nwln
    mov ah,09h
    int 21h
    ret
newline endp

scanf proc
    mov dx, bx
    mov ah, 0ah
    int 21h
    ret
scanf endp 


getx proc



    ret
getx endp   

START:
    MOV AX,@data
    MOV DS,AX
    mov ES,AX

    mov al,13h
    mov ah,0
    int 10h

    mov ax, 0
    int 33h

    mov ax, 1
    int 33h

    lea bx,coordsx
    call printf
    call newline
    lea bx, coordsy
    call printf
    call newline
    call newline   
    lea bx,line
    call printf
    call newline
    lea bx, circle
    call printf

    mov cx, 0002
    mov dx, 0024

start1:  
    mov x,cx
    mov y,dx  
    lea bx,coordsx
    call printf
    mov ax, 3
    int 33h     
    jmp start1


fin:
    mov ah,4ch
    int 21h        

end start
