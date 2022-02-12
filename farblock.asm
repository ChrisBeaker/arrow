;---------------------------------------------------------------------------
;
;                          FARBLOCK.ASM
;
;  Stand : 15.03.92
; 
;  Diese Funktion zeichnet einen Farbblock in einer beliebigen Grî·e und einer
;  beliebigen Farbe auf den Bildschirm. Der Aufruf erfolgt folgerderma·en:
;
;        mov       bl,SPALTEA        
;        mov       bh,ZEILEA
;        mov       dl,SPALTEB
;        mov       dh,ZEILEB
;        mov       al,FARBE  0-000-0000 (Blink-hinter-vorder)
;        CALL      RAHMEN4
;        
;     bl = Spalte des linken Punktes
;     bh = Zeile des oberen Punktes
;     dl = Spalte des rechten Punktes
;     dh = Zeile des unteren Punktes
;     al = Farbe des Farbblockes
;
;---------------------------------------------------------------------------
         .286
PUBLIC  FARBLOCK

        ASSUME CS:CODE,DS:CODE,SS:CODE,ES:BILD

BILD    SEGMENT AT 0b800h
BILD    ENDS

CODE    SEGMENT
FARBLOCK  proc      Near

          pusha                     ;Ax,Cx,Dx,Bx,Hilf,Bp,Si,Di
          push      es              ;ES,
          push      ds              ;DS alle Register aus Stack

          mov       cx,BILD         ;Segmentanfang nach CX
          mov       es,cx           ;und dann nach ES(b800h)
          
;---------------------------------------------------------------------------        
          xchg      bh,dl           ;vertausch BH mit DL Register
;---------------------------------------------------------------------------
          push      bx
Spalte_A_B:
          shl       bl,1            ;BL wird mit Zwei Multi.
          shl       bh,1            ;BH wird mit Zwei Multi.
;---------------------------------------------------------------------------
          push      ax              ;sichere Wert fÅr Farbe aus Stack
Zeile_A:  mov       ax,160d         ;160d (abstand einer Zeile)
          mul       dl              ;Zeile A wird mit 160 multiplizier
          mov       si,ax           ;sichere Wert nach SI (Zeile_A)

Zeile_B:  mov       ax,160d         ;
          mul       dh              ;Zeile B wird mit 160 multi.
          mov       di,ax           ;sichere Wert nach DI (Zeile_B)
          pop       ax              ;hole Farb-Wert vom Stack zurÅck
;---------------------------------------------------------------------------          
Punkt_DI: push      bx              ;sichere BX (Spalte A_B)
          xor       bh,bh           ;lîsche HI - Byte BH
          mov       dx,di           ;Wert von DI nach DX
          add       dx,bx           ;Addiere BX mit DX  (Spalte A + Zeile B)
          mov       di,dx           ;neuer Wert DX nach DI
          pop       bx              ;hole alten Wert zurÅck
;---------------------------------------------------------------------------
Punkt_SI: push      bx              ;sicher BX (Spalte A-B)
          xor       bh,bh           ;lîsche BH
          mov       dx,si           ;Wert SI nach DX
          add       dx,bx           ;Addiere DX mit BX  (Spalte A + Zeile A)
          mov       si,dx           ;DX nach SI
          pop       bx              ;hole Wert BX vom Stack zurÅck
;--------------------------------------------------------------------------
          pop       bx              ;hole ursprÅnglichen Wert zurÅck
Strecke:  sub       bh,bl           ;subtrahiere Spalte B - Spalte A
          xor       bl,bl           ;lîsche bl
          xchg      bh,bl           ;vertausche BH mit BL

schleife1:mov       cx,bx           ;Strecke ins CX Reg.
          push      bx              ;sichere Streckenwert auf Stack 
;---------------------------------------------------------------------------
          xor       bx,bx           ;lîsche BX fÅr Adressierung
          add       cx,1d
schleife: mov       byte ptr es:[si+bx+1],al
          inc       bx
          inc       bx
          loop      schleife
;--------------------------------------------------------------------------
          add       si,160d         ;wenn nicht rÅcke eine Zeile runter
          cmp       di,si
          jb         ende1           ;wenn kleiner dann  Ende1
          pop       bx              ;hole Wert fÅr CX vom Stack
          jmp       schleife1       ;gehe schleife1
;--------------------------------------------------------------------------
ende:     pop       ds              ;ofizieles Ende
          pop       es              ;ES ZurÅck
          popa                      ;Di,Si,Bp,Hilf,Bx,Dx,Cx,Ax
          ret                       ;RÅcksprung zum Aufrufer

ende1:    pop       bx              ;hole letzten Wert vom Stack  sauberer
                                    ;Abgang
          jmp       ende            ;gehe nach ende


FARBLOCK  endp

CODE    ENDS
        END   
