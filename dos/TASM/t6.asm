.STACK 64
.DATA
.CODE
MAIN PROC FAR
    MOV AX,@DATA
    MOV DS,AX
    
 
    mov ah, 0
    mov al, 13h
    int 10h
    

    MOV CX,100
    MOV DX,50
    BACK:
    MOV AH,0CH
    MOV AL,1
    INT 10H
    INC CX
    CMP CX,200
    JNZ BACK
    
    
    
    
    MOV AH,4CH
    INT 21H
    MAIN ENDP
END MAIN
