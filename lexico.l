%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "y.tab.h"
#define TAMANIO_COLA 255

FILE  *yyin;
FILE *tabla;
int yylval;
float yylreal;
char* yytext;
char cola[TAMANIO_COLA];
char aux[15];
%}
%option noyywrap  
%option yylineno
%x comment 

DIGITO        [0-9]
LETRA        [a-zA-Z]
PUNTO        [.]
ESPACIO      [ ]
COMILLAS     ["]
ID        {LETRA}({LETRA}|{DIGITO}|_)*
REAL        {DIGITO}+{PUNTO}{DIGITO}+|{PUNTO}{DIGITO}+|{DIGITO}+{PUNTO}
CADENA        {COMILLAS}({LETRA}|{DIGITO}|{ESPACIO})*{COMILLAS}

%%
"inicioprog"        { iniciarTabla(); return INI_PROG;}
"finprog"        { cerrarTabla(); return FIN_PROG;}
"mientras"        { return MIENTRAS;}
"y"        { return OP_Y;}
"o"        { return OP_O;}
"no"        { return NO;}
"si"        { return SI;}
"sino"        { return SINO;}
"escribir"      { return ESCRIBIR;}
"leer"        { return LEER;}
"define"        { return DEFINE;}
"fdefine"        { return FDEFINE;}
"fib"      { return FIB;}
"entero"    { encola("entero"); return T_ENTERO;  }
"real"    { encola("real"); return T_REAL;  }
"cadena"    {  encola("cadena"); return T_CADENA;}
{CADENA}        { cargarTabla(1,"CADENA"); return CADENA;}
{REAL}        { cargarTabla(1,"REAL"); yylreal = atof(yytext); yylreal; return REAL;}
{DIGITO}+        { cargarTabla(1,"ENTERO"); yylval = atoi(yytext); yylval; return ENTERO;}
{ID} {cargarTabla(0,"ID"); return ID;}
"-/"        {BEGIN(comment);printf("Lo que sigue es COMENTARIO\n\r");ECHO;}
    <comment>[^/\n]* ECHO;
    <comment>"/"+[^/\-\n]* ECHO;
    <comment>"/"+"-"        {ECHO;BEGIN(INITIAL);printf("\nEncontre FIN COMENTARIO\n\r");}

";"        { return PUNTO_COMA;}
","        { return COMA;}
":"        { return DOS_PUNTOS;}
"="        { return ASIGNACION;}
"+"        { return OP_SUMA;}
"++"        { return OP_CONCAT;}
"-"        { return OP_MENOS;}
"*"        { return OP_MULTIP;}
"/"        { return OP_DIV;}
"("        { return OP_A_PARENT;}
")"        { return OP_C_PARENT;}
"["        { return OP_A_CORCH;}
"]"        { return OP_C_CORCH;}
("{"|"<%")        { return A_LLAVES;}
("}"|"%>")        { return C_LLAVES;}
"<"        { return OP_MENOR;}
">"        { return OP_MAYOR;}
"<="        { return OP_MENOR_I;}
">="        { return OP_MAYOR_I;}
"=="        { return OP_IGUAL;}
"!="        { return OP_DISTINTO;}
" "
"\n"              
"\t"
. { errorCaracter();}        
%%
void subString(char* string, char divisor);
int encola(char* tipo);
char* desencola();

int iniciarTabla()
{
	tabla = fopen("tabla.txt", "w+");
    if (tabla==NULL)
    {
      printf("\nNo se puede abrir el archivo de la tabla de simbolos\n");
      exit(1);
    }
}

int cargarTabla(int esID, char* tipo)
{
	if (buscarEnTabla() == 1)
		{
		fprintf(tabla,"%s;%s;",yytext,tipo);
		if (esID != 0)
		{
			fprintf(tabla,"%s;\n",yytext);
		}
		else
		{
			char* valor = desencola();
			fprintf(tabla,"%s;\n",valor);
		}
	}
}

int buscarEnTabla()
{
	size_t tam_buffer = 256;
	char *buffer = malloc(tam_buffer * sizeof(char));
	char* temporal = malloc(tam_buffer * sizeof(char));
	fseek(tabla,0,SEEK_SET);
    if (NULL != fgets(buffer, tam_buffer, tabla))
    {
    	//printf("BUFFER: %s\n",buffer);
    	strcpy(temporal,buffer);
    	subString(temporal,';');
    	//printf("TEMPORAL: %s, YYTEXT: %s\n",temporal,yytext);
    	while ((NULL != fgets(buffer, tam_buffer, tabla)) && strcmp(temporal,yytext) != 0)
    	{
    		//printf("BUFFER: %s\n",buffer);
    		strcpy(temporal,buffer);
    		subString(temporal,';');
    		//printf("TEMPORAL: %s, YYTEXT: %s\n",temporal,yytext);
    	}
    	fseek(tabla,0,SEEK_END);
    	if (strcmp(temporal,yytext) == 0) {
    		return 0;
    	}
    	else {
    		return 1;
    	}
    }
    return 1;
}

void subString(char* string, char divisor)
{
	char* sub = string;
    if (!sub)
    {
    	return;
	}
    while (*sub != '\0' && *sub != divisor)
    {
    	sub++;
	}
    *sub = '\0';
}

int encola(char* tipo) {
	char aux[strlen(tipo)];
	strcpy(aux,tipo);
	
	
	char aux2[TAMANIO_COLA];
	strncpy(aux2,cola,TAMANIO_COLA);
	int index=0;
	
	unsigned x=strlen(aux2);

	for(x;x<(strlen(aux2)+strlen(aux));x++){
		cola[x]=aux[index];
		index++;
	}

	cola[x]=',';
	cola[x+1]='\0';
	
}


char* desencola() {
	int cont=0;
	int encontrado=0;
	while( (encontrado==0) && (cont<=sizeof(cola))){
        if(cola[cont]==',') {
			encontrado=1;
		}   
        cont++;
	}	
    
	strncpy(aux,cola,(cont-1));
	aux[cont-1] = '\0';
	char aux2[TAMANIO_COLA];
	strncpy(aux2,cola,TAMANIO_COLA);
	int index=0;
	int i;
	for(i=cont;i<=TAMANIO_COLA;i++) {
		cola[index]=aux2[i];
		index++;
	}
	cola[index]='\0';
	
	return(aux);
}

int cerrarTabla() {
	fclose(tabla);
}

int errorCaracter() {
	printf("ERROR FATAL: El caracter %s no esta definido",yytext);
	exit(1);
}