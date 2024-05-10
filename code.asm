              .data 
STRING1 DB   '******Price list****** $'
STRING2 DB  DB 0AH, 0DH, '-->1 pound for 5 seconds. $'
STRING3 DB  DB 0AH, 0DH, '-->5 pounds for 30 seconds. $'
STRING4 DB  DB 0AH, 0DH, '-->10 pounds for 60 seconds. $' 
MoneyMessage db db 0AH, 0DH, 'Enter the amount of money you will pay (0 to exit): $'      
ExpireMessage db db 0AH, 0DH, 0AH, 0DH, 'Time expired and LED turned red.$'
invalidMessage db db 0AH, 0DH,0AH, 0DH, "undefined value,please enter valid value $"      

.code  

 main proc 
    
 mov ax, @data
 mov ds, ax
  
 ; load address of the strings   
 LEA DX,STRING1
 MOV AH,09H
 INT 21H     
 LEA DX,STRING2
 MOV AH,09H
 INT 21H     
 LEA DX,STRING3
 MOV AH,09H
 INT 21H      
 LEA DX,STRING4
 MOV AH,09H
 INT 21H 
     
main2:  
    
  mov ax, @data
  mov ds, ax
  
  lea dx, MoneyMessage
  mov ah, 09h       ; Display message
  int 21h
   
  mov dl,10 ;intialize dl by 10
  mov bl,0  ;intialize bl by 0   

; Read input  
scanNumber:

      mov ah, 01h
      int 21h

      cmp al, 13   ; if "ENTER"
      je  Return 

      cmp al, '0'   ; Check if the input is a digit
      jl invalid
      cmp al, '9'
      jg invalid

      sub al, '0'   ; ASCII to decimal conversion

      mov cl, al
      mov al, bl   ; bl contains the previous value

      mul dl       ; multiply the previous value with 10

      add al, cl   ; previous * 10 + new value
      mov bl, al

      jmp scanNumber


Return:
  
  ; Check value and choose delay
  cmp bl, 0
  je exit
  
  
  cmp bl, 5
  jl delay_5secN
  
  cmp bl, 10
  jl delay_30secN

  cmp bl, 0Ah
  jge delay_60secN

  ; Invalid value 
  jmp invalid


delay_5secN:
  mov cx, 2700     
  loop $
  dec bl
  cmp bl,0
  jg  delay_5secN
  jmp expired


delay_30secN:
  mov cx, 16000     
  loop $
  sub bl,5
  cmp bl,0
  jg  delay_5secN 
  jmp expired

delay_60secN:
  mov cx, 32500     
  loop $ 
  sub bl,10 
  cmp bl,10
  jge delay_60secN
  cmp bl,5
  jge delay_30secN 
  cmp bl,0
  jg delay_5secN
  jmp expired

expired: 
  ; Display ExpireMessage
  mov ah, 09h
  lea dx, ExpireMessage
  int 21h

  ; Turn on LED (Assume port 199 control LED)
  mov ax, 1
  out 199, ax
  
  jmp main2      ; Repeat the process

invalid: 
  ; Display error message for invalid value
  mov ah, 09h
  lea dx, invalidMessage
  int 21h

  jmp main2      ; Repeat process

exit:
  mov ah, 4Ch   ; Exit program
  int 21h

main endp
end main
