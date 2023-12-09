.model small


.data
MESSAGE db "HI enter a number: $"
MESSAGE1 DB 10, 13, "Your number is $"
.code
.startup

mov ah, 09h
mov dx, offset MESSAGE
int 21




mov ah, 01h
int 21h

mov ah, 09h
mov dx, offset MESSAGE1
int 21

mov dl, al

mov ah, 02h
int 21h

mov ah, 4ch
int 21h

end

.exit
