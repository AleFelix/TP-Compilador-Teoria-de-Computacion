%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
FILE  *yyin;
int yylval;
float yylreal;
char* yytext;
%}
%option noyywrap  
%option yylineno
%x comment 

DIGITO        [0-9]
LETRA        [a-zA-Z]
PUNTO        [.]
COMILLAS        ["]
ID        {LETRA}({LETRA}|{DIGITO}|_)*
REAL        {DIGITO}+{PUNTO}{DIGITO}+|{PUNTO}{DIGITO}+|{DIGITO}+{PUNTO}
CADENA        {COMILLAS}({LETRA}|{DIGITO})*{COMILLAS}

%%
"inicioprog"        { return INI_PROG;}
"finprog"        { return FIN_PROG;}
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
"take"    { return TAKE;}
"entero"    { return T_ENTERO; }
"real"    { return T_REAL; }
"cadena"    { return T_CADENA; }
{CADENA}        { return CADENA;}
{REAL}        { yylreal = atof(yytext); yylreal; return REAL;}
{DIGITO}+        { yylval = atoi(yytext); yylval; return ENTERO;}
{ID} {return ID;}
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


