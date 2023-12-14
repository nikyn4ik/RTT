waitKey proc
	mov ah, 0 
	int 16h                 ;Wait for key 
	mov ax, 3 
	int 10h                 ;Mode 3 
	mov ah, 4ch 
	int 21h                 ;Terminate 

	ret
waitKey endp