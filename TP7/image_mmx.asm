; IMAGE.ASM
;
; MI01 - TP MMX 7
 

.686
; Instructions MMX
.MMX
.MODEL FLAT, C

.DATA
	
.CODE

; **********************************************************************
; Sous-programme _process_image_asm 
; 
; Realise le traitement d'une image 32 bits.
;
; Entrees sur la pile : Largeur de l'image (entier 32 bits)
;			Hauteur de l'image (entier 32 bits)
;			Pointeur sur l'image source (depl. 32 bits)
;			Pointeur sur l'image tampon 1 (depl. 32 bits)
;			Pointeur sur l'image tampon 2 (depl. 32 bits)
;			Pointeur sur l'image finale (depl. 32 bits)
; **********************************************************************

PUBLIC		process_image_mmx

process_image_mmx	PROC NEAR		; Point d'entree du sous programme
		
		push    ebp
		mov     ebp, esp

		push    ebx
		push    esi
		push    edi
		
		mov     ecx, [ebp + 8]		; biWidth
		imul    ecx, [ebp + 12]		; biWidth * biHeight

		mov     esi, [ebp + 16]		; img_src
		mov     edi, [ebp + 20]		; img_tmp1

		;*****************************************************************
		;*****************************************************************
		
		PUSH EAX					; sauvegarde des différents parametres
		PUSH EBX					; 
		PUSH EDX					;
		
		;*****************************************************************
		; Ajout TP7
		;*****************************************************************


		MOV EAX, 4D961Dh		; Inivitalisation d'EAX avec les constantes
		MOVD MM1, EAX			; Instructions spéciales de MMX pour stocker les constantes dansun registre spécifique : MM1
		PUNPCKLBW MM1, MM1		; Répartition des cosntantes prélablement stockées dans MM1 dans les "words"
		PSRLW MM1, 8			; Décalage à droite de chaque composante pour les calculs à venir

		
traitement:

		DEC ECX				; Passage au pixel précédent
		
		MOV EAX, [ESI+ECX*4]		; On récupère les 4 * 8 bits qui sont les 4 compostantes d'un pixel,
		MOVD MM0, EAX			; On les charge dans un registre MMx nommé M0 de 64 bits,
		PUNPCKLBW MM0, MM0		; On transforme comme précédemment les 8 bits en "words" toujours dans notre registre MM0 
		PSRLW MM0, 8			; On décale vers la droite de 8 bits (un byte) les données contenues dans chaque "word" que l'on vient de récupérer 
	ci-dessus
		PMADDWD MM0, MM1		; Traitement sur les poids faibles des registres MM0 et MM1 : on multiplie puis on additionne les "dword" 
	correspondant
		MOVD EAX,MM0			; Stockage, ensuite, de la partie basse de MM0 dans EAX
		MOVD MM2, EAX			; Transfert, toujours de la partie vers dans MM2 par EAX
		PSRLQ MM0, 32			; Mélange de 32 bits vers la droite dans MM0 (on appelle ce procédé "shift" de la partie haute 
	vers la partie droite)
		PADDD MM0,MM2			; Dernière addition : ajoute la partie basse de MM0 shifté avec MM2 
		PSRLQ MM0, 8			; On décale pour compenser le décalage précédemment récupérer avec le traitement par constantes entières 
	puis on place la valeur dans le pixel bleu,
		

		;*****************************************************************
		; Traitement commenté et mis du côté du TP 5
		;*****************************************************************

		;MOV EDX, [ESI + ECX*4]			; edx = @pixel
		
		;MOV EAX, EDX				; copie du pixel dans eax
		;AND EAX, 000000FFh			; masque pour B
		;IMUL EAX, 29				; multiplication 0.114*256
		;MOV EBX, EAX				; sauvegarde du résultat pour bleu dans eax
		
		;MOV EAX, EDX				; copie du pixel dans EAX

		;AND EAX, 0000FF00h			; masque pour G
		;SHR EAX, 8				; on decale vers le bleu
		;IMUL EAX, 150				; on multiplie 0.587*256
		;ADD EBX, EAX				; sauvegarde dans EBX de la somme pour B+G
		
		;MOV EAX, EDX				; copie du pixel dans EAX
		;AND EAX, 00FF0000h			; masque pour R
		;SHR EAX, 16				; décalage vers le bleu
		;IMUL EAX, 77				; multiplication 0.299*256
		;ADD EBX, EAX				; sauvegarde dans EBX = B + G + R
		
		SHR EBX, 8				; on supprime le decalage sur EBX (stockage dans le bleu)

		MOVD EAX, MM0
		MOV [EDI + ECX*4], EAX		; on enregistre le pixel dans l'image suivante
		CMP ECX, 0
		
		JNE traitement				; on repete jusqu'au dernier pixel

		POP EDX					; on remet les registres dans leur état initial : cad avant l'appel
		POP EBX
		POP EAX
		;*****************************************************************
		;*****************************************************************
			
fin:
		emms		
		pop     edi
		pop     esi
		pop     ebx

		pop     ebp

		ret			                ; Retour de la fonction MainWndProc


	
process_image_mmx	ENDP

	  END
