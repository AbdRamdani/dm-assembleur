;RAMDANI Abderrahmane Groupe3
; KESSIR Ouassim Groupe3

DONNE SEGMENT 
    ; jutilise les 10,13 pour le saute de ligne 
    ARRAY  db   0A5h, 30h, 86h, 0FFh, 0C5h, 50h, 7Eh, 00h 
    MESSAGE Db "le tableau contient :$"  
    MESSAGEEntInd db 10,13,"le tableau entre les deux indice $"
    MESSAGEAprTr db   10,13,"Tableau apres le taitement :$" 
    MESSAGEK db 10,13,"donner le nombre de rotation :$"   
    MESSAGER db 10,13,"le tableau apres $" 
    MESSAGERDROIT db " rotation a droite:$"
    MESSAGERGAUCHE db " rotation a gauche:$"  
    MOY db 10,13,"calcule de la moy entre $" 
    débordement db 10,13,"debordement on ne peut pas calculer la moyenne$" 
    MOY2 db 10,13,"la moyenne des element apres la rotation :de $"  
    ERRMOY2 db "ya pas de retation $"
    
DONNE ends 

CODE segment 
    assume CS:CODE , DS : DONNE 
    
    TRIPROC proc 
        mov bp,sp 
        mov si ,[bp+2]
        mov dx, [bp+4]
        dec dx ; car on bascule jusqua n-1 case   
        cont:
            mov cx , dx 
            mov bx , si 
            mov al , [bx]
        plus:
            inc bx 
            cmp al , [bx]
            jge saut ; si la valeur est > de 5       ;
            ;JGE si sup ou egale dans le cas signé  
            ;jae non signé 
            xchg al , [bx]
        saut: 
            loop plus 
            mov [si], al 
            inc si  
            dec dx 
            jnz cont
            
                ; ca marche bien si on transforme les chiffre dans var en octet
        RET 
    TRIPROC   ENDP
    
    
    AFFICHAGE proc 
        mov bp,sp 
        mov si , [bp+2]
        mov cx , [bp+4]
        
        debut: 
           ; mov al , byte ptr([si]) ; mov al , [si] ; pour avoir le byte le plus bas  
            mov al , [si]
            xor ah , ah ; mov ah , 0 
            push ax ; 00chiffre 
            call AFFICHEELMT 
            pop ax ; pour vider la pile a chaque fois 
            inc si ; pour passer a la prochaine case
            ;mov dl ,9 ; 9 c le code asci de la tab donc 3 espace entre les valeur afficher 
            mov dl , 44 ; 44=,
            mov ah,2 
            int 21h
            loop debut 
       ret 
    endp AFFICHAGE 
    
    
   AFFICHEELMT proc 
    mov bp,sp 
    mov ax , [bp+2] ; la valeur a afficher qu'on a empiler 
    mov bl ,16    
    xor di ,di 
    debutAf: 
        inc di 
        div bl  
        mov dl , ah 
        push dx ; la valeur qu'on va afficher 
        xor ah , ah 
        cmp al , 0 
        jnz debutAf 
    afficher: 
        pop dx ; 
        cmp dl , 9 ; si la val est sup ou egale a 9
        ja affichersup10  
        add dl , 48 ; car le code de 0 est 48
        mov ah , 2 
        int 21h 
        dec di 
        jnz afficher     
        jmp addH      ; on passe pour ajouter un H si cest la fin de notre affichage 
    affichersup10: 
        add dl , 55 ; pour afficher le A commence de 65 donc 65-10=55  
        mov ah , 2 
        int 21h 
        dec di 
        jnz afficher              
    addH:
        mov dl, 'H' ; on ajoute le H a la fin de notre chiffre 
        mov ah, 2
        int 21H
        ret
   endp AFFICHEELMT
   
   
   afficherTab proc 
        mov bp,sp 
        mov si , [bp+2]
        mov cx , [bp+4]     ; adresse de fin 
        mov bx , [bp+6]     ;adresse de debut
        dec bx      
        sub cx,bx ; pour avoir le nombre des element a afficher 
        add si ,bx   ; le 1er element a afficher       ex position 3 [si+2]
        debutTr: 
           ; mov al , byte ptr([si]) ;  pour avoir le byte le plus bas  
            mov al , [si]
            xor ah , ah ; mov ah , 0 
            push ax  
            call AFFICHEELMT 
            pop ax ; pour vider la pile a chaque fois 
            inc si ; pour passer a la prochaine case
            mov dl , 44 ; 44=,
            mov ah,2 
            int 21h
            loop debutTr
    
    ret
   endp afficherTab  
   
   
   rotationElements proc 
        mov bp ,sp 
        mov  ax , [bp+6]      ; droite /gauche 
        mov  bx, [bp+8]       ; nombre de rotation   
        dec cx
        cmp bx , 0  ; on doit verifie le nombre de rotation  si il est different de 0
        jz endd
        cmp ax ,0
        jz gauche ; 0=rotation gauche 
        ; sinon droite   
        droite:
            mov si , [bp+2] 
            mov  cx , [bp+4]   
            dec cx ; car on bascule n-1  
            add si , cx 
            mov dl , [si] ; on stock la dernier valeur 
        rotationD:
            mov ax , [si-1] 
            mov [si],ax
            dec si 
            loop rotationD 
            mov [si] , dl        ; la premiere case avec la derniere  
            dec bx    
            jnz droite  
            jmp endd 
            
         gauche: 
            mov  si, [bp+2] ; la 1er case de tableau  
            mov  cx , [bp+4] 
            mov dl , [si] ; on stock la 1er valeur de notre tableau  
            dec cx; car on bascule pas jusqu'a la derniere 
            ;xor di , di ; di est notre compteur 
        rotationG:
            ;inc di 
            mov ax , [si+1]
            mov [si], ax 
            inc si ; la prochaine caise a remplir
            loop rotationG ; on fait que 7 rotation donc di<8  
            mov [si] , dl        ; la derniere case 
            dec bx    
            jnz gauche 
            
        endd:
            ret 
    endp rotationElements  
   
   
   calculeMoy proc 

    mov bp,sp 
    mov si , [bp+2]    ; @ de 1er elmt de tab 
    mov cx , [bp+4]     ; adresse de fin de calcule 
    mov bx , [bp+6]     ;adresse de debut   de calcule 
    dec bx           
    sub cx,bx ; pour avoir le nombre des element a calculer 
    mov di , cx ; on sauvgarde le nombre des element qu'on va afficher 
    add si ,bx   ; le 1er element a afficher
    xor bx , bx ; on stock dans bx 
    xor ax , ax ; on stock dans ax
    debu: 
        mov al  , [si]
        cbw 
        test ax , ax 
        js negatif ; on verifie si il est negatif ou nan 
    ;dans le cas ou elle est positif 
        add bl ,al   
        
        jo deb
        jmp suite 
    negatif: 
        neg al 
        sub bl ,al 
        jo deb
        jmp suite
    
    suite: 
        inc si 
        loop debu 
        ; on calcule la moyenne 
        mov al , bl  ; on recupere la somme 
        cbw     ; on verifie si la moyenne est positif ou negatif 
        test ax , ax 
        js negatifmoy
        jmp divvv
    negatifmoy:
        mov dl ,  45 ; on ajoute le -
        mov ah , 2 
        int 21h 
        mov al , bl ; car la valeur de al va se changer apres l'appel a l'interuption 
        neg al 
         
     divvv: 
        xor ah ,ah  
        mov bx , di ; le nombre des element qu'on a valvuler 
        div bl  
        xor cx , cx 
        mov cl , ah ; le reste apres la , 
        xor ah , ah 
        push ax 
        call AFFICHEELMTDecimal
        pop ax  
        cmp cx ,0 
        jnz apresVirgule ; on verifie si il ya un reste de la division 
        ret

    apresVirgule:
          
        mov dl , 44 ; la , 
        mov ah , 2 
        int 21h 
        push cx  
        call AFFICHEELMTDecimal   
        pop ax ; on enleve la valeur qu'on a pushé pour revenir a notre programme principale 
        ret   

    deb: 
        lea dx ,débordement
        mov ah , 9 
        int 21h 
        ret 
    
   endp calculeMoy  
              
              
              ; pour afficher la moyenne en decimal 
   AFFICHEELMTDecimal proc 
    mov bp,sp 
    mov ax , [bp+2] ; la valeur a afficher qu'on a empiler 
    xor di , di 
    mov bl ,10
    debutAff: 
        inc di 
        div bl  
        mov dl , ah 
        push dx ; la valeur qu'on va afficher 
        xor ah , ah 
        cmp al , 0 
        jnz debutAff    
        
         
   afficherr: 
        pop dx ; 
        add dl , 48 ; car le code de 0 est 48
        mov ah , 2 
        int 21h 
        dec di 
        jnz afficherr 
        
        ret
   endp AFFICHEELMTDecimal 
                   
        ; on cherche l'adresse de premier element a afficher 
   CalculMoyRot proc
    mov bp, sp 
    mov si , [bp+2]
    mov cx , [bp+4]    
    dec cx ; car on test au max 7 fois 
    mov di , 2 ; l'adresse de premier element qu'on cherche  elle commence au min de la 2eme case si on fait une seule roation a droite
    ; la sequance commence si [si]<[si+1]
    debutttt: 
        mov bl , [si]
        cmp bl , [si+1]   
        jae procc ; si [si]<[si+1] donc c le cas qu'on cherche 
        inc si  
        inc di 
        loop debutttt
        ; si on est la donc ya pas de retation 
        lea dx , ERRMOY2
        mov ah , 9
        int 21h 
        ret 
        
    procc:   
    mov dx ,di      ;debut
    push dx  
    ; on affiche la position de debut 
    add dl  ,48
    mov ah,2 
    int 21h   
    mov dl  ,45     ; pour ajouter un - a l'affichage entre 3-6
    mov ah,2 
    int 21h         
    mov dx ,8         ; fin 
    push dx  
    ; on affiche la position de fin 
    add dl  ,48    
    mov ah,2 
    int 21h 
    mov dl ,58 ; pour ajouter les 2 point : a l'affichage 
    mov ah,2 
    int 21h                  
    lea dx , ARRAY
    push dx 
    call calculeMoy   
    pop ax 
    pop ax 
    pop ax  ; pour revenir au sp de notre programme sinon on perds l'@ de retour 
        
    ret 
   endp CalculMoyRot      

    
    
   
        

MAIN: 
    mov ax , offset(DONNE) 
    mov ds ,ax  
    
    
         ;avant le tri  
    lea dx , MESSAGE
    mov ah , 9 
    int 21h  
    push dx 
    lea dx , ARRAY 
    push dx 
    call AFFICHAGE   
    
        
        ;affichage entre 2 indice 
    lea dx , MESSAGEEntInd  
    mov ah ,9 
    int 21h 
    mov dx ,2       ;debut
    push dx  
    add dl , 48      
    mov ah , 2
    int 21h
    mov dl  ,45     ; pour ajouter un -
    mov ah,2 
    int 21h 
    mov dx ,6          ; fin 
    push dx   
    add dl , 48      
    mov ah , 2
    int 21h   
    mov dl ,58 ; pour ajouter les 2 point   :
    mov ah,2 
    int 21h                  
    lea dx , ARRAY
    push dx 
    call afficherTab
    
    
    ; POUR LE TRI 
    mov dx , 8 
    push dx 
    lea dx , ARRAY 
    push dx 
    call TRIPROC   
    
          
      ; affichage apres le tri 
    lea dx , MESSAGEAprTr
    mov ah , 9 
    int 21h
    mov dx , 8 
    push dx 
    lea dx , ARRAY 
    push dx 
    call AFFICHAGE   
    
          
          ; la rotation 
    lea dx , MESSAGER
    mov ah , 9 
    int 21h    
    mov dx , 2 ;k  nombre de rotation 
    push dx   
    add dl , 48 
    mov ah , 2 
    int 21h 
    mov dx, 1; 0 gauche /sinon droite  
    push dx 
    cmp dx , 0 
    jnz s
    lea dx ,MESSAGERGAUCHE ; on afficher message de rotation a gauche
    mov ah , 9 
    int 21h   
    jmp sss
    s:
    lea dx ,MESSAGERDROIT
    mov ah , 9 
    int 21h 
    sss:
    mov dx , 8 
    push dx 
    lea dx , ARRAY 
    push dx   
    call rotationElements
          ; affichage apres la rotation 
    mov dx , 8 
    push dx 
    lea dx , ARRAY 
    push dx 
    call AFFICHAGE 
           
     
          ; calcule de la moyenne entre i et j   
          ;    1er ex : 86h+7Eh+50H=  -122+126+80/3=28
    lea dx , MOY
    mov ah , 9 
    int 21h    
    mov dx ,2      ;debut  i
    push dx  
    ; on affiche la position de debut 
    add dl  ,48
    mov ah,2 
    int 21h   
    mov dl  ,45     ; pour ajouter un - a l'affichage entre 3-6
    mov ah,2 
    int 21h         
    mov dx ,4        ; fin   j
    push dx  
    ; on affiche la position de fin 
    add dl  ,48    
    mov ah,2 
    int 21h 
    mov dl ,58 ; pour ajouter les 2 point : a l'affichage 
    mov ah,2 
    int 21h                  
    lea dx , ARRAY
    push dx 
    call calculeMoy   
    
        ;calcule de la moy apres la rotation 
    lea dx ,MOY2 
    Mov ah , 9 
    int 21h 
    mov dx , 8 
    push dx 
    lea dx, ARRAY 
    push dx 
    call CalculMoyRot
    
     
    
    
    
    
    mov ah , 4ch 
    int 21h 
CODE ENDS 
END MAIN 