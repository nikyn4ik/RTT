


; 4-битные режимы (16 цветов):
; VGA

setResulutionVGA40 proc
	; 012h: 640x480 (64 Кб)
	mov ah, 4fh
	mov al, 02h
	mov bh, 0h
	mov bl, 12h
	int 10h

	ret
setResulutionVGA40 endp



; VESA VBE 1.0
setResulutionVBE40 proc
	; 102h: 800x600 (256 Кб)
	mov ah, 4fh
	mov al, 02h
	mov bh, 1h
	mov bl, 02h
	int 10h

	ret
setResulutionVBE40 endp


setResulutionVBE41 proc
	; 104h: 1024x768 (192 Кб)
	mov ah, 4fh
	mov al, 02h
	mov bh, 1h
	mov bl, 04h
	int 10h

	ret
setResulutionVBE41 endp

setResulutionVBE42 proc
	; 106h: 1280x1024 (768 Кб)
	mov ah, 4fh
	mov al, 02h
	mov bh, 1h
	mov bl, 06h
	int 10h

	ret
setResulutionVBE42 endp
















; 8-битные режимы (256 цветов):
; VGA
setResulutionVGA80 proc
	; 013h: 320x200 (64 Кб)
	mov ah, 4fh
	mov al, 02h
	mov bh, 0h
	mov bl, 13h
	int 10h

	ret
setResulutionVGA80 endp
; VBE
setResulutionVBE81 proc
	; Установить мод 800x600
	mov ah, 4fh
	mov al, 02h
	mov bh, 1h
	mov bl, 03h
	int 10h
	ret
setResulutionVBE81 endp


setResulutionVBE82 proc
	; Установить мод 1024x768
	mov ah, 4fh
	mov al, 02h
	mov bh, 1h
	mov bl, 05h
	int 10h
	ret
setResulutionVBE82 endp


setResulutionVBE83 proc
	; Установить мод 1280x1024
	mov ah, 4fh
	mov al, 02h
	mov bh, 1h
	mov bl, 07h
	int 10h
	ret
setResulutionVBE83 endp