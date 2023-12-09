; Ex 1-1. Hello world
assume CS:code,DS:data
; Describe the segment of code
code segment ; Open segment of code
begin:
mov AX,data ; Configure DS
mov DS,AX ; on segment on date
; Print on display text string
mov AH, 09h ; DOS function print to display
mov DX, offset msg ; Addres of printing srting
int 21h ; System call DOS
; Ending programm
mov AX, 4C00h ; DOS function to ending of programm
int 21h ; System call DOS
code ends ; Close code segment
; Describe the segment of date
data segment ; Open date segment
msg db "Hello world!$" ; Text string
data ends ; Close date segment
; Describe the stack segment
stk segment stack ; Open stack segment
db 256 dup (?) ; Stack size now 256 byte
stk ends ; Close stack segment
end begin ; End text with enter point.
