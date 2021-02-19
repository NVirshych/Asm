.model small

.stack 100h

.code

greeting proc
    
    mov dx, offset greeting1
    call outputString
    
    mov ax, maxSize
    call outputNum
    
    mov dx, offset greeting2
    call outputString
    
    ret
greeting endp

clearOutput proc
    
    mov di, offset output
    mov cx, 8
    
    clearOutputLoop:
    
    mov [di], '$'
    
    inc di
    loop clearOutputLoop
    
    ret
clearOutput endp

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

;������� ��������� ������ � �����
strToNum MACRO str
    xor cx, cx
    xor ax, ax                      ;��������� ��
    mov si, offset str[2]           ;������ ������ ��� ��������
    mov cl, [str+1]                 ;���-�� ��������� ��������
    
    cmp cx, 0                       ;�������� �� ���� ������ ������
    je emptyInput
     
    ;�������� �� ���� + � ������ ����� ��� ��������
    cmp [si], '+'
    jne minus
    sub cx, 1 
    inc si
    jmp converse
    
    ;�������� �� ���� - � ������ ����� ��� ��������
    minus:
    cmp [si], '-'
    jne converse
    sub cx, 1 
    inc si
    
    converse:   
    mov bx, 0Ah
    mul bx                          ;��������� ������������ �� 10    
    jo inputOverflow                ;�������� �� ������������
    
    mov bl, [si]                    ;������ �� ������
    sub bx, '0'                     ;�������� �� ascii ���� ������� ascii ��� ����
    
    ;�������� ������� �� ������� 0 <= x <= 9
    cmp bx, 9                       
    jg incorrectInput
    cmp bx, 0
    jl incorrectInput
    
    add ax, bx                      ;���������� ������ ������� � ������������
    jo inputOverflow                ;�������� �� ������������
    
    inc si                          ;������� � ���������� �������
    loop converse 
    
    cmp ax, 0                       ;�������� ������������ ����� (������������)
    jl inputOverflow
    
    ;�������� �� - � ������ ������
    cmp [str+2], '-'
    jne strToNumEnd 
    neg ax                          ; *(-1)
                  
    strToNumEnd:               
ENDM

;���� ������� �����
getArray proc 
    mov di, offset array    
    mov cx, maxSize    
    jmp arrayInputLoop
    
    ;������� ������ ������
    emptyInput:
    pop cx
    mov dx, offset empty
    call outputString
    jmp arrayInputLoop
    
    ;������������
    inputOverflow:
    pop cx                          ;��������� �������� �������� �� �����
    mov dx, offset overflow
    call outputString
    jmp arrayInputLoop
    
    ;������������ ���� �����          
    incorrectInput:
    pop cx                          ;��������� �������� �������� �� �����
    mov dx, offset error
    call outputString          
              
    arrayInputLoop:
    ;����� ������ - ������� �����
    mov dx, offset enterNum
    call outputString
    
    ;���� �����
    mov dx, offset input 
    call inputString           
    
    push cx                         ;��������� �������� �������� � ����
    strToNum input                  ;������� ������ � �����  
    pop cx                          ;��������� �������� �������� �� �����
    
    mov [di], ax                    ;��������� ����� � ������
    add di, 2                    
    
    loop arrayInputLoop
    ret             
getArray endp

outputArray proc
    
    mov cx, maxSize                 ;������ �������
    mov si, offset array
    
    mov dx, offset your
    call outputString
    
    outputArrayLoop:
    
    push cx                         ;���������� ��������
    mov ax, [si]                    ;������� �������
    call outputNum                  ;����� ��������
    pop cx
    
    cmp cx, 1
    je finishOutput
    ;����� �����������
    mov dx, offset separator
    call outputString
         
    add si, 2                       ;��������� �������
    loop outputArrayLoop
    
    finishOutput:
    ret
outputArray endp

setRepArray proc
    
    mov cx, maxSize                 ;������ �������
    mov si, offset array
    
    arrayLoop:
    mov ax, [si]                    ;������� �������
    push si                         ;���������� �������� ����� � ������� � ����
    push cx                         ;���������� �������� � ����
    
    mov cx, maxSize                 ;������ �������
    mov si, offset array
    searchLoop:
    
    cmp [si], ax                    ;��������� ���������� �������� � ��������� �������
    je found
    
    add si, 2                       ;��������� ������� �������
    loop searchLoop
    
    found:
    sub si, offset array            ;��������� ������ � �������� �������
    add si, offset repArray         ;��������� ���������������� �������� � ������������� �������
    inc [si]                        ;���������� ���-�� ����������
    
    pop cx                          ;��������� �������� �� �����
    pop si                          ;��������� �������� ����� � ������� �� �����
    add si, 2                       ;��������� ������� �������     
    loop arrayLoop
    
    ret
setRepArray endp

getMaxRep proc
    
    
    mov cx, maxSize                 ;������ �������
    mov di, offset repArray
    mov ax, [di]                    ;���������� ������� ��������
    
    mov si, offset repArray
    add si, 2
    
    repSearchLoop:
    
    cmp [si], ax                    ;��������� ���������� �������� � ��������� �������
    jle skip
    
    ;���������� ������ ����������� ��������
    mov di, si
    mov ax, [di]
    
    skip:
    add si, 2                       ;��������� ������� 
    loop repSearchLoop
    
    sub di, offset repArray         ;��������� ������ � ������������� �������
    add di, offset array            ;��������� ���������������� �������� � �������� �������
    
    mov ax, [di]                    ;���������� �������� ����� �������������� ��������
      
    ret
getMaxRep endp
              
outputNum proc
    
    call clearOutput
    
    xor cx, cx                      ;��������� ��������
    mov bx, 0Ah                     ;10
    mov di, offset output           ;������ ��� ������ �����
    
    ;��������� ���������� ����� � 0
    cmp ax, 0
    jge pos
    
    ;��������� ������ � ������ � ��������� ������ �����
    mov [di], '-'
    inc di
    neg ax
    
    ;����� ����, ���� ����� = 0
    pos:
    cmp ax, 0
    jne toStack
    mov [di], '0'
    jmp printNum
    
    
    toStack:
    ;�������� �� ������������� ��������
    cmp ax, 0
    je toStr
    
    xor dx, dx                      ;��������� dx
    div bx                          ; ax/10 - ������� � dl
    add dl, '0'                     ;��������� ascii ���� ����� � dl
    push dx                         ;��������� ������� � ����
    inc cx                          ;���������� �������� ��������
    
    jmp toStack
    
    toStr:
    pop dx                          ;��������� ������� �� �����
    mov [di], dx                    ;��������� ������� ������
    inc di
    loop toStr
    
    ;����� ����������
    printNum:
    mov dx, offset output
    call outputString 
    
    ret              
outputNum endp   
              
start:
mov ax, @data
mov ds, ax
mov es, ax 

mov [input], maxLen

call greeting

call getArray                   ;���� �������

mov ax, 03
int 10h

call outputArray                ;����� ��������� ������ �� �����

mov dx, offset result
call outputString

call setRepArray                ;��������� ������� ����������

call getMaxRep                  ;���������� �������� ����� �������������� �����

call outputNum                  ;����� �������� ����� �������������� �����

;���������� ���������� ���������
Exit:
mov ax, 4ch
int 21h 

.data 
;�������������� ������  
greeting1 db "Input $"
greeting2 db "numbers from -32.767 to 32.767",0Ah,'$'
your db 0Dh,0Ah,0Ah,"Your array: $" 
separator db ", $"
result db 0Dh,0Ah,0Ah,"Most frequent number: $"
enterNum db 0Dh,0Ah,"Enter number: $"        
error db 0Dh,0Ah,"Error. Incorrect input!$" 
overflow db 0Dh,0Ah,"Error. Input overflow$!"
empty db 0Dh,0Ah,"Error. Empty input!$"

input db 09h dup('$')           ;������ ��� ����� �����    
output db 08h dup('$')          ;������ ��� ������ �����    
maxLen equ 07h

maxSize equ 6                   ;������ �������
array dw maxSize dup (?)        ;�������� ������ 
repArray dw maxSize dup (0)     ;������ ����������

end start