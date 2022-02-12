EXTRN   BILDEIN:NEAR
EXTRN   BILDAUS:NEAR
EXTRN   CLS:NEAR
EXTRN   RAHMEN:NEAR
EXTRN   CLS_RAHMEN:NEAR        
EXTRN   FARBLOCK:NEAR

        ASSUME CS:CODE,DS:DATA,SS:STAPEL,ES:BILD    
        .286

BILD    SEGMENT     AT 0B800h
BILD    ENDS

DATA    SEGMENT

SPALTEA DB  "SPALTE A ","$"
ZEILEA  DB  "ZEILE  A ","$"
SPALTEB DB  "SPALTE B ","$"
ZEILEB  DB  "ZEILE  B ","$"
TEXT    DB  "   F1 = Verschieben ","$"   
TEXT1   DB  "  F2 = Vergrîssern - A = linke o. Ecke B = rechte u. Ecke   ","$"
        

UEBERSETZER  DB "0123456789ABCDEF"

DATA    ENDS

STAPEL  SEGMENT     STACK
        DW 100 DUP (0)
STAPEL  ENDS

CODE    SEGMENT
START:    MOV     DX,DATA              ; Datensegment (DS) auf definiertes
          MOV     DS,DX                ; DATA - Segment setzen
        
          MOV     DX,BILD
          MOV     ES,DX
          XOR     DX,DX

          call      BILDEIN            ;merke bildschirminhalt beim aufruf
;---------------------------------------------------------------------------
          mov       ax,00              ;initialisierung des Mousetreibers
          int       33h

          
          mov       ax,04              ;Mouse position bestimmen
          mov       cx,104d
          mov       dx,312d
          int       33h                ;Mousepunkt ersch. in der mitte 
          
          mov       ax,01              ;mousepunkt darstellen
          int       33h
          
;-------------------------------------------------------------------------
          
          mov       bl,25d             ;Spalte A
          mov       bh,5d              ;Zeile  A

          mov       dl,60d             ;Spalte B
          mov       dh,20d             ;Zeile  B
          mov       cx,00000100b       ;Farbe / rot
          call      cls                ;lîsche gesamten Bildschirm
          call      rahmen             ;zeichne einen Rahmen
          call      koordinaten
;----------------------------------------------------------------------------           
schleife:  
;        ---M-O-U-S-E------------------------------------------------------           
           push     ax
           push     bx
           push     cx
           push     dx

           mov      ax,3d              ;Mouseposition abfraben
           int      33h                ;CX= Horizo
                                       ;DX= Verti
                                       ;BX= Tasten
           cmp      bx,1d              ;linke Taste gedrÅckt ? 1 = JA
           jne      keine_TasteS
           cmp      dx,0d
           jne      Keine_TasteS
           cmp      cx,160d
           jb       keine_TasteS
           
           pop      dx
           pop      cx
           pop      bx
           pop      ax
           
           jmp      ZOOMA 

;---------------------------------------------------------------------
keine_TasteS:
           pop      dx
           pop      cx
           pop      bx
           pop      ax
           
           push     dx
           
           MOV     AH,06h              ; Funktion Eingabe Zeichen ohne BREAK
           mov     dl,0ffh
           INT     21h                 ; DOS-Interrupt aufrufen 
           
           CMP     AL,4bh              ;  Links - Taste 
           JE     FARschleife1

           CMP     AL,4dh              ;  Rechts - Taste 
           JE     FARschleife2

           CMP     AL,50h              ;  Runter - Taste 
           JE     FARschleife3

           CMP     AL,48h              ;  Hoch - Taste 
           JE     FARschleife4

           cmp      al,3ch             ;  fage Tase F2 ab
           je       FARZOOMA
           
           cmp       al,1bh            ;vergleiche mit ESC-Tase
           je        FARSPRUNG         ;wenn gleich dann ende

           pop      dx

           
          jmp     schleife
;---------------------------------------------------------------------------
FARschleife1:  
          pop       dx
          jmp  schleife1
FARschleife2:  
          pop       dx
          jmp  schleife2
FARSCHLEIFE3:  
          pop       dx
          jmp  schleife3
FARSCHLEIFE4:  
          pop       dx
          jmp  schleife4
FARZOOMA:    
          pop       dx
          jmp  ZOOMA
FARSPRUNG: 
          pop       dx
          jmp     ende

;--------------------------------------------------------------------------
ZOOMA:     
          ;---M-O-U-S-E----------------------------------------------------           
           push     ax
           push     bx
           push     cx
           push     dx

           mov      ax,3d              ;Mouseposition abfraben
           int      33h                ;CX= Horizo
                                       ;DX= Verti
                                       ;BX= Tasten
           cmp      bx,1d              ;linke Taste gedrÅckt ? 1 = JA
           jne      keine_Taste
           cmp      dx,0d
           jne      Keine_Taste
           cmp      cx,152d
           ja       keine_Taste
           
           pop      dx
           pop      cx
           pop      bx
           pop      ax
           
           jmp      schleife

;--M-O-U-S-E- -E-N-D-E-----------------------------------------------
keine_Taste:pop      dx
           pop      cx
           pop      bx
           pop      ax
           
           push     dx

           MOV     AH,06h              ; Funktion Eingabe Zeichen ohne BREAK
           mov     dl,0ffh
           INT     21h                 ; DOS-Interrupt aufrufen 
           
           CMP     AL,4bh              ;  Links - Taste 
           JE     FARZSPALTE_A_k

           CMP     AL,4dh              ;  Rechts - Taste 
           JE     FARZSPALTE_A_g

           CMP     AL,50h              ;  Runter - Taste 
           JE     FARZZEILE_A_g

           CMP     AL,48h              ;  Hoch - Taste 
           JE     FARZZEILE_A_k

           cmp      al,62h             ;  frage taste B ab
           je       FARZOOMB
           
           cmp      al,3bh             ; frage Taste F1 ab
           je       FARschleife
           
           cmp       al,1bh            ;vergleiche mit ESC-Tase
           je        FARSPRUNG         ;wenn gleich dann ende

           pop      dx
;------------------------------------------------------------------------
           call     mouse              ;Springe ins Mouse Menue
                                       ;wenn keine Mouse-Taste gedrÅckt wird
                                       ;Spingt das Prog. wieder zurÅck.
;-------------------------------------------------------------------------           
           jmp     ZOOMA    
;------------------------------------------------------------------------

FARZSPALTE_A_g:
          pop       dx
          jmp ZSPALTE_A_g
FARZZEILE_A_g: 
          pop       dx
          jmp ZZEILE_A_g
FARZZEILE_A_k: 
          pop       dx
          jmp ZZEILE_A_k 
FARZSPALTE_A_k: 
          pop       dx
          jmp ZSPALTE_A_k

FARZOOMB:    
          pop       dx
          jmp       ZOOMB
FARschleife:          
          pop       dx
          jmp       schleife
          
;---------------------------------------------------------------------------
schleife1: call     cls_rahmen          ;lîsche bildschirm
           dec      bl                 ;SPALTE A nach links (-1)
           dec      dl                 ;SPALTE B nach links (-1)
           mov      cx,00000100b       ;Farbe
           call     rahmen             ;zeichne Rahmen
           call     koordinaten
           jmp      schleife           ;springe zum Schleifen Anfang
;----------------------------------------------------------------------------

schleife2: call     cls_rahmen          ;lîsche bildschirm 
           inc      bl                 ; Spalte A nach rechts (+1)
           inc      dl                 ; Spalte B nach rechts (+1)
           mov      cx,00000100b       ;Farbe
           call     rahmen
           call     koordinaten
           jmp      schleife
;----------------------------------------------------------------------------
schleife3: call     cls_rahmen          ;lîsche bildschirm
           inc      bh                 ;verringere Zeile A (-1)
           inc      dh                 ;verringere Zeile B (-1)
           mov      cx,00000100b       ;Farbe
           call     rahmen
           call     koordinaten
           jmp      schleife
;----------------------------------------------------------------------------
schleife4: call     cls_rahmen          ;lîsche bildschirm
           dec      bh                 ;erhîhe Zeile A (+1)
           dec      dh                 ;erhîhe Zeile B (+1)
           mov      cx,00000100b
           call     rahmen
           call     koordinaten
           jmp      schleife
;---------------------------------------------------------------------------
ZSPALTE_A_k:call     cls_rahmen          ;lîsche bildschirm    
          dec       bl
          call      rahmen
          call      koordinaten
          jmp       ZOOMA
;---------------------------------------------------------------------------
ZSPALTE_A_g:call     cls_rahmen          ;lîsche bildschirm    
          inc       bl
          call      rahmen
          call      koordinaten
          jmp       ZOOMA
;--------------------------------------------------------------------------
ZZEILE_A_k:call     cls_rahmen          ;lîsche bildschirm    
          dec       bh
          call      rahmen
          call      koordinaten
          jmp       ZOOMA
;--------------------------------------------------------------------------
ZZEILE_A_g:call     cls_rahmen          ;lîsche bildschirm    
          inc       bh
          call      rahmen
          call      koordinaten
          jmp       ZOOMA
;--------------------------------------------------------------------------
FARSPRUNG1:  jmp ende
;------------------------------------------------------------------------
ZOOMB: 
;---M-O-U-S-E-------------------------------------------------------           
           push     ax
           push     bx
           push     cx
           push     dx

           mov      ax,3d              ;Mouseposition abfraben
           int      33h                ;CX= Horizo
                                       ;DX= Verti
                                       ;BX= Tasten
           cmp      bx,1d              ;linke Taste gedrÅckt ? 1 = JA
           jne      keine_TasteB
           cmp      dx,0d
           jne      Keine_TasteB
           cmp      cx,152d
           ja       keine_TasteB
           
           pop      dx
           pop      cx
           pop      bx
           pop      ax
           
           jmp      schleife

;---------------------------------------------------------------------
keine_TasteB:
          pop      dx
          pop      cx
          pop      bx
          pop      ax
           
;---------------------------------------------------------------------------
           push     dx

           MOV     AH,06               ; Funktion Eingabe Zeichen ohne BREAK
           mov     dl,0ffh
           INT     21h                 ; DOS-Interrupt aufrufen 
           
           CMP     AL,4bh              ;  Links - Taste 
           JE     FARZSPALTE_B_k

           CMP     AL,4dh              ;  Rechts - Taste 
           JE     FARZSPALTE_B_g

           CMP     AL,50h              ;  Runter - Taste 
           JE     FARZZEILE_B_g

           CMP     AL,48h              ;  Hoch - Taste 
           JE     FARZZEILE_B_k

           cmp      al,61h             ;  frage taste A ab
           je       FARZOOMA1
           
           cmp      al,3bh             ; frage Taste F1 ab
           je       FARSCHLEIFEa

           cmp       al,1bh            ;vergleiche mit ESC-Tase
           je        FARSPRUNG1        ;wenn gleich dann ende
           
           pop      dx
           
           call     mouse              ;Springe ins Mouse Menue
                                       ;wenn keine Mouse-Taste gedrÅckt wird
                                       ;Spingt das Prog. wieder zurÅck.

           jmp     ZOOMB    
;----------------------------------------------------------------------------
FARZSPALTE_B_k: 
          pop       dx
          jmp ZSPALTE_B_k
FARZSPALTE_B_g: 
          pop       dx
          jmp ZSPALTE_B_g
FARZZEILE_B_g : 
          pop       dx
          jmp ZZEILE_B_g
FARZZEILE_B_k : 
          pop       dx
          jmp ZZEILE_B_k
FARSCHLEIFEa: 
          pop       dx
          jmp schleife
FARZOOMA1:   
          pop       dx
          jmp ZOOMA
;---------------------------------------------------------------------------
ZSPALTE_B_k:call     cls_rahmen          ;lîsche bildschirm    
          dec       dl
          call      rahmen
          call      koordinaten
          jmp       ZOOMB
;---------------------------------------------------------------------------
ZSPALTE_B_g:call     cls_rahmen          ;lîsche bildschirm    
          inc       dl
          call      rahmen
          call      koordinaten
          jmp       ZOOMB
;--------------------------------------------------------------------------
ZZEILE_B_k:call     cls_rahmen          ;lîsche bildschirm    
          dec       dh
          call      rahmen
          call      koordinaten
          jmp       ZOOMB
;--------------------------------------------------------------------------
ZZEILE_B_g:call     cls_rahmen          ;lîsche bildschirm    
          inc       dh
          call      rahmen
          call      koordinaten
          jmp       ZOOMB
;--------------------------------------------------------------------------

koordinaten         proc
           push       cx
           push       si
           push       di
           push       dx
           push       bx
;------------------------------------------------------------------------                                                 
           
           mov      cx,20d                                      
           xor      si,si
           mov      di,0d
schTEXT:   mov      al,byte ptr ds:[TEXT+si]
           mov      byte ptr es:[di],al
           mov      byte ptr es:[di+1],00100000b
           inc      si
           inc      di
           inc      di
           loop     SchTEXT                                      
                                                 
           mov      cx,60d                                      
           xor      si,si
           mov      di,40d
schTEXT1:  mov      al,byte ptr ds:[TEXT1+si]
           mov      byte ptr es:[di],al
           mov      byte ptr es:[di+1],00110000b
           inc      si
           inc      di
           inc      di
           loop     SchTEXT1                                      
                                                 ;bl wird ausgewertet
           mov      cx,09d                       ;schleife fÅr 9 Zeichen
           xor      si,si                        ;lîsche si
           mov      di,3850d                     ;lîsche di
SP_A:      mov      al,byte ptr ds:[SPALTEA+si]  ;Adresse von SPALTEA nach al
           mov      byte ptr es:[di],al          ;ASCI-Zeichen in Bildspeich.
           mov      byte ptr es:[di+1],10d       ;Attribut (rot)
           inc      si                           ;erhîhe si nÑchstes Zeichen
           inc      di                           ;Zeichenposition um eins
           inc      di                           ;nach rechts
           loop     SP_A                         ;hole nÑchstes Zeichen
;------------------------------           
           Push     bx
           push     bx
           and      bl,0f0h
           shr      bl,4d
           xor      bh,bh
           mov      ah,[UEBERSETZER+bx]
           mov      byte ptr es:[di],ah
           mov      byte ptr es:[di+1],00001111b
           pop      bx
           and      bl,0fh
           xor      bh,bh
           inc      di
           inc      di
           mov      ah,[UEBERSETZER+bx]
           mov      byte ptr es:[di],ah
           mov      byte ptr es:[di+1],00001111b
           pop      bx
;------------------------------
           mov      cx,09d
           xor      si,si
           mov      di,3890d
ZE_A:      mov      al,byte ptr ds:[ZEILEA+si]
           mov      byte ptr es:[di],al
           mov      byte ptr es:[di+1],10d  
           inc      si
           inc      di
           inc      di
           loop     ZE_A
;-------------------------------
           xchg     bh,bl                           ;vertausche BH bit BL
;------------------------------           
           Push     bx                              ;(bh) wird ausgewertet
           push     bx
           and      bl,0f0h
           shr      bl,4d
           xor      bh,bh
           mov      ah,[UEBERSETZER+bx]
           mov      byte ptr es:[di],ah
           mov      byte ptr es:[di+1],00001111b
           pop      bx
           and      bl,0fh
           xor      bh,bh
           inc      di
           inc      di
           mov      ah,[UEBERSETZER+bx]
           mov      byte ptr es:[di],ah
           mov      byte ptr es:[di+1],00001111b
           pop      bx
;------------------------------
           xchg     bl,bh                          ;tausche re BL mit BH
;------------------------------           
           mov      cx,09d
           xor      si,si
           mov      di,3930d
SP_B:      mov      al,byte ptr ds:[SPALTEB+si]
           mov      byte ptr es:[di],al
           mov      byte ptr es:[di+1],10d  
           inc      si
           inc      di
           inc      di
           loop     SP_B
;--------------------------------
           xchg     bx,dx                ;vertausche Register BX mit DX
;------------------------------           
           Push     bx                   ;sichere 2 * Wert auf Stack 
           push     bx                   ; BX (SPALTE/ZEILE)
           and      bl,0f0h              ;selektiere BL f0
           shr      bl,4d                ;verschiebe BL 0f
           xor      bh,bh                ;lîsche BH .BX fÅr Adressierung
           mov      ah,[UEBERSETZER+bx]  ;(1234..abc..) ASCI - Aufbereitung
           mov      byte ptr es:[di],ah  ;Bildsch.spei.+ Posit. ,Zeichen
           mov      byte ptr es:[di+1],00001111b  ;Attribut (rot)
           pop      bx                   ;hole Wert vom Stack
           and      bl,0fh               ;selektiere BL 0f
           xor      bh,bh                ;lîsche BH. BX fÅr Adressierung
           inc      di                   ;Zeichen Position um eins nach
           inc      di                   ;rechts
           mov      ah,[UEBERSETZER+bx]  ;(123..ABC..) ASCI _ Aufbereitung
           mov      byte ptr es:[di],ah ; Bildch.spei. + Posit. , Zeichen
           mov      byte ptr es:[di+1],00001111b  ;Attribut  (rot)
           pop      bx                   ;hole Wert vom Stack BX (origin.)
;------------------------------
           mov      cx,09d
           xor      si,si
           mov      di,3970d
ZE_B:      mov      al,byte ptr ds:[ZEILEB+si]
           mov      byte ptr es:[di],al
           mov      byte ptr es:[di+1],10d  
           inc      si
           inc      di
           inc      di
           loop     ZE_B
;------------------------------           
           xchg     bh,bl                ;vertausche re DH mit DL
;------------------------------           
           Push     bx
           push     bx
           and      bl,0f0h
           shr      bl,4d
           xor      bh,bh
           mov      ah,[UEBERSETZER+bx]
           mov      byte ptr es:[di],ah
           mov      byte ptr es:[di+1],00001111b
           pop      bx
           and      bl,0fh
           xor      bh,bh
           inc      di
           inc      di
           mov      ah,[UEBERSETZER+bx]
           mov      byte ptr es:[di],ah
           mov      byte ptr es:[di+1],00001111b
           pop      bx
;------------------------------
           
           pop      bx            ;original werte fÅr BX und DX werden
           pop      dx            ;vom Stack geholt deshalb endfÑhlt
           pop      di            ;re Tausch BX mit DX und DH  mit DL
           pop      si
           pop      cx

           ret                
           endp

;---------------------------------------------------------------------------          
Mouse     proc
          push      ax            ;sichere AX Farbe auf Stack
          push      cx            ;sichere CX (Farbe Rahmen)
          push      Bx            ;Sichere Ecke A aus Stack
          push      Dx            ;Sichere Ecke B Auf Stack

          mov       ax,03         ;Funktion Mouseposition prÅfen
          int       33h           ;int 33h aufrufen
          cmp       bx,1          ;prÅfe ob linke Taste gedrÅckt ist
          je        linke_Taste   ;wenn ja dann gehe nach linke_Taste
          cmp       bx,2          ;prÅfe ob rechte Taste gedrÅckt ist
          je        rechte_Taste  ;wenn ja dann gehe nach rechte Taste

          pop       Dx            ;wenn keine Taste oder 3.Taste gedrÅckt
          pop       Bx            ;gedrÅckt ist dann hole Registerinhalt
          pop       cx            ;vom Stack ZurÅck,in folgender Reihenfolge
          pop       ax            ;DX - BX - CX - AX

          ret                     ;springe zurÅck zum Aufrufer

linke_Taste:
          mov       ax,dx               ;lade Y-koord. nach AX
          mov       dx,08d              ;Teiler nach dx
          div       dl                  ;al,ah = ax / dl
          mov       dx,ax               ;und dann nach wieder nach dx

          mov       ax,cx               ;selbe in grÅn wie oben
          mov       cx,08d              ;nur das Ergebnis nach CL
          div       cl
          mov       cx,ax

          mov       ah,dl               ;neue Zeile nach AH
          mov       al,cl               ;neue Spalte nach AL

          pop       Dx                  ;hole alte Koordinaten von Ecke A
          pop       BX                  ;und Ecke B vom Stack zurÅck

          cmp       ax,bx               ;vergleiche neue Koordinaten von 
                                        ;Ecke A mit altem Wert
          pop       cx                  ;hole Farb wert vom Stack 
          pop       ax                  ;und AX zurÅck
          
          je        Move_Ecke_A         ;wenn Koordinaten Åbereinstimmen
                                        ;dann gehe nach Move_Ecke_A
          ret                           ;wenn ungleich gehe zum Aufrufer

Move_Ecke_A:                             
          push      ax                  ;sichere AX Farbe auf Stack
          push      cx                  ;sichere CX (Farbe Rahmen)  
          push      DX                  ;Sichere Ecke A aus Stack
          push      BX                  ;Sichere Ecke B Auf Stack

Moven:    call      cls_Rahmen          ;lîsche Rahmen mit altem Wert
          mov       ax,03               ;funktion Mouseposition prÅfen
          int       33h                 ;int 33h aufrufen
          cmp       bx,1                ;prÅfe ob linke Taste gedrÅckt ist
          je        Move_Ecke_A1        ;wenn JA dann gehe nach Move_Ecke_A1


          pop       BX                  ;wenn Nein dann lade Registen zurÅck
          pop       DX                  ;vom Stack wenn linke Taste schon mal
          pop       CX                  ;gedrÅckt war dann ist Registerinhalt
          pop       AX                  ;von BX und DX verÑndert worden.

          call      rahmen              ;zeichne Rahmen mit altem oder neuen
                                        ;Wert 
          ret                           ;gehe zum Aufrufer zurÅck

Move_Ecke_A1: 
          mov       ax,dx               ;lade Y-koord. nach AX
          mov       dx,08d              ;Teiler nach dx
          div       dl                  ;al,ah = ax / dl
          mov       dx,ax               ;und dann nach wieder nach dx

          mov       ax,cx
          mov       cx,08d
          div       cl
          mov       cx,ax

          mov       bl,cl               ;neue Mousewerte nach BX ( Ecke A)
          mov       bh,dl

          pop       dx                  ;BX mit altem Wert wird zerstîrt
          pop       dx                  ;DX vom Stack wir nach DX geladen

          mov       cx,04               ;farbe fÅr Rahmen
         
          call      rahmen              ;zeichne Rahmen in AbhÑnigkeit von 
                                        ;Mouseposition
          call      koordinaten         ;bringe Koordinaten auf den Schirm


          push      DX                  ;lege neuen Wert aus Regegister BX
          push      BX                  ;und alten Wert DX auf Stack

          jmp       Moven               ;gehe nach Moven
;----------------------------------------------------------------------------
rechte_Taste:
          mov       ax,dx               ;lade Y-koord. nach AX
          mov       dx,08d              ;Teiler nach dx
          div       dl                  ;al,ah = ax / dl
          mov       dx,ax               ;und dann nach wieder nach dx

          mov       ax,cx               ;selbe in grÅn wie oben
          mov       cx,08d              ;nur das Ergebnis nach CL
          div       cl
          mov       cx,ax

          mov       ah,dl               ;neue Zeile nach AH
          mov       al,cl               ;neue Spalte nach AL

          pop       Dx                  ;hole alte Koordinaten von Ecke A
          pop       BX                  ;und Ecke B vom Stack zurÅck

          cmp       ax,DX               ;vergleiche neue Koordinaten von 
                                        ;Ecke B mit altem Wert
          pop       cx                  ;hole Farb wert vom Stack 
          pop       ax                  ;und AX zurÅck
          
          je        Move_Ecke_B         ;wenn Koordinaten Åbereinstimmen
                                        ;dann gehe nach Move_Ecke_A
          ret                           ;wenn ungleich gehe zum Aufrufer

move_Ecke_B:
          push      ax                  ;sichere AX Farbe auf Stack
          push      cx                  ;sichere CX (Farbe Rahmen)  
          push      BX                  ;Sichere Ecke B aus Stack
          push      DX                  ;Sichere Ecke A Auf Stack

Moven1:   call      cls_Rahmen          ;lîsche Rahmen mit altem Wert
          mov       ax,03               ;funktion Mouseposition prÅfen
          int       33h                 ;int 33h aufrufen
          cmp       bx,2                ;prÅfe ob rechte Taste gedrÅckt ist
          je        Move_Ecke_B1        ;wenn JA dann gehe nach Move_Ecke_A1

          pop       DX                  ;wenn Nein dann lade Registen zurÅck
          pop       BX                  ;vom Stack wenn linke Taste schon mal
          pop       CX                  ;gedrÅckt war dann ist Registerinhalt
          pop       AX                  ;von BX und DX verÑndert worden.

          call      rahmen              ;zeichne Rahmen mit altem oder neuen
                                        ;Wert 
          ret                           ;gehe zum Aufrufer zurÅck
          
Move_Ecke_B1: 
          mov       ax,dx               ;lade Y-koord. nach AX
          mov       dx,08d              ;Teiler nach dx
          div       dl                  ;al,ah = ax / dl
          mov       dx,ax               ;und dann nach wieder nach dx

          mov       bx,dx
          
          mov       ax,cx
          mov       cx,08d
          div       cl
          mov       cx,ax

          mov       Dl,cl               ;neue Mousewerte nach DX ( Ecke B)
          mov       Dh,bl

          pop       BX                  ;DX mit altem Wert wird zerstîrt
          pop       BX                  ;BX vom Stack wir nach BX geladen

          mov       cx,04               ;farbe fÅr Rahmen
         
          call      rahmen              ;zeichne Rahmen in AbhÑnigkeit von 
                                        ;Mouseposition
          call      koordinaten         ;bringe Koordinaten auf den Schirm


          push      BX                  ;lege neuen Wert aus Regegister DX
          push      DX                  ;und alten Wert BX auf Stack

          jmp       Moven1              ;gehe nach Moven
;----------------------------------------------------------------------------
          
          
          
          endp

ende:     mov       ax,02d              ;Mousepunkt verbergen 
          int       33h

          call    BILDAUS             ;Gebe Anfangsbildschirm wieder
           
           MOV     AX,4C00h            ; Funktion Programm beenden
           INT     21h                 ; DOS-Interrupt aufrufen

CODE       ENDS
           END     START


