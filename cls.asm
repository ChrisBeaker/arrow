ZEILE     EQU       25d
SPALTE    EQU       80d

PUBLIC    CLS                 ; Name der Unterroutine bekanntgeben

          ASSUME CS:CODE,DS:DATA,SS:NOTHING,ES:NOTHING

DATA      SEGMENT
DATA      ENDS

CODE      SEGMENT
CLS       PROC      NEAR
          PUSH      BX        ; Benîtigte Register sichern
          PUSH      CX
          PUSH      ES          

          MOV       BX,0B800h
          MOV       ES,BX

          XOR       BX,BX
          MOV       CX,SPALTE*ZEILE

SCHLEIFE:
          MOV  BYTE PTR  ES:[BX],' '
          mov  byte ptr  es:[bx+1],0h

          INC       BX
          INC       BX
          LOOP      SCHLEIFE

          POP       ES
          POP       CX
          POP       BX        ; GeÑnderte Register zurÅckholen
          RET                 ; Unterprogramm verlassen
CLS       ENDP
CODE      ENDS
          END     
