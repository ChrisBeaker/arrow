         .286
PUBLIC  RAHMEN

        ASSUME CS:CODE,DS:CODE,SS:CODE,ES:BILD

BILD    SEGMENT AT 0b800h
BILD    ENDS

;  BX (ZEILEA,SPALTEA)
;  DX (ZEILEB,SPALTEB)

CODE    SEGMENT
RAHMEN   proc      Near

          pusha
          push      es
          push      ds

          mov       ax,BILD         ;lade bildspeicher-Adresse
          mov       es,ax           ;nach es
          xor       ax,ax           ;lîsche ax Register

;---------------------------------------------------------------------------
          mov       al,bh           ; bx = (Spalte B / Spalte A)
          xor       bh,bh           ; dx = (Zeile  B / Zeile  A)
          mov       bh,dl           ; hier werden die Register BH mit BL
          xor       dl,dl           ; vertauscht
          mov       dl,al
;---------------------------------------------------------------------------
Zeile_A_B:xor       ax,ax           ;AX wird gelîscht
          mov       al,2d
          mul       bl
          xor       bl,bl           ;Spalte A wir aubereitet (Wert * 2)
          mov       bl,al           ;und zurÅckgeschrieben nach bl

          xor       ax,ax
          mov       al,2d
          mul       bh
          xor       bh,bh           ;Spalte B wir aubereitet (Wert * 2)  
          mov       bh,al           ;und zurÅckgeschrieben nach bh 

Ecke1:    xor       ax,ax           ;ax wird gelîscht
          mov       al,160d
          mul       dl              ;Zeile A wird mit 160 multiplizier
          add       al,bl           ;addiere Zeile A mit Spalte A
          mov       si,ax           ;sichere Wert nach SI
          push      si              ;Ergebnis auf Stack fÅr Ende des Stiches
          sub       al,bl           ;subrt. Spalte A von Zeile A
          push      ax              ;Zeilenanfang auf den Stack 
          mov  byte ptr es:[si],"⁄"      ;SI = Ecke1
          mov  byte ptr es:[si+1],cl

Ecke2:    xor       ax,ax           ;seber beschi· wie oben nur mit dem
          mov       al,160d         ;unterschied das Ecke = DI ist
          mul       dh
          push      ax              ;Zeile B auf Stack
          add       al,bl           ;addiere Spalte A mit Zeile B
          mov       di,ax
          mov  byte ptr es:[di],"¿"      ;DI = Ecke2
          mov  byte ptr es:[di+1],cl

          add       si,160d         ;erhîhe Eckewert1 um eine Zeile

linker_Strich:
          mov  byte ptr es:[si],"≥"      ;SI wird verÑnder um einen 
          mov  byte ptr es:[si+1],cl
          add       si,160d             ;senkrechten Strich zu erhalten
          cmp       si,di               ;vergleiche Strich mit Ecke2
          jb        linker_Strich

Ecke3:    xor       dx,dx
          pop       dx                  ;hole Zeile A vom Stack
          xor       ax,ax
          mov       al,bh                  
          add       dx,ax               ;Addiere Spalt B und Zeile B
          xor       si,si
          mov       si,dx
          mov  byte ptr es:[si],"Ÿ"   ;SI = Ecke 3
          mov  byte ptr es:[si+1],cl

          add       di,2d                ;erhîhe Eckwert3 um eine Spalte

untere_Strich:
          mov  byte ptr es:[di],"ƒ"  ;DI wir verÑndert um einen
          mov  byte ptr es:[di+1],cl
          add       di,2d                 ;wagerechten Strich zu erhalten
          cmp       di,si                 ;Vergleiche Strich mit Ecke3
          jb        untere_Strich

Ecke4:    xor       dx,dx
          pop       dx                    ;hole Zeile A vom Stack
          xor       ax,ax
          mov       al,bh
          add       dx,ax                 ;addiere Zeile A mit Spalt B
          xor       di,di
          mov       di,dx
          mov  byte ptr es:[di],"ø"  ;di = Eckwert4
          mov  byte ptr es:[di+1],cl

          sub       si,160d               ;verringere Ecke3 um eine Zeile

rechter_Strich:
          mov  byte ptr es:[si],"≥"
          mov  byte ptr es:[si+1],cl
          sub       si,160d
          cmp       si,di
          ja        rechter_Strich

          xor       dx,dx
          sub       di,2d                 ;verringere Ecke4 um eine Spalte
          pop       dx                    ;hole Adresse von Ecke1 nach DX

oberer_Strich:
          mov   byte ptr es:[di],"ƒ"
          mov   byte ptr es:[di+1],cl
          sub       di,2d
          cmp       di,dx                 ;vergleiche Strich mit Ecke1
          ja        oberer_Strich
          
          pop       ds
          pop       es
          popa
          ret

RAHMEN   endp

CODE    ENDS
        END  
