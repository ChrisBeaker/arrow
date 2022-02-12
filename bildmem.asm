ZEILE     equ       25d
SPALTE    equ       80d

PUBLIC    BILDSPEICHER     

PUBLIC    BILDEIN             ; Name der Unterroutine bekanntgeben
PUBLIC    BILDAUS             ;   "          "              "

          ASSUME CS:CODE,DS:DATA,SS:NOTHING,ES:BILD  

BILD      SEGMENT AT 0B800h   "Bildschirm Speicher 0B800H)"
BILD      ENDS

DATA      SEGMENT  "Datenseg. aus Bildmem"
BILDSPEICHER   db   ZEILE * SPALTE * 2 dup(0)
DATA      ENDS

CODE      SEGMENT  "Codeseg. aus bildmem"
BILDEIN   PROC      NEAR
          
          PUSH      ax        ; Benîtigte Register sichern
          PUSH      bx
          PUSH      cx
          PUSH      es
          PUSH      ds
          
          mov       ax,BILD
          mov       es,ax

          mov       ax,DATA
          mov       ds,ax

          mov       cx,ZEILE * SPALTE * 2
          xor       bx,bx
          xor       ax,ax

schleife9: 
          mov       al,Byte ptr es:[bx]
          mov       Byte ptr ds:[BILDSPEICHER+bx],al
          inc       bx
          loop      schleife9
          
          POP       ds
          POP       es        ; GeÑnderte Register zurÅckholen
          POP       cx        ; GeÑnderte Register zurÅckholen
          POP       bx        ; GeÑnderte Register zurÅckholen
          POP       ax        ; GeÑnderte Register zurÅckholen
          
          RET                 ; Unterprogramm verlassen
BILDEIN   ENDP
;----------------------------------------------------------------------------
BILDAUS   PROC      NEAR
          
          PUSH      AX        ; Benîtigte Register sichern
          PUSH      BX
          PUSH      CX
          PUSH      ES
          PUSH      DS

          mov       ax,DATA
          mov       ds,ax

          mov       ax,BILD
          mov       es,ax
          mov       cx,SPALTE * ZEILE * 2
          
          xor       ax,ax
          xor       bx,bx

schleife6:          
          mov       al,Byte ptr ds:[BILDSPEICHER+bx]
          mov       byte ptr es:[bx],al
          inc       bx
          loop      schleife6

          POP       DS
          POP       ES
          POP       CX
          POP       BX
          POP       AX

          RET                 ; Unterprogramm verlassen
BILDAUS   ENDP

CODE      ENDS
          END     
