.model small

.data
enterStr db "Enter string:",0Dh,0Ah,'$'
result db 0Dh,0Ah,"Result is:",0Dh,0Ah,'$'
empty db 0Dh,0Ah,"Error. Empty string!",0Dh,0Ah,'$'
string db 0CBh dup('$') 
maxSize equ 0C8h

.code

;������� � cx ����� ���������� ����� ������. str - ������, cur - ������� ��������. 
len MACRO str, cur 
    xor cx, cx  
    mov cl, str[1]
    add cx, offset str[2]
    sub cx, cur    
ENDM

;������������ ����� ������
sym_output MACRO str
    mov cl, str+1
    mov si, offset str+2
    mov ah, 02h
    output:
    lodsb
    mov dl, al
    int 21h
    loop output   
ENDM

;������� �������� � ������ str
skipSpaces MACRO str  
    LOCAL skip
    sub str, 1
    skip:
    inc str
    cmp [str], ' ' 
    je skip
ENDM  

;������ ������� old �� new � ������ str
removeSym MACRO str, old, new
    LOCAL skip
    mov cl, [str+1]
    mov di, offset str[2]
    mov al, new
    remove:
    cmp [di], old
    jne skip
    stosb
    skip:
    inc di
    loop remove 
removeSym ENDM

;����� ������ �� �����
outputString proc
    mov ah, 09h
    int 21h
    ret
outputString endp

;���� ������
inputString proc
    mov ah, 0Ah
    int 21h
    ret
inputString endp

;����� ������ �������� �����: 
;dx - ������ ������ ������ �������� �����
;ax - ����� ������ �������� �����
findMaxWord proc
    len string, si
    mov di, si
    xor bx, bx
    xor ax, ax  
    
    word:
    inc bx
    
    cmp [di+1], ' '   
    je len_cmp                
    cmp cx, 1
    jbe len_cmp  
    
    inc di
    loop word   
    
    len_cmp:  
    cmp bx, ax       
    ja set
    xor bx, bx
    jmp skip_sp
    
    set:  
    mov dx, di
    inc dx
    sub dx, bx
    mov ax, bx
    xor bx, bx
    
    skip_sp:
    inc di
    sub cx, 1
    cmp cx, 1
    jbe end
    cmp [di], ' '
    jne word
    jmp skip_sp 
    
    end:
    mov di, si
    ret
findMaxWord endp
 
; di - ������ ��������� ��� �������
; cx - ����� ��������� ��� �������
reverse proc    
    rev_loop:
    mov bl, [di]
    add di, cx
    mov bh, [di]
    mov [di], bl
    sub di, cx 
    mov [di], bh
    inc di
    sub cx, 2  
    cmp cx, 0
    jg rev_loop    
    ret
reverse endp

;�������� ����� ������
isEnd proc 
    len string, si
    cmp cx, 1
    jbe outputResult
    mov di, si
    ret
isEnd endp    

start:
mov ax, @data
mov ds, ax
mov es, ax 

mov dx, offset enterStr
call outputString
 
;���� ������
mov [string], maxSize          ; ��������� ������������� ������� ������ ��� int 21h-09h 
mov dx, offset string
call inputString

;��������� di � si �� ������ ������
mov si, offset string[2]
mov di, si 

;�������� �� ���� ������ ������ � ������ �� ��������
skipSpaces si 
mov di, si
len string, si
cmp cx, 0
je strIsEmpty

;remove_sym string, '$', 13h

sort:  
call findMaxWord 

add dx, ax
sub dx, 1                   ;dx - ��������� ����� ����� ��� �������
mov cx, dx
sub cx, si                  ;cx=dx-si - ����� ��������� ��� �������
call reverse

mov di, si                           
mov cx, ax                  ;cx - ����� ������ �������� ����� (��� �������) 
sub cx, 1
call reverse  
 
add si, ax                  ;����� ������ ������� ��������� �� ����� ������������ �����
skipSpaces si               ;������� ��������    
call isEnd                  ;�������� �� ����� ������
mov di, si
mov cx, dx
sub cx, si                  ;cx=dx-si - ����� ��������� ��� �������
call reverse                                                        

jmp sort 

;����� ����������
outputResult:
mov dx, offset result
call outputString
sym_output string
jmp Exit

;����� ��������� � ����� ������ ������
strIsEmpty:
mov dx, offset empty
call outputString    
 
;���������� ���������� ���������
Exit:
mov ax, 4ch
int 21h 

end start