.model tiny
.code
.org 100h

start:  
    jmp main

;������ ����������� �����             
screenSize equ 2000             ;����������� ���������� ��� - 80�25 16-������� 
screenBuf dw screenSize dup(?)
screenSaver dw screenSize dup(0)

;������ ������ ����������
oldTimerHandler dd 0
oldKeyboardHandler dd 0  

delay dw 0     
current dw 0  
ticks db 18
saving db 0

;����� ���������� �������
timerHandler proc far
    pushf 
    ;������ ����������
    call dword ptr cs:oldTimerHandler
    
    pusha
    push ds
    push es
    push cs
    pop ds
    
    cmp saving, 1
    je timerIntEnd 
    
    dec ticks
    jnz timerIntEnd
    
    mov ticks, 18
    
    dec current
    jnz timerIntEnd
    
    mov ax, delay
    mov current, ax
    
    call save
    call changeScreen

    timerIntEnd:
    pop es
    pop ds
    popa
    iret
timerHandler endp

;����� ���������� ����������
keyboardHandler proc far
    pushf  
    ;������ ����������
    call dword ptr cs:oldKeyboardHandler
    
    pusha
    push es
    push ds
    push cs
    pop ds
    
    ;�������� ������� Esc
    cli
        mov ah, 11h
        int 16h
        jz keep

        cmp al, 1Bh
        jne keep

        ;������������ ������ �����������
        mov ds, WORD PTR cs:oldTimerHandler + 2
        mov dx, WORD PTR cs:oldTimerHandler
        mov al, 1Ch
        mov ah, 25h
        int 21h 

        mov ds, WORD PTR cs:oldKeyboardHandler + 2
        mov dx, WORD PTR cs:oldKeyboardHandler
        mov al, 09h
        mov ah, 25h
        int 21h 

        push cs
        pop ds

        keep:
    sti
    
    
    cmp saving, 0
    je keyboardIntEnd

    restore:    
    call changeScreen

    keyboardIntEnd: 
    mov ticks, 18 
    mov ax, delay
    mov current, ax  
    
    pop es
    pop ds
    popa
    iret
keyboardHandler endp


;��������� ���������� �������� ������
save proc
    pusha 
    push cs
    pop es
    push cs
    pop ds 
    
    mov cx, screenSize
    mov di, offset screenBuf
    mov ax, 0B800h                  ;�����������
    mov ds, ax
    xor si, si
    rep movsw
    popa 
    ret
save endp

;��������� ����� ����������� �� ������
changeScreen proc
    pusha 
    push cs
    pop ds
    
    mov cx, screenSize  
    
    cmp saving, 0
    je scrSave
    mov si, offset screenBuf
    mov saving, 0 
    jmp change
    
    scrSave:
    mov si, offset screenSaver
    mov saving, 1 
    
    change:
    
    mov ax, 0B800h                  ;�����������
    mov es, ax                    
    xor di, di
    rep movsw 
    popa
    ret            
changeScreen endp

      
main: 
    call getDelay
    
    cmp delay, 0
    je incorrectInput
    
    mov ax, delay
    mov current, ax
     
    cli 
        
        mov al, 1Ch
        mov ah, 35h
        int 21h 

        mov WORD PTR oldTimerHandler, bx
        mov WORD PTR oldTimerHandler + 2, es
        
        ;�������������� ���������� rtc
        mov dx, offset timerHandler
        mov al, 1Ch
        mov ah, 25h
        int 21h 

        mov al, 09h
        mov ah, 35h
        int 21h 

        mov WORD PTR oldKeyboardHandler, bx
        mov WORD PTR oldKeyboardHandler + 2, es
        
        ;�������������� ���������� ����������
        mov dx, offset keyboardHandler
        mov al, 09h
        mov ah, 25h
        int 21h 
    sti  
    
    mov dx, offset turnoff
    call outputString 
   
    ;�������� ��������� �����������
    mov ax, 3100h      
    mov dx, (main-start+10Fh)/16
    int 21h           
    
    ;������������
    inputOverflow:
    mov dx, offset overflow
    call outputString
    jmp exit
    
    ;������������ ���� �����          
    incorrectInput:
    mov dx, offset error
    call outputString 
    
    exit:
    mov ax, 4ch
    int 21h
       
getDelay proc
    pusha
    
    mov si, 82h                     ;������ ��������� ������
    xor ax, ax
    
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
   
    cmp [si], 0Dh                   ;������� ����� ��������� ������
    jne converse
    
    mov delay, ax
       
    popa  
    ret
getDelay endp 

;����� ������ �� �����
outputString proc
    mov ah, 09h
    int 21h
    ret
outputString endp

error db "Error. Incorrect input! cmd arg should be [1, 32.767]$" 
turnoff db "Info: press Esc to turn screensaver off$" 
overflow db "Error. Input overflow! cmd arg should be [1, 32.767]$"

end start