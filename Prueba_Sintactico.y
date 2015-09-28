%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
int yystopparser=0;
FILE  *yyin;

%}

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
programa:
INI_PROG A_LLAVES {printf("A_LLAVES\n");} {printf("Inicia COMPILADOR\n");} declaracion sentencias C_LLAVES {printf("C_LLAVES\n");} FIN_PROG {printf("Fin COMPILADOR ok\n");};
;
declaracion:
DEFINE {printf("Inicia DEFINE\n");} OP_A_CORCH {printf("OP_A_CORCH\n");} tipo dec_variables ID {printf("ID\n");} OP_C_CORCH {printf("OP_C_CORCH\n");} FDEFINE {printf("Termina DEFINE\n");}
;

dec_variables:
COMA {printf("COMA\n");} tipo dec_variables ID {printf("ID\n");} COMA {printf("COMA\n");}
| OP_C_CORCH {printf("OP_C_CORCH\n");} DOS_PUNTOS {printf("DOS PUNTOS\n");} OP_A_CORCH {printf("OP_A_CORCH\n");}
;

tipo:
T_ENTERO {printf("TIPO_ENTERO\n");}
| T_REAL {printf("TIPO_REAL\n");}
| T_CADENA {printf("TIPO_CADENA\n");}
;

sentencias:
sentencia
| sentencias sentencia
;
sentencia:
asignacion PUNTO_COMA {printf("PUNTO_COMA\n");}
| bucle
| decision
| entrada PUNTO_COMA {printf("PUNTO_COMA\n");}
| salida PUNTO_COMA {printf("PUNTO_COMA\n");}
| asignacion_multiple PUNTO_COMA {printf("PUNTO_COMA\n");}
;
asignacion:
ID {printf("ID\n");} ASIGNACION {printf("ASIGNACION\n");} expresion
;
expresion:
expresion OP_SUMA {printf("OP_SUMA\n");} factor
| expresion OP_CONCAT {printf("OP_CONCAT\n");} factor
| expresion OP_MENOS {printf("OP_MENOS\n");} factor
| expresion OP_MULTIP {printf("OP_MULTIP\n");} factor
| expresion OP_DIV {printf("OP_DIV\n");} factor
| OP_A_PARENT {printf("OP_A_PARENT\n");} expresion OP_C_PARENT {printf("OP_C_PARENT\n");}
| factor
;

factor:
ID {printf("ID\n");}
| ENTERO {printf("ENTERO\n");}
| REAL {printf("REAL\n");}
| CADENA {printf("CADENA\n");}
| FIB {printf("FIB\n");} OP_A_PARENT {printf("OP_A_PARENT\n");} expresion OP_C_PARENT {printf("OP_C_PARENT\n");}
| TAKE {printf("TAKE\n");} OP_A_PARENT {printf("OP_A_PARENT\n");} operador PUNTO_COMA {printf("PUNTO_COMA\n");} ENTERO {printf("ENTERO\n");} PUNTO_COMA {printf("PUNTO_COMA\n");} lista_enteros OP_C_PARENT {printf("OP_C_PARENT\n");}
;

bucle:
MIENTRAS {printf("MIENTRAS\n");} OP_A_PARENT {printf("OP_A_PARENT\n");} condicion OP_C_PARENT {printf("OP_C_PARENT\n");} A_LLAVES {printf("A_LLAVES\n");} sentencias C_LLAVES {printf("C_LLAVES\n");}
;

condicion:
condicion OP_MENOR {printf("OP_MENOR\n");} expresion
| condicion OP_MAYOR {printf("OP_MAYOR\n");} expresion
| condicion OP_MENOR_I {printf("OP_MENOR_I\n");} expresion
| condicion OP_MAYOR_I {printf("OP_MAYOR_I\n");} expresion
| condicion OP_IGUAL {printf("OP_IGUAL\n");} expresion
| condicion OP_DISTINTO {printf("OP_DISTINTO\n");} expresion
| condicion OP_Y {printf("OP_Y\n");} expresion
| condicion OP_O {printf("OP_O\n");} expresion

| expresion OP_MENOR {printf("OP_MENOR\n");} condicion
| expresion OP_MAYOR condicion
| expresion OP_MENOR_I {printf("OP_MENOR_I\n");} condicion
| expresion OP_MAYOR_I {printf("OP_MAYOR_I\n");} condicion
| expresion OP_IGUAL {printf("OP_IGUAL\n");} condicion
| expresion OP_DISTINTO {printf("OP_DISTINTO\n");} condicion
| expresion OP_Y {printf("OP_Y\n");} condicion
| expresion OP_O {printf("OP_O\n");} condicion
| NO {printf("NO\n");} OP_A_PARENT {printf("OP_A_PARENT\n");} condicion OP_C_PARENT {printf("OP_C_PARENT\n");}
| factor
;

decision:
SI {printf("SI\n");} OP_A_PARENT {printf("OP_A_PARENT\n");} condicion OP_C_PARENT {printf("OP_C_PARENT\n");} A_LLAVES {printf("A_LLAVES \n");} sentencias C_LLAVES {printf("C_LLAVES \n");} SINO {printf("SINO\n");} A_LLAVES {printf("A_LLAVES\n");} sentencias C_LLAVES {printf("C_LLAVES\n");} |
SI {printf("SI\n");} OP_A_PARENT {printf("OP_A_PARENT\n");} condicion OP_C_PARENT {printf("OP_C_PARENT\n");} A_LLAVES {printf("A_LLAVES\n");} sentencias C_LLAVES {printf("C_LLAVES\n");}
;





entrada:
LEER {printf("LEER\n");} ID {printf("ID\n");}
;

salida:
ESCRIBIR {printf("ESCRIBIR\n");} ID {printf("ID\n");}
| ESCRIBIR {printf("ESCRIBIR\n");} CADENA {printf("CADENA\n");}
;

asignacion_multiple:
OP_A_CORCH {printf("OP_A_CORCH\n");} ID {printf("ID\n");} asig_mul constante OP_C_CORCH {printf("OP_C_CORCH\n");}
;


asig_mul:
COMA {printf("COMA\n");} ID {printf("ID\n");} asig_mul constante COMA {printf("COMA\n");}
| OP_C_CORCH {printf("OP_C_CORCH\n");} ASIGNACION {printf("ASIGNACION\n");} OP_A_CORCH {printf("OP_A_CORCH\n");}


constante:
ENTERO {printf("ENTERO\n");}
| REAL {printf("REAL\n");}
| CADENA {printf("CADENA\n");}
;

operador:
OP_SUMA {printf("OP_SUMA\n");}
| OP_MENOS {printf("OP_MENOS\n");}
| OP_MULTIP {printf("OP_MULTIP\n");}
| OP_DIV {printf("OP_DIV\n");}
;

lista_enteros:
lis_ent ENTERO {printf("ENTERO\n");} OP_C_CORCH {printf("OP_C_CORCH\n");}
;

lis_ent:
lis_ent ENTERO {printf("ENTERO\n");} PUNTO_COMA {printf("PUNTO_COMA\n");}
| OP_A_CORCH {printf("OP_A_CORCH\n");}
;
%%

int main(int argc,char *argv[])
{
  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
    printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else
  {
    yyparse();
  }
  fclose(yyin);
  return 0;
}
int yyerror(void)
{
  printf("Syntax Error\n");
  system ("Pause");
  exit (1);
}