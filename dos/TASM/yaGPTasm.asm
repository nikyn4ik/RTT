org 100h

start:
    mov ax,@data
    mov ds,ax

    ; Ввод текста
    lea dx, input_buffer
    mov ah, 0Ah
    int 21h

    ; Вывод текста
    lea si, input_buffer+2
    call printString

exit:
    mov ax, 4C00h
    int 21h

; Функции
printString:
    lodsb
    cmp al, 0
    je done
    call writeChar
    jmp printString
done:
    ret

input_buffer: db 254, ?

; Константы
times 510-($-$$) db 0
dw 0xAA55
