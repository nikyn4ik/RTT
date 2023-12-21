; 4-битные режимы (16 цветов):
; VGA
; установить разрешение экрана в 640 на 480
setResulutionVGA40 proc
	; 012h: 640x480 (64 Кб)
	mov ah, 4fh
	mov al, 02h
	mov bh, 0h
	mov bl, 12h
	int 10h

	ret
setResulutionVGA40 endp



