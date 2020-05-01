.model small
.stack 100h

.code
jmp main

;����� �����  
printScore proc
    pusha
    xor cx, cx    
    mov ax, score
    xor dx, dx 
    mov si, 10
;������ ���� ����� � ����
loadStack:   
    div si 			  		
    add dl, '0'
    push dx    
    xor dx, dx 
    inc cx        
    cmp ax, 0
    jne loadStack   
    mov bx, 466
;������ ���� �� ����� � �����������    
printStack:
    pop dx 
    push ds
    mov ax, 0b800h
    mov ds, ax
    mov [bx], dl
    inc bx
    mov [bx], 07h
    inc bx
    pop ds           
    loop printStack          
    popa 
    ret   
endp    

;������� ������ � ����� ����� 
setScreen proc
    push cx
    push ax
    push si
    push ds  
    push bx
    push dx    
    
    mov ah, 02h
    mov bh, 0
    xor dx, dx
    int 10h
     
    mov ax, 0b800h                  ;����� �����������
    mov ds, ax 
    
    ;������� ������
    mov ah, 00 
    mov al, 01                    
    int 10h
    
    xor si, si
    inc si
    ;������� �����
    mov cx, 40              
    screenTopBorder:
    mov [si], 70h
    add si, 2
    loop screenTopBorder
    
    ;������� ����� 
    mov cx, 23
    screenSideBorders:
    mov [si], 70h
    add si, 78
    mov [si], 70h
    add si, 2
    loop screenSideBorders
    
    ;������ �����
    mov cx, 40
    screenBottomBorder:
    mov [si], 70h
    add si, 2
    loop screenBottomBorder
    
    ;����� �������� ���� 
    ;�������
    mov cx, 2
    gameplaySideBorders:
    mov al, 80
    mul cl
    add ax, 4
    mov si, ax
    inc si
    mov [si], 70h
    add si, 46
    mov [si], 70h
    inc cx
    cmp cx, 23
    je gameplaySideBordersEnd
    jmp gameplaySideBorders
    
    ;�������
    gameplaySideBordersEnd:
    mov cx, 2
    gameplayTopBorder:
    mov al, 2
    mul cl
    add ax, 160
    mov si, ax
    inc si
    mov [si], 70h
    inc cx
    cmp cx, 26
    je gameplayTopBorderEnd
    jmp gameplayTopBorder
    
    ;"����"
    gameplayTopBorderEnd:
    mov [454], 'S' 
    mov [456], 'c'
    mov [458], 'o'
    mov [460], 'r'
    mov [462], 'e'
    mov [464], ':'
    mov [615], 20h
    mov [616], '>' 
    mov [619], 30h
    mov [620], '>'
    mov [623], 40h
    mov [624], '>'
    mov [627], 50h
    
    xor bh, bh
    mov dh, 25
    mov ah, 02
    int 10h  
    pop dx
    pop bx
    pop ds
    pop si
    pop ax
    pop cx
    ret
endp

;������� ������ � playerField
initPlayField proc
    push cx
    push bx
    push ax  
    push es
    push di
    push si
      
    mov ax, ds
    mov es, ax
    mov si, offset level
    mov di, offset playField  
    mov cx, 396
    rep movsb                       ;������� ������ � playField
  
    pop si
    pop di
    pop es 
    pop ax
    pop bx
    pop cx
    ret
endp

;����� ������ �� �����
displayPlayField proc
    push ax
    push es
    push cx
    push di
    push si 
    
    mov ax, 0B800h                  ;�����������
    mov es, ax
    mov cx, 19                      ;���-�� �����
    mov di, 247                     ;���� �������� ������� ������� �������� ����
    mov si, offset playField
    
    rowLoop: 
        push cx
        mov cx, 22                  ;�������� � ����
        
        colLoop:
        movsb                       ;����������� si -> di
        inc di                      ;������� ���� ���� �������
        loop colLoop
        add di, 36                  ;��������� ���
        pop cx
        
    loop rowLoop
    
    pop si
    pop di
    pop cx
    pop es
    pop ax
    ret
endp

;��������� ���������
displayPaddle proc       
    push ds
    
    mov bx, offset paddlePosition
    mov dx, [bx]
    
    mov ax, 0b800h
    mov ds, ax
    mov bx, 1767                    ;������ ������, � ������� �������� ���������
    mov cx, 22
    ;������� ������
    loop21:    
    mov [bx], 00h
    add bx, 2
    loop loop21
       
    mov bx, 1767
    add bx, dx
    add bx, dx
    mov cx, 4 
    ;����� ���������
    loop31:    
    mov [bx], 070h
    add bx, 2
    loop loop31
    
    pop ds    
    ret
endp

;����� �����������
welcomeScreen proc 
    push ax
    push bx 
    push dx
    
    ;����� ������
    mov ah, 9h
    mov dx, offset messageWelcome
    int 21h          
    
    waitEnterWelcome: 
    ;�������� ������� �������� � ������
    mov ah, 1
    int 16h
    jz waitEnterWelcome
    ;��������� ������� �� ������
    xor ah, ah
    int 16h
    cmp ah, 1Ch                         ;Enter
    je EnterWelcome
    cmp ah, 01h                         ;Esc
    jne waitEnterWelcome                    
    ;���������� ��� ������� esc
    jmp exit
    EnterWelcome:
    pop dx
    pop bx
    pop ax      
    ret
endp

;������������ ����
moveBall proc
    push dx    
    cmp verticalMovement, 0             ;���������� ������������� ��������
    jne moveDown                        
    cmp ballPositionY, 0                ;�������� ������������ � ������� ��������
    jne notUpBorder
    mov verticalMovement, 1             ;�������� ������������ ��������
    notUpBorder:              
    jmp horizontalCheck                 ;�������������� ��������
    moveDown:
    cmp ballPositionY, 18               ;�������� ������������ � ������ ��������
    jne notDownBorder         
    mov bx, offset paddlePosition
    mov ax, [bx]
    cmp ax, ballPositionX               ;������ ��������� �����
    jg paddleLose
    add ax, 3
    cmp ax, ballPositionX
    jl paddleLose                       ;������ ��������� ������
    mov verticalMovement, 0             ;�������� ������������ ��������
    jmp notDownBorder
    ;����� - ���������
    paddleLose:
    mov ax, 01h
    pop dx
    ret
    notDownBorder: 
    horizontalCheck:
    cmp horizontalMovement, 0           ;����������� ��������������� ��������
    jne moveLeft
    cmp ballPositionX, 21               ;�������� ������������ � ������ �������
    jne changeBallPos
    mov horizontalMovement, 1           ;�������� �������������� ��������
    jmp changeBallPos
    moveLefT:   
    cmp ballPositionX, 0                ;�������� ������������ � ����� �������
    jne changeBallPos   
    mov horizontalMovement, 0           ;�������� �������������� ��������
    changeBallPos: 
    cmp horizontalMovement, 1           ;����������� �������������� ��������
    jne moveRight
    dec ballPositionX                   ;�������� �����
    call checkCollision                 ;��������� ������������
    cmp dx, 00h                         ;��������� ��������
    je verticalMove
    inc ballPositionX                   ;�������� ������
    mov horizontalMovement, 0           ;�������� �������������� ��������
    jmp verticalMove
    moveRight:
    inc ballPositionX                   ;�������� ������
    call checkCollision                 ;��������� ������������
    cmp dx, 00h                         ;��������� ��������
    je verticalMove
    dec ballPositionX                   ;�������� �����
    mov horizontalMovement, 1           ;�������� �������������� ��������
    verticalMove:
    cmp verticalMovement, 1
    jne moveUp
    inc ballPositionY                   ;�������� ����
    call checkCollision                 ;��������� ������������
    cmp dx, 00h                         ;��������� ��������
    je moveEnd
    dec ballPositionY                   ;�������� �����
    mov verticalMovement, 0             ;�������� ���� ��������
    jmp moveEnd
    moveUp:
    dec ballPositionY                   ;�������� �����
    call checkCollision                 ;��������� ������������
    cmp dx, 00h                         ;��������� ��������
    je moveEnd
    inc ballPositionY                   ;�������� ����
    mov verticalMovement, 1             ;�������� ���� ��������
    moveEnd:     
    xor ax, ax
    pop dx
    ret
endp

;��������� ����
displayBall proc           
    push ax
    push bx
    push cx
    push ds     
    mov bx, offset ballPositionY    
    mov ax, [bx]
    add ax, 3                       ;3 ���� ������
    mov cl, 80                      ;40 �������� � ��� �� 2 ����� �� ������
    mul cl                          
    mov bx, offset BallPositionX
    mov cx, [bx]
    add ax, cx                      
    add ax, cx                      ;x2 ����� �� ������ ������
    add ax, 6                       ;3 ������� �� 2 �����
    mov bx, ax
    mov ax, 0b800h                  ;������ �����������
    mov ds, ax 
    mov [bx], 'o'
    inc bx 
    mov [bx], 07h                   ;����������� ������
    pop ds
    pop cx
    pop bx
    pop ax
    ret
endp

;���������� � dx : 0 - ������������ �� ���������, 1 - ������������ ���������
checkCollision proc   
    push ax
    push bx
    push cx    
    xor dx, dx
    mov bx, offset ballPositionY    ;Y ���������� ����
    mov ax, [bx]
    mov cl, 22                      ;22 ������� � ����� ���� �������� ����
    mul cl
    mov bx, offset ballPositionX    ;+X ���������� ����
    mov cx, [bx]
    add ax, cx                      ;����� ������ � ������� ��������� ���
    mov bx, offset playField
    add bx, ax                      ;���� �������� ������ � ������� ��������� ���
    cmp [bx], 00h
    je notCollision                 ;������ ������ - ������������ �� ���������
    add score, 10                   ;���������� �����
    call printScore                 ;����� ����� 
    mov dx, 01h                     ;����� ������������ 
    
    ;"����������" ������ ��� ��������� �����
    cmp [bx], 50h
    jne changeColour   
    mov [bx], 00h   
    dec winCount                    ;���������� ����� �� ������
    jmp notCollision
    
    ;��������� ����� ������
    changeColour:
    add [bx], 10h 
           
    notCollision: 
    pop cx
    pop bx
    pop ax
    ret
endp

;�������� ��������� ����� �������
paddleStart proc
    mov bx, offset paddlePosition
    mov ax, [bx]
    add ax, 2
    mov ballPositionX, ax           ;X ���������� ���� - 3 ������ ��������� 
    call displayBall                ;��������� ����
    call displayPaddle              ;��������� ���������
    paddleLoop:
    ;�������� ������ ����������
    mov ah, 1
    int 16h
    jz paddleLoop  
    ;��������� �������� �� ������
    xor ah, ah
    int 16h 
    
    cmp ah, 4Dh                     ;������� ������  
    je paddleRight
    cmp ah, 4Bh                     ;������� �����
    je paddleLeft
    cmp ah, 01h                     ;Esc
    je paddleEsc
    cmp ah, 1Ch                     ;Enter
    je paddleEnter 
    jmp paddleLoop
    
    paddleRight:
    cmp paddlePosition, 18          ;������ �������
    jge paddleLoop
    inc paddlePosition              ;�������� ��������� ������
    inc ballPositionX               ;�������� ��� ������ 
    call displayPlayField           ;���������� ������� ����
    call displayPaddle              ;���������� ���������
    call displayBall                ;���������� ���
    jmp paddleLoop
    
    paddleLeft:  
    cmp paddlePosition, 0           ;����� �������
    je paddleLoop
    dec paddlePosition              ;�������� ��������� �����
    dec ballPositionX               ;�������� ��� ����� 
    call displayPlayField           ;���������� ������� ����
    call displayPaddle              ;���������� ���������
    call displayBall                ;���������� ���
    jmp paddleLoop
    
    paddleEsc:
    jmp exit                        ;�����
    
    paddleEnter:
    ret                             ;����� ����
endp    

printScreen MACRO Screen   
    pusha 
    
    LOCAL printScrLoop
    LOCAL waitEnterScr 
    LOCAL EnterScr
     
    ;������� ������
    mov ah, 00 
    mov al, 01                    
    int 10h  
    
    mov ax, 0B800h                  ;�����������
    mov es, ax
    mov cx, 880                     
    mov di, 1                       ;���� �������� ������� �������
    mov si, offset Screen
    
    printScrLoop: 
 
        movsb                       ;����������� si -> di
        inc di                      ;������� ���� ���� �������
        
    loop printScrLoop
    
    ;������ �� ������������� ������
    mov ah, 02h
    mov bh, 0
    mov dh, 23
    mov dl, 0
    int 10h

    ;����� ��������� �� �����
    mov ah, 9h
    mov dx, offset message
    int 21h
    
    ;�������� ������
    mov ah, 02h
    mov bh, 0
    mov dh, 25
    int 10h         
    
    waitEnterScr:
    ;�������� ������ ����������
    mov ah, 1
    int 16h
    jz waitEnterScr
    ;��������� �������� �� ������
    xor ah, ah
    int 16h 
    
    cmp ah, 1Ch                     ;Enter
    je EnterScr               
    
    cmp ah, 01h                     ;Esc
    jne waitEnterScr
    jmp exit 
    
    EnterScr:
    
    popa      
printScreen ENDM

main:
    mov ax, @data
    mov ds, ax
    mov ah, 00                      ;��������� �����������
    mov al, 01                      ;40x25 16-������� ����� � �������� ������
    int 10h                 
    call welcomeScreen 
    
    restart:
    ;��������� �������� ������� 
    mov winCount, 30                ;220 ������ �����
    mov score, 0 
    mov previousTime, 0  
    mov ballPositionY, 18
    mov horizontalMovement, 0
    mov verticalMovement, 0 
       
    call setScreen                  ;������� ������ � ��������� ������
    call printScore                 ;������������ ����� �����
    call initPlayField              ;����� ������ � ��������� ������������ ���-�� �����
    call displayPlayField           ;����� ������ �� �����
    call displayPaddle              ;����� ��������� �� �����
    call paddleStart                ;����� ��������� ����� 
    
    ;��������� �������� �������
    mov ah, 01h
    xor cx, cx
    xor dx, dx
    int 1ah
         
    start:
    ;�������� ������� � ������                     
    mov ah, 1
    int 16h
    jz checkTime  
    ;������ ������� �� ������
    xor ah, ah
    int 16h   
    
    
    cmp ah, 4Dh                     ;������� ������  
    je Right
    cmp ah, 4Bh                     ;������� �����
    je Left
    cmp ah, 01h                     ;Esc
    je Esc
    jmp checkTime                   ;�� ���� �� ��������.
    
    Right:
    cmp paddlePosition, 18          ;������ �������
    je checkTime
    inc paddlePosition              ;����� ��������� ������
    call displayPlayField           ;��������� �������� ����
    call displayPaddle              ;��������� ���������
    call displayBall                ;��������� ����
    jmp checkTime
    
    Left:
    cmp paddlePosition, 0           ;����� �������
    je checkTime             
    dec paddlePosition              ;����� ��������� �����  
    call displayPlayField           ;��������� �������� ����
    call displayPaddle              ;��������� ���������
    call displayBall                ;��������� ����
    jmp checkTime  
    
    Esc:
    jmp exit
     
    checkTime: 
    ;��������� ������� �������
    mov ah, 00h
    int 1ah
    push dx 
    
    mov ax, previousTime            ;���������� �������� ��������
    sub dx, ax            
    mov ax, dx                      ;��������� �����
    pop dx
    cmp ax, 3
    jl checkCount                   ;���� ������ ������������  - �� ������ ����
    mov previousTime, dx            ;���������� �������� ��������
    call moveBall                   ;����� ����
    
    ;�������� ����������� � ���������
    cmp ax, 01h
    je Lose 
       
    call displayPlayField           ;��������� �������� ����
    call displayPaddle              ;��������� ���������
    call displayBall                ;��������� ����
    
    checkCount:
    cmp winCount, 0
    jg start
    printScreen winScreen
    jmp restart
      
    
    waitEnter:
    ;�������� ������ ����������
    mov ah, 1
    int 16h
    jz waitEnter 
    ;������ �� ������ ����������
    xor ah, ah
    int 16h
    cmp ah, 1Ch                     ;Enter
    jne notEnter 
    
    Lose: 
    printScreen loseScreen
    
    jmp restart
    
    notEnter:                       
    cmp ah, 01                      ;Esc
    jne waitEnter
    
exit:
;������������ �����������
mov ah, 00
mov al, 03
int 10h 
;���������� ������
mov ah, 4Ch
int 21h  

.data
messageWelcome db 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah
               db 09h, "   Movement:",0Dh ,0Ah
               db 09h, "   Left/Right arrow",0Dh ,0Ah
               db 09h, "   Esc - exit",0Dh ,0Ah
               db 09h, "   Enter - start",0Dh ,0Ah,'$'
                
message db "     Esc - exit     Enter - restart",'$'

;����� �������� ���� 22 ����, ������ 18
playField db 396 dup(00h)
level db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h 
      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
      db 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h  
      db 50h, 50h, 50h, 50h, 20h, 20h, 20h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h
      db 50h, 50h, 50h, 20h, 50h, 50h, 50h, 20h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h
      db 50h, 50h, 50h, 20h, 50h, 50h, 50h, 20h, 50h, 50h, 30h, 30h, 30h, 50h, 40h, 50h, 50h, 50h, 40h, 50h, 50h, 50h
      db 50h, 50h, 50h, 20h, 20h, 20h, 20h, 20h, 50h, 30h, 50h, 50h, 50h, 50h, 40h, 40h, 50h, 40h, 40h, 50h, 50h, 50h
      db 50h, 50h, 50h, 20h, 50h, 50h, 50h, 20h, 50h, 50h, 30h, 30h, 50h, 50h, 40h, 50h, 40h, 50h, 40h, 50h, 50h, 50h
      db 50h, 50h, 50h, 20h, 50h, 50h, 50h, 20h, 50h, 50h, 50h, 50h, 30h, 50h, 40h, 50h, 50h, 50h, 40h, 50h, 50h, 50h
      db 50h, 50h, 50h, 20h, 50h, 50h, 50h, 20h, 50h, 30h, 30h, 30h, 50h, 50h, 40h, 50h, 50h, 50h, 40h, 50h, 50h, 50h
      db 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h
      db 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h, 50h 
      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h 
      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
    
winScreen db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 20h, 00h, 00h, 00h, 20h, 20h
	      db 00h, 00h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 20h, 00h, 00h, 20h, 00h, 00h
	      db 20h, 00h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 20h, 00h, 00h, 20h, 00h, 00h
	      db 20h, 00h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 20h, 00h, 00h, 20h, 00h, 00h
	      db 20h, 00h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 20h, 00h, 00h, 20h, 00h, 00h
	      db 20h, 00h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 00h, 00h, 20h, 00h, 00h
	      db 20h, 00h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 00h, 00h, 20h, 00h, 00h
	      db 20h, 00h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 00h, 00h, 20h, 00h, 00h
	      db 20h, 00h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 00h, 00h, 20h, 00h, 00h
	      db 20h, 00h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 20h, 20h
	      db 00h, 00h, 00h, 20h, 20h, 20h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h 
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h 
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 00h, 00h, 20h, 00h, 00h, 00h, 20h, 20h, 00h
	      db 00h, 00h, 20h, 00h, 00h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 00h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 20h
	      db 00h, 00h, 20h, 20h, 00h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 00h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 20h
	      db 00h, 00h, 20h, 20h, 00h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 00h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 20h
	      db 00h, 00h, 20h, 00h, 20h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h 
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 00h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 20h
	      db 00h, 00h, 20h, 00h, 20h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 00h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 20h
	      db 00h, 00h, 20h, 00h, 00h, 20h, 20h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 00h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 20h
	      db 00h, 00h, 20h, 00h, 00h, 20h, 20h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 20h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 20h
	      db 00h, 00h, 20h, 00h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 20h, 00h, 00h, 00h, 00h, 20h, 20h, 00h
	      db 00h, 00h, 20h, 00h, 00h, 00h, 20h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
          
          
loseScreen db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
 	       db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	       db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 40h, 00h, 00h, 00h, 40h, 40h
	       db 00h, 00h, 00h, 40h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	       db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 40h, 00h, 00h, 40h, 00h, 00h
	       db 40h, 00h, 00h, 40h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	       db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 40h, 00h, 00h, 40h, 00h, 00h
	       db 40h, 00h, 00h, 40h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
 	       db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 40h, 00h, 00h, 40h, 00h, 00h
	       db 40h, 00h, 00h, 40h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	       db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 40h, 00h, 00h, 40h, 00h, 00h
	       db 40h, 00h, 00h, 40h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	       db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 40h, 00h, 00h
	       db 40h, 00h, 00h, 40h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	       db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 40h, 00h, 00h
 	       db 40h, 00h, 00h, 40h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	       db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 40h, 00h, 00h
	       db 40h, 00h, 00h, 40h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	       db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 40h, 00h, 00h
	       db 40h, 00h, 00h, 40h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	       db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 40h, 40h
	       db 00h, 00h, 00h, 40h, 40h, 40h, 40h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	       db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
           db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
           db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 00h, 40h, 40h, 00h, 00h, 00h, 40h
           db 40h, 40h, 40h, 00h, 40h, 40h, 40h, 40h, 40h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h 
           db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 40h, 00h, 00h, 40h
           db 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
           db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 40h, 00h, 00h, 40h
           db 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
           db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 40h, 00h, 00h, 00h
           db 40h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
           db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 40h, 00h, 00h, 00h
           db 40h, 40h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
           db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 40h, 00h, 00h, 00h
           db 00h, 40h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
           db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 40h, 00h, 00h, 00h
           db 00h, 00h, 40h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
           db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 40h, 00h, 00h, 00h
           db 00h, 00h, 40h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
           db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 40h, 40h, 40h, 00h, 00h, 00h, 40h, 40h, 00h, 00h, 00h, 40h
           db 40h, 40h, 40h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 40h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         
	       db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	       db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	       
verticalMovement dw 0       ;0 - �����, 1 - ����
horizontalMovement dw 0     ;0 - �����, 1 - ����


; 0;0 - ������� ����� ���� ����, ������������� ��������                  
ballPositionY dw 18
ballPositionX dw 11
                   
paddlePosition dw 0                   
previousTime dw 0    
score dw 0                       
winCount dw 0 

end main