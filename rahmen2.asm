;---------------------------------------------------------------------------
;
;                      cls_RAHMEN.ASM
;
;  Stand : 11.02.92
; 
;  Diese Funktion zeichnet einen Rahmen in einer beliebigen Grî·e und einer
;  beliebigen Farbe auf den Bildschirm. Der Aufruf erfolgt folgerderma·en:
;
;        mov       bl,SPALTEA        
;        mov       bh,ZEILEA
;        mov       dl,SPALTEB
;        mov       dh,ZEILEB
;        mov       cx,FARBE
;        CALL      RAHMEN4
;        
;     bl = Spalte des linken Punktes
;     bh = Zeile des oberen Punktes
;     dl = Spalte des rechten Punktes
;     dh = Zeile des unteren Punktes
;     cl = Farbe des Rahmens
;
;---------------------------------------------------------------------------
PUBLIC  CLS_RAHMEN

        ASSUME CS:CODE,DS:CODE,SS:CODE,ES:BILD
         .286

BILD    SEGMENT AT 0b800h
BILD    ENDS

CODE    SEGMENT
CLS_RAHMEN   proc  Near

          pusha                     ;DI,SI,BP,SP,DX,CX,AX
          push      es              ;ES,
          push      ds              ;DS alle Register aus Stack

          mov       ax,BILD         ;Segmentanfang nach AX
          mov       es,ax           ;und dann nach ES(b800h)
          
;         mov       bl,SPALTEA      ;Spalte_A nach BL  
;         mov       bh,ZEILEA       ;Zeile_A  nach BH
;         mov       dl,SPALTEB      ;Spalte_B nach DL
;         mov       dh,ZEILEB       ;Zeile_B  nach DH
;         mov       cl,FARBE        ;Farbe 0_0000_000 (Blin./Hinter/Vorder)

          xchg      bh,dl           ;vertausch BH mit DL Register
          mov       cx,0d           ;Attribut schwarz
;---------------------------------------------------------------------------
Spalte_A_B:
          shl       bl,1            ;BL wird mit Zwei Multi.
          shl       bh,1            ;BH wird mit Zwei Multi.
;---------------------------------------------------------------------------
Zeile_A:  mov       ax,160d
          mul       dl              ;Zeile A wird mit 160 multiplizier
          mov       si,ax           ;sichere Wert nach SI (Zeile_A)

Zeile_B:  mov       ax,160d         ;
          mul       dh              ;Zeile B wird mit 160 multi.
          mov       di,ax           ;sichere Wert nach DI (Zeile_B)
;---------------------------------------------------------------------------          
          mov       dl,bh           ;sichere Spalte B nach DL
          xor       bh,bh           ;dann lîsche Register Bh
          
          mov   byte ptr es:[si+bx]," "    ;Zeile_A + Spalte_A     
          mov   byte ptr es:[si+bx+1],cl
          mov   byte ptr es:[di+bx]," "    ;Zeile_B + Spalte_A
          mov   byte ptr es:[di+bx+1],cl
          
          push      si              ;sichere Zeile A auf Stack

          add       si,160d         ;verringere Zeile A um eine Zeile

linker_Strich:
          mov   byte ptr es:[si+bx]," "    ;Zeile_A + (ZÑhler)
          mov   byte ptr es:[si+bx+1],cl
          
          add       si,160d         ;verringere Zeile A um eine Zeile 
          cmp       si,di           ;Vergleiche Strich mit Zeile_B
          jb        linker_Strich
          
          pop       si              ;hole Zeile A wieder vom Stack
          
          push      bx              ;Sichere Spalte A
          inc       bx
          inc       bx              ;erhîhe   Spalte A

unterer_Strich:
          mov   byte ptr es:[di+bx]," "    ;Zeile_B + (ZÑhler)
          mov   byte ptr es:[di+bx+1],cl
          inc       bl
          inc       bl              ;erhîhe Spalte A um eine Spalte
          cmp       bl,dl           ;Vergleiche Strich mit Spalte_B
          jb        unterer_Strich
          
          pop       bx              ;hole Spalte A zurÅck vom Stack
          inc       bl
          inc       bl              ;verringer Spalte A um eine Spalte

oberer_Strich:
          mov   byte ptr es:[si+bx]," "    ;Zeile_A + (ZÑhler)
          mov   byte ptr es:[si+bx+1],cl
          inc       bl
          inc       bl              ;verringere Spalte A um eine Spalte
          cmp       bl,dl           ;Vergleiche Strich mit Spalte_B
          jb        oberer_Strich

          mov       bl,dl           ;Zeile_B nach BL

          mov   byte ptr es:[si+bx]," "    ;Zeile_A + Spalte_B
          mov   byte ptr es:[si+bx+1],cl 
          mov   byte ptr es:[di+bx]," "    ;Zeile_B + Spalte_B
          mov   byte ptr es:[di+bx+1],cl 
          
          add       si,160d         ;Verringere Zeile A um eine Zeile

rechter_Strich:
          mov   byte ptr es:[si+bx]," "    ;Zeile_A + (ZÑhler)
          mov   byte ptr es:[si+bx+1],cl 
          
          add       si,160d         ;Verringer Zeile A um eine Zeile
          cmp       si,di           ;vergleiche Strich mit Zeile_B
          jb        rechter_Strich  
          
          pop       ds
          pop       es
          popa
          ret

CLS_RAHMEN  endp

CODE    ENDS
        END   
