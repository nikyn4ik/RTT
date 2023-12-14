
startTime    proc
    ;инициализация сегментного регистра данных
    mov     ax,     _DATA
    mov     ds,     ax
    mov     es,     ax

    ;очистка экрана
    mov     ah,     06h     ;функция SCROLL UP
    mov     bh,     07h     ;атрибут для заполнения
    mov     cx,     0000h   ;верхний левый угол окна
    mov     dx,     24*256+79
    int     10h
    ;получение параметров видеорежима
    mov     ah,     0Fh     ;уточнить параметры видеорежима
    int     10h             ;
    mov     [VideoMode],al  ;номер текущего видеорежима
    mov     [VideoPage],bh  ;номер текущей видеостраницы
    ;цикл вывода даты и времени на экран
    @@repeat:
        ;получить текущую дату
        mov     ah,     2Ah
        int     21h
        mov     [Year], cx
        mov     [Month],dh
        mov     [Day],  dl
        ;получить текущее время
        mov     ah,     2Ch
        int     21h
        cmp     dh,     [Seconds]
        je      @@repeat
        mov     [Hours],ch
        mov     [Minutes],cl
        mov     [Seconds],dh
        ;преобразование в строку
        call    DateTimeToString
        ;переместить курсор в заданную позицию
        mov     ah,     02h
        mov     bh,     [VideoPage]     ;видеостраница
        mov     dl,     [Y]             ;столбец (от 0)
        mov     dh,     [X]             ;строка (от 0)
        int     10h
        ;вывести сообщение выбранным цветом в указанной позиции экрана
        mov     ax,     1301h           ;функция вывода строки
        mov     bl,     [Color]         ;bl - цвет текста
        mov     bh,     [VideoPage]     ;страница видеопамяти
        mov     dl,     [X]             ;позиция X экрана
        mov     dh,     [Y]             ;позиция Y экрана
        mov     cx,     [MsgLen]        ;длина строки
        lea     bp,     es:[MsgTime]    ;в es:bp помещаем адрес начала строки
        int     10h
        ;проверить нажатие клавиши
        mov     ah,     01h
        int     16h
        ;если нажата - завершить цикл
    jz      @@repeat
    ;считать код нажатой клавиши (очистить буфер клавиатуры)
    mov     ah,     00h
    int     16h

    ;завершение программы
    mov     ax,     4C00h
    int 21h
startTime    endp
 
;преобразование числа в строку с заменой
;лидирующего нуля на пробел
;на входе:
;  al - число (от 0 до 99)
;на выходе:
;  ax - символы цифр входного числа (ah - старший разряд, al - младший разряд)
IntToCharsWithoutZeroLead proc
    push    bx
    aam
    add     ax,     '00'
    cmp     ah,     '1'
    mov     bl,     0
    adc     bl,     -1
    mov     bh,     ' '
    and     ah,     bl
    not     bl
    and     bh,     bl
    or      ah,     bh
    pop     bx
    ret
IntToCharsWithoutZeroLead endp
 
;преобразование даты и времени в строку
DateTimeToString        proc
    mov     al,     [Hours]
    call    IntToCharsWithoutZeroLead
    xchg    al,     ah
    mov     word ptr [MsgTime],ax

    mov     al,     [Minutes]
    aam
    add     ax,     '00'
    xchg    al,     ah
    mov     word ptr [MsgTime+3],ax

    mov     al,     [Seconds]
    aam
    add     ax,     '00'
    xchg    al,     ah
    mov     word ptr [MsgTime+6],ax

    mov     al,     [Day]
    call    IntToCharsWithoutZeroLead
    xchg    al,     ah
    mov     word ptr [MsgDate],ax

    mov     al,     [Month]
    aam
    add     ax,     '00'
    xchg    al,     ah
    mov     word ptr [MsgDate+3],ax

    mov     ax,     [Year]
    mov     bx,     100
    mov     dx,     0
    div     bx
    aam
    add     ax,     '00'
    xchg    al,     ah
    mov     word ptr [MsgDate+6],ax
    mov     ax,     dx
    aam
    add     ax,     '00'
    xchg    al,     ah
    mov     word ptr [MsgDate+8],ax
    ret     
DateTimeToString endp
 


delay proc
    push ax
    push bx
    push cx
    push dx


    push bp
    mov bp, sp

    push si
    push ax
    push dx
    mov ax, [bp+12] ; задержка передаётся сюда
    mov dx, 10
    mul dx

    mov  si, ax
    pop dx
    pop ax
    mov  ah, 0
    int  1Ah
    mov  bx, dx
    add  bx, si
delay_loop:
    int  1ah
    cmp  dx, bx
    jne  delay_loop
    pop  si
    pop  dx

    mov sp, bp
    pop bp



    pop dx
    pop cx
    pop bx
    pop ax
    ret 2
delay endp


; getRandom proc
; xor ah,ah  ; ah = 0
; int 1Ah    ; returns in cx:dx ticks since midnight (18.2Hz ticks)
; ; let's mix the cx:dx a bit together to get a bit more entropy out of it


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


    xor ax, ax
    xor ah, ah
    mov es, ax
    mov ax, es:[46Ch]


    cmp [bp+4], 16 ; условие для псевдорандомности - запутывание чисел таймера
    jne no_equel
    je equel
no_equel:
    ; rol ax, 2
    ; ror ax, 2
    mul ax
    mov al, ah
    mov ah, dl 

equel:
    xor dx, dx
    mov bx, [bp+4]
    div bx
    ; cmp [bp+4], 460
    ; je addition3
    ; cmp [bp+4], 620
    ; je addition3


    cmp dx, 0 ; условие для цвета - чтобы не меньше 1
    je addition1
    jne addition2
addition1:
    inc dx
addition2:
    mov random, dx
    jmp stop11
; addition3:
;     cmp dx, 20
;     jb sub_pease
;     jnb stop11
; sub_pease:
;     add dx, 20
;     mov random, dx
stop11:
    pop dx
    pop cx
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret 2
getRandom endp


; getRandom16 proc
;     push bp
;     mov bp, sp
;     push ax
;     push bx
;     push cx
;     push dx


;     xor ax, ax
;     xor ah, ah
;     mov es, ax
;     mov ax, es:[46Ch]
;     xor dx, dx
;     mov bx, 16
;     div bx

;     cmp dx, 0
;     je addition1
;     jne addition2
; addition1:
;     inc dx
; addition2:
;     mov random, dx

;     pop dx
;     pop cx
;     pop bx
;     pop ax
;     mov sp, bp
;     pop bp
;     ret
; getRandom16 endp


; getRandom480 proc
;     push bp
;     mov bp, sp
;     push ax
;     push bx
;     push cx
;     push dx


;     xor ax, ax
;     xor ah, ah
;     mov es, ax
;     mov ax, es:[46Ch]
;     xor dx, dx
;     mov bx, 480
;     div bx
;     mov random, dx

;     pop dx
;     pop cx
;     pop bx
;     pop ax
;     mov sp, bp
;     pop bp
;     ret
; getRandom480 endp


; getRandom640 proc
;     push bp
;     mov bp, sp
;     push ax
;     push bx
;     push cx
;     push dx


;     xor ax, ax
;     xor ah, ah
;     mov es, ax
;     mov ax, es:[46Ch]
;     xor dx, dx
;     mov bx, 640
;     div bx
;     mov random, dx

;     pop dx
;     pop cx
;     pop bx
;     pop ax
;     mov sp, bp
;     pop bp
;     ret
; getRandom640 endp