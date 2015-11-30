include macros2.asm
include number.asm

.MODEL	LARGE
.386
.STACK 200h

MAXTEXTSIZE equ 50

.DATA

	_n1			dd	?
	_n2			dd	?
	_t1			db	MAXTEXTSIZE dup (?),'$'
	_t2			db	MAXTEXTSIZE dup (?),'$'
	_t3			db	MAXTEXTSIZE dup (?),'$'
	_3			dd	3.0
	_5			dd	5.0
	T_Hola_			db	"Hola $",'$', 44 dup (?)
	T_Mundo			db	"Mundo$",'$', 44 dup (?)
	T_Esto_funciona			db	"Esto funciona$",'$', 36 dup (?)
	_6			dd	6.0
	_AUX_valorFib			dd	?
	_AUX_valorAnterior1			dd	?
	_AUX_valorAnterior2			dd	?
	_AUX_posicion			dd	?
	_0			dd	0.0
	_1			dd	1.0
	_2			dd	2.0
	_7			dd	7.0
	T_Es_mayor_a_7			db	"Es mayor a 7$",'$', 37 dup (?)
	T_No_es_mayor_a_7			db	"No es mayor a 7$",'$', 34 dup (?)
	_10			dd	10.0
	T_Es_mayor_a_5			db	"Es mayor a 5$",'$', 37 dup (?)
	T_No_es_mayor_a_5			db	"No es mayor a 5$",'$', 34 dup (?)
	_aux			db	MAXTEXTSIZE dup (?),'$'
	_msgPRESIONE			db	0DH,0AH,"Presione una tecla para continuar...",'$'
	_NEWLINE			db	0DH,0AH,'$'

.CODE

;************************************************************
; devuelve en BX la cantidad de caracteres que tiene un string
; DS:SI apunta al string.
;
STRLEN PROC
	mov bx,0
STRL01:
	cmp BYTE PTR [SI+BX],'$'
	je STREND
	inc BX
	jmp STRL01
STREND:
	ret
STRLEN ENDP


;*********************************************************************8
; copia DS:SI a ES:DI; busca la cantidad de caracteres
;
COPIAR PROC
	call STRLEN
	cmp bx,MAXTEXTSIZE
	jle COPIARSIZEOK
	mov bx,MAXTEXTSIZE
COPIARSIZEOK:
	mov cx,bx
	cld
	rep movsb
	mov al,'$'
	mov BYTE PTR [DI],al
	ret
COPIAR ENDP


;*******************************************************
; concatena DS:SI al final de ES:DI.
;
; busco el size del primer string
; sumo el size del segundo string
; si la suma excede MAXTEXTSIZE, copio solamente MAXTEXTSIZE caracteres
; si la suma NO excede MAXTEXTSIZE, copio el total de caracteres que tiene el segundo string
;
CONCAT PROC
	push ds
	push si
	call STRLEN
	mov dx,bx
	mov si,di
	push es
	pop ds
	call STRLEN
	add di,bx
	add bx,dx
	cmp bx,MAXTEXTSIZE
	jg CONCATSIZEMAL
CONCATSIZEOK:
	mov cx,dx
	jmp CONCATSIGO
CONCATSIZEMAL:
	sub bx,MAXTEXTSIZE
	sub dx,bx
	mov cx,dx
CONCATSIGO:
	push ds
	pop es
	pop si
	pop ds
	cld
	rep movsb
	mov al,'$'
	mov BYTE PTR [DI],al
	ret
CONCAT ENDP


START:
	mov AX,@DATA
	mov DS,AX
	mov es,ax
	fld _3
	fstp _n1
	fld _5
	fstp _n2
	mov si,OFFSET T_Hola_
	mov di,OFFSET _t1
	call COPIAR
	mov si,OFFSET T_Mundo
	mov di,OFFSET _t2
	call COPIAR
	mov si,OFFSET _t1
	mov di,OFFSET _aux
	call COPIAR
	mov si,OFFSET _t2
	mov di,OFFSET _aux
	call CONCAT
	mov si,OFFSET _aux
	mov di,OFFSET _t3
	call COPIAR
	mov dx,OFFSET _t3
	mov ah,9
	int 21h
	newLine 1
	displayFloat _n1,2
	newLine 1
	displayFloat _n2,2
	newLine 1
	fld _n1
	fld _n2
	fadd
	fstp _n1
	displayFloat _n1,2
	newLine 1
	mov dx,OFFSET T_Esto_funciona
	mov ah,9
	int 21h
	newLine 1
	fld _6
	fld _2
	fxch
	fcomp
	fstsw ax
	ffree st(0)
	sahf
	JAE ET_36
	fld _6
	fstp _AUX_valorFib
	JMP ET_43
ET_36:
	fld _0
	fstp _AUX_valorAnterior1
	fld _1
	fstp _AUX_valorAnterior2
	fld _2
	fstp _AUX_posicion
ET_52:
	fld _AUX_posicion
	fld _6
	fxch
	fcomp
	fstsw ax
	ffree st(0)
	sahf
	JA ET_56
	fld _AUX_valorAnterior1
	fld _AUX_valorAnterior2
	fadd
	fstp _AUX_valorFib
	fld _AUX_valorAnterior2
	fstp _AUX_valorAnterior1
	fld _AUX_valorFib
	fstp _AUX_valorAnterior2
	fld _AUX_posicion
	fld _1
	fadd
	fstp _AUX_posicion
	JMP ET_52
ET_56:
ET_43:
	fld _AUX_valorFib
	fstp _n2
	displayFloat _n2,2
	newLine 1
	fld _n2
	fld _7
	fxch
	fcomp
	fstsw ax
	ffree st(0)
	sahf
	JBE ET_87
	mov dx,OFFSET T_Es_mayor_a_7
	mov ah,9
	int 21h
	newLine 1
	JMP ET_93
ET_87:
	mov dx,OFFSET T_No_es_mayor_a_7
	mov ah,9
	int 21h
	newLine 1
ET_93:
	fld _3
	fstp _n1
ET_99:
	fld _n1
	fld _10
	fxch
	fcomp
	fstsw ax
	ffree st(0)
	sahf
	JAE ET_103
	fld _n1
	fld _1
	fadd
	fstp _n1
	JMP ET_99
ET_103:
	displayFloat _n1,2
	newLine 1
	GetFloat _n1
	fld _n1
	fld _5
	fxch
	fcomp
	fstsw ax
	ffree st(0)
	sahf
	JBE ET_121
	mov dx,OFFSET T_Es_mayor_a_5
	mov ah,9
	int 21h
	newLine 1
	JMP ET_127
ET_121:
	mov dx,OFFSET T_No_es_mayor_a_5
	mov ah,9
	int 21h
	newLine 1
ET_127:
	mov dx,OFFSET _NEWLINE
	mov ah,09
	int 21h
	mov dx,OFFSET _msgPRESIONE
	mov ah,09
	int 21h
	mov ah, 1
	int 21h
	mov ax, 4C00h
	int 21h
END START
