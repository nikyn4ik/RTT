waitKey proc
	mov ah, 0 
	int 16h                 ; ждать нажатия клавиши
	; mov ax, 3 
	; int 10h               ; режим 3 
	; mov ah, 4ch 
	; int 21h               ; Завершить программу после нажатия любой клавиши 

	ret                     ; Вернуть управление
waitKey endp