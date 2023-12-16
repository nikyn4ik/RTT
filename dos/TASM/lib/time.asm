

; delay proc
;     push ax
;     push bx
;     push cx
;     push dx


;     push bp
;     mov bp, sp

;     push si
;     push ax
;     push dx
;     mov ax, [bp+12] ; задержка передаётся сюда
;     mov dx, 10
;     mul dx

;     mov  si, ax
;     pop dx
;     pop ax
;     mov  ah, 0
;     int  1Ah
;     mov  bx, dx
;     add  bx, si
; delay_loop:
;     int  1ah
;     cmp  dx, bx
;     jne  delay_loop
;     pop  si
;     pop  dx

;     mov sp, bp
;     pop bp



;     pop dx
;     pop cx
;     pop bx
;     pop ax
;     ret 2
; delay endp


; getRandom proc
; xor ah,ah  ; ah = 0
; int 1Ah    ;  возвращается в тактах cx:dx с полуночи (тики 18,2 Гц)
; давайте немного смешаем cx:dx, чтобы получить из него немного больше энтропии


; rol cx, 8
; mov dx, cx
; add dx, '0'
; call printString
; ret
; getRandom endp

getRandom proc
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx


    xor ax, ax ; обнуление ax
    xor ah, ah ; обнуление ah
    mov es, ax
    mov ax, es:[46Ch] ; системный таймер

    cmp [bp+4], 4
    je get_remainder

    cmp [bp+4], 15 ; условие для псевдорандомности - запутывание чисел таймера
    je get_remainder
    jne confuse
confuse:
    ; rol ax, 2
    ; ror ax, 2
    mul ax
    mov al, ah
    mov ah, dl 

get_remainder:
    xor dx, dx
    mov bx, [bp+4]
    div bx


    cmp [bp+4], 4
    je get_end

    cmp [bp+4], 15
    je get_end
    jne dx_below_30
dx_below_30:
    cmp dx, 30
    jbe below
    jnbe get_end

below:
    add dx, 30

get_end:
    mov random, dx

    pop dx
    pop cx
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret 2
getRandom endp



