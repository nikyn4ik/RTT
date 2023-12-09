;---------------------------------------------
; Park Miller random number algorithm
; Получить случайное число 0 ... 99999
; stdcall WRandom
; на выходе EAX - случайное число 
;---------------------------------------------
proc    WRandom
        push    edx ecx
        mov     eax,[random_seed]
        xor     edx,edx
        mov     ecx,127773
        div     ecx
        mov     ecx,eax
        mov     eax,16807
        mul     edx
        mov     edx,ecx
        mov     ecx,eax
        mov     eax,2836
        mul     edx
        sub     ecx,eax
        xor     edx,edx
        mov     eax,ecx
        mov     [random_seed],ecx
        mov     ecx,100000
        div     ecx
        mov     eax,edx
        pop     ecx edx
        ret
endp
 
;---------------------------------------------
; Получить случайное число в нужном интервале
; Требуется процедура WRandom
; stdcall WIRandom,min,max
; на выходе EAX - случайное число   
;---------------------------------------------
proc    WIRandom rmin:dword,rmax:dword
        push    edx ecx
        mov     ecx,[rmax]
        sub     ecx,[rmin]
        inc     ecx
        stdcall WRandom
        xor     edx,edx
        div     ecx
        mov     eax,edx
        add     eax,[rmin]
        pop     ecx edx
        ret
endp
 
;---------------------------------------------
; Инициализация генератора случайных чисел
; stdcall WRandomInit 
;---------------------------------------------
proc    WRandomInit
        push    eax edx
        rdtsc
        xor     eax,edx
        mov     [random_seed],eax
        pop     edx eax
        ret
endp
