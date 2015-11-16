%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "y.tab.h"
#define TAMANIO_COLA 10000
#define TAMANIO_ELEM 101

int yystopparser = 0;
FILE  *yyin;
FILE *fpo;
FILE *tabla;
extern char *yytext;
char polacaInversa[TAMANIO_COLA][TAMANIO_ELEM];
char ultimaComp[2];
char indexInicioComp[100];
int indexSaltoMientras;
int indice;
int pila[100];
int indexPila;
char pilaIdAsigMul[100][TAMANIO_ELEM];
char pilaConstAsigMul[100][TAMANIO_ELEM];
int indexPilaIdAsigMul = 0;
int indexPilaConstAsigMul = 0;
int opY = 0;
int opO = 0;

%}

%error-verbose
%token ID
%token ENTERO
%token REAL
%token CADENA
%token INI_PROG
%token FIN_PROG
%token MIENTRAS
%token OP_Y
%token OP_O
%token NO
%token SI
%token SINO
%token ESCRIBIR
%token LEER
%token DEFINE
%token FDEFINE
%token T_ENTERO
%token T_REAL
%token T_CADENA
%token FIB
%token TAKE
%token PUNTO_COMA
%token COMA
%token DOS_PUNTOS
%token ASIGNACION
%token OP_SUMA
%token OP_CONCAT
%token OP_MENOS
%token OP_MULTIP
%token OP_DIV
%token OP_A_PARENT
%token OP_C_PARENT
%token OP_A_CORCH
%token OP_C_CORCH
%token A_LLAVES
%token C_LLAVES
%token OP_MENOR
%token OP_MAYOR
%token OP_MENOR_I
%token OP_MAYOR_I
%token OP_IGUAL
%token OP_DISTINTO

%%
pgm:
programa
;

programa:
INI_PROG A_LLAVES declaracion sentencias C_LLAVES FIN_PROG
| INI_PROG A_LLAVES sentencias_prints C_LLAVES FIN_PROG
;

declaracion:
DEFINE lineas_declaracion FDEFINE 
;

lineas_declaracion:
linea_declaracion
| lineas_declaracion linea_declaracion
;

linea_declaracion:
OP_A_CORCH  tipo dec_variables ID OP_C_CORCH PUNTO_COMA 
;

dec_variables:
COMA tipo dec_variables ID  COMA 
| OP_C_CORCH  DOS_PUNTOS  OP_A_CORCH 
;

tipo:
T_ENTERO
| T_REAL 
| T_CADENA
;

sentencias:
sentencia
| sentencias sentencia
;

sentencia:
asignacion PUNTO_COMA
| bucle
| decision
| entrada PUNTO_COMA 
| salida PUNTO_COMA 
| asignacion_multiple PUNTO_COMA 
;

asignacion:
ID {poID();} ASIGNACION  expresion {pf("=");}
;

expresion:
expresion OP_SUMA termino {pf("+");}
| expresion OP_CONCAT  termino {pf("++");}
| expresion OP_MENOS termino  {pf("-");}
| termino
;

termino:
termino OP_MULTIP factor  {pf("*");} 
| termino OP_DIV factor   {pf("/");} 
| factor
;

factor:
ID {poID();}
| ENTERO {po();}
| REAL {po();}
| CADENA {po();}
| fib
| take
| OP_A_PARENT expresion OP_C_PARENT 
;

fib:
FIB OP_A_PARENT expresion_fib OP_C_PARENT
;

expresion_fib:
ID {insertarFIB(yytext);}
| ENTERO {insertarFIB(yytext);}

take:
TAKE OP_A_PARENT {po();} elementos_take OP_C_PARENT {po();}
;

elementos_take:
operador PUNTO_COMA {po();} ENTERO {po();} PUNTO_COMA {po();} lista_enteros
;

bucle:
MIENTRAS OP_A_PARENT  {reservar(1);} condicion {reservar(2);} OP_C_PARENT  A_LLAVES  sentencias C_LLAVES  {reservar(3);} 
;

condicion:
comparacion {reservarYO(1);} OP_Y comparacion {reservarYO(2);/*operador("y");*/}
| comparacion {reservarYO(3);} OP_O comparacion {reservarYO(4);/*operador("o");*/}
| NO {po();} comparacion
| comparacion
| expresion
;

comparacion:
expresion OP_MENOR expresion   {ultimaComparacion("< ");}
| expresion OP_MAYOR  expresion   {ultimaComparacion("> ");}
| expresion OP_MENOR_I  expresion    {ultimaComparacion("<=");}
| expresion OP_MAYOR_I expresion    {ultimaComparacion(">=");}
| expresion OP_IGUAL expresion     {ultimaComparacion("==");}
| expresion OP_DISTINTO expresion     {ultimaComparacion("!=");}
;

decision:
SI OP_A_PARENT condicion {reservarIf(1);} OP_C_PARENT A_LLAVES sentencias  C_LLAVES sino
;

sino:
{reservarIf(4);}
| {reservarIf(2);} SINO A_LLAVES sentencias {reservarIf(3);} C_LLAVES  {/*reservarIf(4);*/}
;
entrada:
LEER {po();} ID {poID();}
;

salida:
ESCRIBIR {po();} ID {poID();}
| ESCRIBIR {po();} CADENA {po();}
;

sentencias_prints:
sentencia_print
| sentencias_prints sentencia_print

sentencia_print:
entrada PUNTO_COMA {po();}
| salida PUNTO_COMA {po();}

asignacion_multiple:
OP_A_CORCH  ID {apilarAsigMul(0);} asig_mul constante OP_C_CORCH {apilarAsigMul(2);}
;

asig_mul:
COMA ID {apilarAsigMul(0);} asig_mul constante COMA 
| OP_C_CORCH  ASIGNACION OP_A_CORCH 
;

constante:
ENTERO {apilarAsigMul(1);}
| REAL {apilarAsigMul(1);}
| CADENA {apilarAsigMul(1);}
;

operador:
OP_SUMA {po();}
| OP_MENOS {po();}
| OP_MULTIP {po();}
| OP_DIV {po();}
;

lista_enteros:
lis_ent ENTERO {po();} OP_C_CORCH {po();}
;

lis_ent:
lis_ent ENTERO {po();} PUNTO_COMA {po();}
| OP_A_CORCH {po();}
;
%%
int poArray(char* s);
int tope();
int desapilar();
char* concatenarStrings(char* a,char* b);
void mostrarArray();
char* averiguarOperador(char* op);
char* averiguarOperadorVerdadero(char* op);
void iniciarPila();
void apilar(int n);
void subStr(char* string, char divisor);
void operador(char* op);

int main(int argc,char *argv[]) {
	if ((yyin = fopen(argv[1], "rt")) == NULL) {
		printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
	} else {
		fpo = fopen("intermedia.txt", "w+");
		if (fpo==NULL) {
			printf("\nNo se puede abrir el archivo de preorden\n");
		} else {
			iniciarPila();
			iniTabla();
			yyparse();
		}
	}
	mostrarArray();
	fclose(yyin);
	fclose(fpo);
	cerrTabla();
	return 0;
}

int yyerror(const char *s) {                                                     
	printf("parser error %s \n ",s);
	return 0;
	
}

int p() {
	printf("%s\n",yytext);
}

/**
 * Se mantiene por compatibilidad
 */
 int pf(char* s) {
 	poArray(s);
 }

/**
 * Se mantiene por compatibilidad
 */
 int po() {
 	poArray(yytext);
 }

/**
 * Almacena un ID en la Polaca Inversa.
 * Le agrega el guion bajo adelante
 */
 int poID() {
 	if (buscEnTabla(yytext) == 0) {
		char *guion = "_";
 		poArray(concatenarStrings(guion,yytext));
 	} else {
 		printf("ERROR FATAL: La variable %s no fue declarada previamente",yytext);
 		exit(1);
 	}
 	
 }

/**
 * Guarda los elementos en forma posorder en el array
 * de Polaca Inversa
 */
 int poArray(char* s) {
 	if (s != NULL) {
 		char aux[TAMANIO_ELEM];										
 		strncpy(aux,s,strlen(s));									
 		strcpy(polacaInversa[indice], aux);							
 		if (strlen(s) < TAMANIO_ELEM) {
 			polacaInversa[indice][strlen(s)] = '\0';
 		} else {
 			polacaInversa[indice][TAMANIO_ELEM - 1] = '\0';
 		}
 	}
 	indice++;
 }

/**
 * Guarda la ultima comparacion que se realizo en el codigo 
 */
 int ultimaComparacion(char* s) {
	
 	strncpy(ultimaComp,s,strlen(s));
 }

void concatenarDelante(char* texto, const char* textoPrevio) {
    size_t longitud = strlen(textoPrevio);
    size_t i;
    memmove(texto + longitud, texto, strlen(texto) + 1);
    for (i = 0; i < longitud; ++i) {
        texto[i] = textoPrevio[i];
    }
}


/**
 * Segun en el sector del WHILE que se encuentre,
 * actua para reservar los espacios necesarios y lo reemplaza con el
 * codigo intermedio de assembler necesario.
 */
 int reservar(int a) {
	 char s[100];
	 int etiq_final;
 	if (a == 1) {
		//Esto actua en el inicio de la comparacion, reserva el espacion antes del bloque izquierdo
		 //coloco la etiqueta a la cual se va saltar, de esta forma "etiqueta_indice:"
		 itoa(indice,s,10);
 		  concatenarDelante(s,"ET_");
		  strcat(s,":");
		  pf(s);
		 apilar(indice-1);
 	} else if (a == 2) {
		if(opY == 0 & opO == 0){ 
			//Esto reserva el espacio, y genera el assembler necesario antes del cuerpo del while
			etiq_final = indice+1;
			apilar(etiq_final);
			pf("CMP");
			 itoa(etiq_final,s,10);
			 concatenarDelante(s,"ET_");
			 pf(s);
			//Ponemos la operacion assembler del operador correspondiente.
			pf(averiguarOperador(ultimaComp));
		}else if (opY == 1){
			opY = 0;
		}else if (opO == 1){
			opO = 0;
		}
		
 	} else if (a == 3) {
		//Esto reserva el espacio, y genera el assembler necesario despues del cuerpo del while
		etiq_final=desapilar();
 		itoa(desapilar(),s,10);
 		concatenarDelante(s,"ET_");
 		pf(s);
 		pf("BI");
		//Se agrega la etiqueta del final del while.
		itoa(etiq_final,s,10);
		concatenarDelante(s,"ET_");
		strcat(s,":");
		pf(s);
 	}
 }
 
 int reservarYO(int a) {
	 char s[100];
	 int etiq_final;
 	if (a == 1) {
		//Esto reserva el espacio, y genera el assembler necesario para las comparaciones del operador Y
		etiq_final = indice+1;
 		apilar(etiq_final);
 		pf("CMP");
	     itoa(etiq_final,s,10);
 		 concatenarDelante(s,"ET_");
		 pf(s);
		//Ponemos la operacion assembler del operador correspondiente.
 		pf(averiguarOperador(ultimaComp));
 	} else if (a == 2) {
		pf("CMP");
	     itoa(tope(),s,10);
 		 concatenarDelante(s,"ET_");
		 pf(s);
		//Ponemos la operacion assembler del operador correspondiente.
 		pf(averiguarOperador(ultimaComp));
 		operador("y");
 	} else if (a == 3) {
		etiq_final = indice+1;
 		apilar(etiq_final);
 		pf("CMP");
	     itoa(etiq_final,s,10);
 		 concatenarDelante(s,"ET_");
		 pf(s);
		//Ponemos la operacion assembler del operador correspondiente.
 		pf(averiguarOperadorVerdadero(ultimaComp));
 	}else if (a == 4) {
		int tope = desapilar();
		pf("CMP");
	     itoa(tope,s,10);
 		 concatenarDelante(s,"ET_");
		 pf(s);
		//Ponemos la operacion assembler del operador correspondiente.
 		pf(averiguarOperadorVerdadero(ultimaComp));
 		etiq_final = indice+1;
 		apilar(etiq_final);
 		itoa(etiq_final,s,10);
 		concatenarDelante(s,"ET_");
		pf(s);
		pf("BI");
		itoa(tope,s,10);
 		concatenarDelante(s,"ET_");
		strcat(s,":");
		pf(s);
 		operador("o");
 	}
 }

/**
 * Segun en el sector del IF en que se encuentra
 * actua para reservar los espacios necesarios y lo reemplaza con el
 * codigo intermedio de assembler necesario.
 */
 int reservarIf(int a) {
 	char s[100];
	int etiq_final;
 	if (a == 1) {
		if(opY == 0 & opO == 0){ 
			//DESPUES DE LA CONDICION
			//Esto actua en el inicio de la comparacion, reserva el espacion antes del bloque izquierdo
			etiq_final=indice+2;
			apilar(etiq_final);
			pf("CMP");
			//indexSaltoMientras = indice;
			itoa(etiq_final,s,10);
			concatenarDelante(s,"ET_");
			pf(s);
			//Ponemos la operacion assembler del operador correspondiente.
			pf(averiguarOperador(ultimaComp));
		}else if(opY == 1){
			opY = 0;
		}else if(opO == 1){
			opO = 0;
		}
 	} else if (a == 2) {
		//TERMINACION DEL SINO
		etiq_final = desapilar();
        apilar(indice+3);
        itoa(indice+3,s,10);
 		concatenarDelante(s,"ET_");
		pf(s);
		pf("BI");
		itoa(etiq_final,s,10);
 		concatenarDelante(s,"ET_");
		strcat(s,":");
		pf(s);
 	} else if (a == 3) {
		//FIN DEL SINO
		//Esto reserva el espacio, y genera el assembler necesario despues del cuerpo del while
 		itoa(desapilar(),s,10);
 		concatenarDelante(s,"ET_");
		strcat(s,":");
		pf(s);
 	} else if(a==4){
		//IF SIMPLE ** TERMINACION
		etiq_final = desapilar();
		itoa(etiq_final,s,10);
 		concatenarDelante(s,"ET_");
		strcat(s,":");
		pf(s);
	}
 }

/**
 * Muestra el array en la consola y guarda el resultado en 
 * un archivo de texto
 */
 void mostrarArray() {
 	unsigned x = 0;
 	strcpy(polacaInversa[indice], "\0");
 	printf("------------------------------------------------------- \n");
 	printf("Cantidad de elementos registrados %d \n",indice);
 	for (x;x < indice;x++) {
 		printf("%s \n",polacaInversa[x]);
 		fprintf(fpo,"(%d) %s\n",x,polacaInversa[x]);
 	}
 }

/**
 * Concatena A con B
 */
 char* concatenarStrings(char* a,char* b) {
   // Determino el nuevo tamaño
 	int newSize = strlen(b)  + strlen(a) + 1; 
   // Malloc del nuevo tamaño en una nueva variable
 	char * newBuffer = (char *)malloc(newSize);
   // Copiamos y concatenamos
 	strcpy(newBuffer,a);
 	strcat(newBuffer,b);
 	return newBuffer;
 }

void operador(char* op){
	if (strcmp(op,"y") == 0) {
 		opY = 1;
 	} else if (strcmp(op,"o") == 0) {
 		opO = 1;
 	} else{
	}
}
/**
 * Averigua cual es el operador enviado como parametro
 * y devuelve el codigo asembler de la comparacion por falso
 * correspondiente.
 */
 char* averiguarOperador(char* op) {
 	if (strcmp(op,">=") == 0) {
 		return "BLT";
 	} else if (strcmp(op,"> ") == 0) {
 		return "BLE";
 	} else if (strcmp(op,"<=") == 0) {
 		return "BGT";
 	} else if (strcmp(op,"< ") == 0) {
 		return "BGE";
 	} else if (strcmp(op,"!=") == 0) {
 		return "BEQ";
 	} else if (strcmp(op,"==") == 0) {
 		return "BNE";
 	} else {
 		return "ERROR-BUSQUEDA-OP";
 	}; 
 }
 
 /**
 * Averigua cual es el operador enviado como parametro
 * y devuelve el codigo asembler de la comparacion por verdadero
 * correspondiente.
 */
 char* averiguarOperadorVerdadero(char* op) {
 	if (strcmp(op,">=") == 0) {
 		return "BGE";
 	} else if (strcmp(op,"> ") == 0) {
 		return "BGT";
 	} else if (strcmp(op,"<=") == 0) {
 		return "BLE";
 	} else if (strcmp(op,"< ") == 0) {
 		return "BLT";
 	} else if (strcmp(op,"!=") == 0) {
 		return "BNE";
 	} else if (strcmp(op,"==") == 0) {
 		return "BEQ";
 	} else {
 		return "ERROR-BUSQUEDA-OP";
 	}; 
 }

int insertarFIB(char* n) {
	int salto1, salto2, salto3, salto4;
	char cSalto1[20], cSalto2[20], cSalto3[20], cSalto4[20], defSalto1[20], defSalto2[20], defSalto3[20], defSalto4[20];
	salto1 = indice + 4;
	itoa(salto1,cSalto1,10);
	concatenarDelante(cSalto1,"ET_");
	salto2 = indice + 11;
	itoa(salto2,cSalto2,10);
	concatenarDelante(cSalto2,"ET_");
	salto3 = indice + 20;
	itoa(salto3,cSalto3,10);
	concatenarDelante(cSalto3,"ET_");
	salto4 = indice + 24;
	itoa(salto4,cSalto4,10);
	concatenarDelante(cSalto4,"ET_");
	strcpy(defSalto1,cSalto1);
	strcpy(defSalto2,cSalto2);
	strcpy(defSalto3,cSalto3);
	strcpy(defSalto4,cSalto4);
	strcat(defSalto1,":");
	strcat(defSalto2,":");
	strcat(defSalto3,":");
	strcat(defSalto4,":");
	char *valorFib = "AUX_valorFib";
	char *valorAnt1 = "AUX_valorAnterior1";
	char *valorAnt2 = "AUX_valorAnterior2";
	char *pos = "AUX_posicion";
	cargarIDAuxEnTabla(valorFib,"entero");
	cargarIDAuxEnTabla(valorAnt1,"entero");
	cargarIDAuxEnTabla(valorAnt2,"entero");
	cargarIDAuxEnTabla(pos,"entero");
	char *fibIntermedio[] = {n, "2", "CMP", cSalto1, "BGE", valorFib, n, "=", cSalto2,"BI", defSalto1, valorAnt1, "0", "=", valorAnt2, "1", "=", pos, "2", "=", defSalto3, pos, n, "CMP",cSalto4,"BGT", valorFib, valorAnt1, valorAnt2,"+", "=", valorAnt1, valorAnt2, "=", valorAnt2, valorFib, "=", pos, pos, "1", "+", "=", cSalto3, "BI", defSalto4, defSalto2, valorFib};
	size_t i = 0;
	for (i = 0; i < sizeof(fibIntermedio) / sizeof(fibIntermedio[0]); i++) {
    	poArray(fibIntermedio[i]);
    }
}

int apilarEnPilaAsigMul(char pila[100][TAMANIO_ELEM], int indicePila) {
	char aux[TAMANIO_ELEM];										
 	strncpy(aux,yytext,strlen(yytext));									
 	strcpy(pila[indicePila], aux);	
 	if (strlen(yytext) < TAMANIO_ELEM) {
 		pila[indicePila][strlen(yytext)] = '\0';
 	} else {
 		pila[indicePila][TAMANIO_ELEM - 1] = '\0';
 	}
}

int apilarAsigMul(int caso) {
	if (caso == 0) {
		apilarEnPilaAsigMul(pilaIdAsigMul,indexPilaIdAsigMul);
		indexPilaIdAsigMul += 1;
	} else if (caso == 1) {
		apilarEnPilaAsigMul(pilaConstAsigMul,indexPilaConstAsigMul);
		indexPilaConstAsigMul +=1;
	} else {
		int i;
		for (i=0;i<indexPilaIdAsigMul;i++) {
			poArray(pilaIdAsigMul[i]);
			poArray(pilaConstAsigMul[i]);
			poArray("=");
		}
		indexPilaIdAsigMul = 0;
		indexPilaConstAsigMul = 0;
	}
}

/*********************************************
 * 
 *    METODOS DE PILA
 * 
 *********************************************
 */
 
 void iniciarPila() {
 	indexPila = -1;
 }
 void apilar(int n) {
 	pila[++indexPila] = n;
 }

 int desapilar() {
 	if (indexPila >= 0)
 		return pila[indexPila--];
 	return -1;
 }

 int tope() {
 	if(indexPila >= 0)
 		return pila[indexPila];
 	return-1;
 }

 /*********************************************
 * 
 *    METODOS DE TABLA
 * 
 *********************************************
 */

 int iniTabla() {
	tabla = fopen("tabla.txt", "w+");
    if (tabla == NULL) {
      printf("\nNo se puede abrir el archivo de la tabla de simbolos\n");
      exit(1);
    }
}

int cargarIDAuxEnTabla(char* nombreID, char* tipo) {
	if (buscEnTabla(nombreID) == 1) {
		fprintf(tabla,"%s;%s;%s;\n",nombreID,"ID",tipo);
	}
}

int buscEnTabla(char* nombreID) {
	size_t tam_buffer = 256;
	char *buffer = malloc(tam_buffer * sizeof(char));
	char* temporal = malloc(tam_buffer * sizeof(char));
	fseek(tabla,0,SEEK_SET);
    if (NULL != fgets(buffer, tam_buffer, tabla)) {
    	strcpy(temporal,buffer);
    	subStr(temporal,';');
    	while ((NULL != fgets(buffer, tam_buffer, tabla)) && strcmp(temporal,nombreID) != 0) {
    		strcpy(temporal,buffer);
    		subStr(temporal,';');
    	}
    	fseek(tabla,0,SEEK_END);
    	if (strcmp(temporal,nombreID) == 0) {
    		return 0;
    	} else {
    		return 1;
    	}
    }
    return 1;
}

void subStr(char* string, char divisor) {
	char* sub = string;
    if (!sub) {
    	return;
	}
    while (*sub != '\0' && *sub != divisor) {
    	sub++;
	}
    *sub = '\0';
}

int cerrTabla() {
	fclose(tabla);
}
