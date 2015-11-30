include macros2.asm
include number.asm

.MODEL	LARGE
.386
.STACK 200h

MAXTEXTSIZE equ 50

.DATA

	_nAux			dd	?
	_n1			dd	?
	_n2			dd	?
	_n3			dd	?
	_t1			db	MAXTEXTSIZE dup (?),'$'
	_t2			db	MAXTEXTSIZE dup (?),'$'
	_t3			db	MAXTEXTSIZE dup (?),'$'
	T_Bienvenido_al_sistema_de_pruebas			db	"Bienvenido al sistema de pruebas$",'$', 17 dup (?)
	T_Ingrese_un_numero_por_favor			db	"Ingrese un numero por favor$",'$', 22 dup (?)
	T_Que_interesante			db	"Que interesante$",'$', 34 dup (?)
	_AUX_valorFib			dd	?
	_AUX_valorAnterior1			dd	?
	_AUX_valorAnterior2			dd	?
	_AUX_posicion			dd	?
	_0			dd	0.0
	_1			dd	1.0
	_2			dd	2.0
	T_La_secuencia_de_fibonacci_de_este_numero_es			db	"La secuencia de fibonacci de este numero es$",'$', 6 dup (?)
	T_Ingrese_otro_numero_por_favor			db	"Ingrese otro numero por favor$",'$', 20 dup (?)
	T_El_primer_numero_ingresado_es_mayor_al_segundo			db	"El primer numero ingresado es mayor al segundo$",'$', 3 dup (?)
	T_La_diferencia_entre_ambos_es			db	"La diferencia entre ambos es$",'$', 21 dup (?)
	T_El_primer_numero_ingresado_es_menor_al_segundo			db	"El primer numero ingresado es menor al segundo$",'$', 3 dup (?)
	T_Los_numeros_son_iguales			db	"Los numeros son iguales$",'$', 26 dup (?)
	T_De_hecho_ambos_numeros_son_mayores_a_1			db	"De hecho ambos numeros son mayores a 1$",'$', 11 dup (?)
	T_De_hecho_uno_de_ellos_no_es_mayor_a_1			db	"De hecho uno de ellos no es mayor a 1$",'$', 12 dup (?)
	_3			dd	3.0
	T_Y_tambien_se_que_alguno_de_los_dos_es_tres			db	"Y tambien se que alguno de los dos es tres$",'$', 7 dup (?)
	T_Y_tambien_se_que_ninguno_de_los_dos_es_tres			db	"Y tambien se que ninguno de los dos es tres$",'$', 6 dup (?)
	T_Solo_una_cosa_mas			db	"Solo una cosa mas$",'$', 32 dup (?)
	T_Ingrese_un_texto			db	"Ingrese un texto$",'$', 33 dup (?)
	T_El_texto_es_			db	"El texto es $",'$', 37 dup (?)
	T_Ahora_algunas_operaciones			db	"Ahora algunas operaciones$",'$', 24 dup (?)
	T_El_primer_numero_mas_5_es			db	"El primer numero mas 5 es$",'$', 24 dup (?)
	_5			dd	5.0
	T_El_segundo_numero_por_3_es			db	"El segundo numero por 3 es$",'$', 23 dup (?)
	T_Y_si_los_sumamos_y_los_dividimos_por_2			db	"Y si los sumamos y los dividimos por 2$",'$', 11 dup (?)
	T_Gracias_por_			db	"Gracias por $",'$', 37 dup (?)
	T_realizar_la_prueba			db	"realizar la prueba$",'$', 31 dup (?)
	T_Terminando_en			db	"Terminando en$",'$', 36 dup (?)
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
	mov dx,OFFSET T_Bienvenido_al_sistema_de_pruebas
	mov ah,9
	int 21h
	newLine 1
	mov dx,OFFSET T_Ingrese_un_numero_por_favor
	mov ah,9
	int 21h
	newLine 1
	GetFloat _n1
	mov dx,OFFSET T_Que_interesante
	mov ah,9
	int 21h
	newLine 1
	fld _n1
	fld _2
	fxch
	fcomp
	fstsw ax
	ffree st(0)
	sahf
	JAE ET_12
	fld _n1
	fstp _AUX_valorFib
	JMP ET_19
ET_12:
	fld _0
	fstp _AUX_valorAnterior1
	fld _1
	fstp _AUX_valorAnterior2
	fld _2
	fstp _AUX_posicion
ET_28:
	fld _AUX_posicion
	fld _n1
	fxch
	fcomp
	fstsw ax
	ffree st(0)
	sahf
	JA ET_32
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
	JMP ET_28
ET_32:
ET_19:
	fld _AUX_valorFib
	fstp _n3
	mov dx,OFFSET T_La_secuencia_de_fibonacci_de_este_numero_es
	mov ah,9
	int 21h
	newLine 1
	displayFloat _n3,2
	newLine 1
	mov dx,OFFSET T_Ingrese_otro_numero_por_favor
	mov ah,9
	int 21h
	newLine 1
	GetFloat _n2
	fld _n1
	fld _n2
	fxch
	fcomp
	fstsw ax
	ffree st(0)
	sahf
	JBE ET_69
	mov dx,OFFSET T_El_primer_numero_ingresado_es_mayor_al_segundo
	mov ah,9
	int 21h
	newLine 1
	fld _0
	fstp _n3
	fld _n2
	fstp _nAux
ET_78:
	fld _nAux
	fld _n1
	fxch
	fcomp
	fstsw ax
	ffree st(0)
	sahf
	JAE ET_82
	fld _nAux
	fld _1
	fadd
	fstp _nAux
	fld _n3
	fld _1
	fadd
	fstp _n3
	JMP ET_78
ET_82:
	mov dx,OFFSET T_La_diferencia_entre_ambos_es
	mov ah,9
	int 21h
	newLine 1
	displayFloat _n3,2
	newLine 1
	JMP ET_104
ET_69:
	fld _n1
	fld _n2
	fxch
	fcomp
	fstsw ax
	ffree st(0)
	sahf
	JAE ET_108
	mov dx,OFFSET T_El_primer_numero_ingresado_es_menor_al_segundo
	mov ah,9
	int 21h
	newLine 1
	fld _0
	fstp _n3
	fld _n1
	fstp _nAux
ET_117:
	fld _nAux
	fld _n2
	fxch
	fcomp
	fstsw ax
	ffree st(0)
	sahf
	JAE ET_121
	fld _nAux
	fld _1
	fadd
	fstp _nAux
	fld _n3
	fld _1
	fadd
	fstp _n3
	JMP ET_117
ET_121:
	mov dx,OFFSET T_La_diferencia_entre_ambos_es
	mov ah,9
	int 21h
	newLine 1
	displayFloat _n3,2
	newLine 1
	JMP ET_143
ET_108:
	mov dx,OFFSET T_Los_numeros_son_iguales
	mov ah,9
	int 21h
	newLine 1
ET_143:
ET_104:
	fld _n1
	fld _1
	fxch
	fcomp
	fstsw ax
	ffree st(0)
	sahf
	JBE ET_150
	fld _n2
	fld _1
	fxch
	fcomp
	fstsw ax
	ffree st(0)
	sahf
	JBE ET_150
	mov dx,OFFSET T_De_hecho_ambos_numeros_son_mayores_a_1
	mov ah,9
	int 21h
	newLine 1
	JMP ET_162
ET_150:
	mov dx,OFFSET T_De_hecho_uno_de_ellos_no_es_mayor_a_1
	mov ah,9
	int 21h
	newLine 1
ET_162:
	fld _n1
	fld _3
	fxch
	fcomp
	fstsw ax
	ffree st(0)
	sahf
	JE ET_168
	fld _n2
	fld _3
	fxch
	fcomp
	fstsw ax
	ffree st(0)
	sahf
	JE ET_168
	JMP ET_176
ET_168:
	mov dx,OFFSET T_Y_tambien_se_que_alguno_de_los_dos_es_tres
	mov ah,9
	int 21h
	newLine 1
	JMP ET_183
ET_176:
	mov dx,OFFSET T_Y_tambien_se_que_ninguno_de_los_dos_es_tres
	mov ah,9
	int 21h
	newLine 1
ET_183:
	mov dx,OFFSET T_Solo_una_cosa_mas
	mov ah,9
	int 21h
	newLine 1
	mov dx,OFFSET T_Ingrese_un_texto
	mov ah,9
	int 21h
	newLine 1
	getString _t1
	mov si,OFFSET T_El_texto_es_
	mov di,OFFSET _t2
	call COPIAR
	mov si,OFFSET _t2
	mov di,OFFSET _aux
	call COPIAR
	mov si,OFFSET _t1
	mov di,OFFSET _aux
	call CONCAT
	mov si,OFFSET _aux
	mov di,OFFSET _t3
	call COPIAR
	mov dx,OFFSET _t3
	mov ah,9
	int 21h
	newLine 1
	mov dx,OFFSET T_Ahora_algunas_operaciones
	mov ah,9
	int 21h
	newLine 1
	mov dx,OFFSET T_El_primer_numero_mas_5_es
	mov ah,9
	int 21h
	newLine 1
	fld _n1
	fld _5
	fadd
	fstp _n1
	displayFloat _n1,2
	newLine 1
	mov dx,OFFSET T_El_segundo_numero_por_3_es
	mov ah,9
	int 21h
	newLine 1
	fld _n2
	fld _3
	fmul
	fstp _n2
	displayFloat _n2,2
	newLine 1
	mov dx,OFFSET T_Y_si_los_sumamos_y_los_dividimos_por_2
	mov ah,9
	int 21h
	newLine 1
	fld _n1
	fld _n2
	fadd
	fld _2
	fdiv
	fstp _n3
	displayFloat _n3,2
	newLine 1
	fld _1
	fstp _n1
	fld _2
	fstp _n2
	fld _3
	fstp _n3
	mov si,OFFSET T_Gracias_por_
	mov di,OFFSET _t1
	call COPIAR
	mov si,OFFSET T_realizar_la_prueba
	mov di,OFFSET _t2
	call COPIAR
	mov dx,OFFSET T_Terminando_en
	mov ah,9
	int 21h
	newLine 1
	displayFloat _n3,2
	newLine 1
	displayFloat _n2,2
	newLine 1
	displayFloat _n1,2
	newLine 1
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
