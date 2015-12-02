#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>

#define TRUE 0
#define FALSE 1
#define TAMANIO_COLA 10000
#define STRING_SIZE 200
#define CANT_ATTR_TABLA 3
#define TAMANIO_ELEM 101
#define TAMANIO_LINEA 120
#define POS_NOMBRE_TABLA 0
#define POS_TIPO_TABLA 1
#define POS_TIPOID_TABLA 2
#define MAX_TAM_TEXT 50
#define TIPO_ID "ID"
#define ID_CADENA "cadena"
#define ID_REAL "real"
#define ID_ENTERO "entero"
#define TIPO_CADENA "CADENA"
#define TIPO_ENTERO "ENTERO"
#define TIPO_REAL "REAL"
#define PREFIJO_ETIQUETAS "ET_"

FILE *tabla;
FILE *polaca;
FILE *assembler;
int indiceConstantes = 0;
int indiceMatrizTabla = 0;
int indiceColaTokens = 0;
char matrizTabla[TAMANIO_COLA][CANT_ATTR_TABLA][TAMANIO_ELEM];
char colaTokens[TAMANIO_COLA][TAMANIO_ELEM];
char etiquetaEncontrada[TAMANIO_ELEM];
int ultimoTokenFueOperador = FALSE;
int anteUltimoTokenFueOperador = FALSE;
int lectura = FALSE;
int escritura = FALSE;
int concatenacion = FALSE;

void declararVariables();
void declararID(char *nombreID, char *tipoID);
void copiarElementoAMatrizTabla(char *nombre, char *tipo, char *valorOTipoID);
void declararConstante(char *tipo, char *valor);
void declararAux();
void generarCabecera();
void generarInicioCodigo();
void generarCodigo();
void insertarLectura(char *token);
void insertarEscritura(char *token);
void insertarOperacionCompleja(char *variable, char *operador);
void insertarOperacionSimple(char *valor1, char*valor2, char *operador);
void insertarComparacion(char *valor1, char*valor2);
void insertarSalto(char *token);
void insertarAsignacionCompleja(char *variable);
void insertarAsignacionSimple(char *valor, char *variable);
void insertarAsignacionConcatenadaCadena(char *valor1, char *valor2, char *variable);
void insertarAsignacionSimpleCadena(char *valor, char *variable);
void insertarDefEtiquetaASM(char *linea);
void generarFinCodigo();
void iniAssembler();
void cerrAssembler();
void encolarToken(char *token);
void desencolarToken(char *token);
void iniPolaca();
void cerrPolaca();
int obtenerSiguienteTokenPolaca(char *token);
void iniTabla();
void cerrTabla();
void cargarArrayDeTabla(int cantLineasTabla, char arreglo[][TAMANIO_ELEM]);
int contarLineas(FILE *file);
void lineasToArray(FILE *file, char array[][TAMANIO_LINEA]);
int esEscrituraOLectura(char* token);
int esEscritura(char* token);
int esOperador(char* token);
int esAsignacion(char* token);
int esComparacion(char* token);
int esEtiqueta(char* token);
int esDefinicionDeEtiqueta(char* token);
int esSalto(char *token);
void obtenerInstruccionDeOperador(char *operador);
void concatenarDelante(char* texto, const char* textoPrevio);
char* concatenarGuionEnCadena(char* cadena);
int tienePuntoDecimal(char* token);
void agregarFinCadena(char *cadena);
int verificarSiEsCadena(char *token);
char* generarRutinasCadenas();
int esConcatenacion(char *token);
void insertarEsperaTecla();
int sonDelMismoTipo(char* token1, char* token2);
int verificarSiEsID(char *token);

int main(int argc, char *argv[]) {
	iniTabla();
	iniPolaca();
	iniAssembler();
	generarCabecera();
	declararVariables();
	generarInicioCodigo();
	generarCodigo();
	generarFinCodigo();
	cerrTabla();
	cerrPolaca();
	cerrAssembler();
	return 0;
}

/*********************************************
 *
 *    METODOS DE ASSEMBLER
 *
 *********************************************
 */

void generarCodigo() {
	char token[TAMANIO_LINEA];
	char aux0[TAMANIO_LINEA];
	char aux1[TAMANIO_LINEA];
	char aux2[TAMANIO_LINEA];
	while (obtenerSiguienteTokenPolaca(token) == TRUE) {
		if (lectura == TRUE) {
			insertarLectura(token);
			lectura = FALSE;
		} else if (escritura == TRUE) {
			insertarEscritura(token);
			escritura = FALSE;
		} else if (esConcatenacion(token) == TRUE) {
			concatenacion = TRUE;
		} else if (esEscrituraOLectura(token) == FALSE) {
			if (esOperador(token) == FALSE) {
				if (esEtiqueta(token) == FALSE) {
					if (esComparacion(token) == FALSE) {
						if (esSalto(token) == TRUE) { //Es salto
							insertarSalto(token);
						} else { //Es ID o constante
							encolarToken(token);
							printf("ENCOLE: %s\n", token);
						}
					} else { //Es comparacion
						desencolarToken(aux2);
						desencolarToken(aux1);
						insertarComparacion(aux1, aux2);
					}
				} else { //Es etiqueta
					if (esDefinicionDeEtiqueta(token) == TRUE) {
						insertarDefEtiquetaASM(token);
					} else {
						strcpy(etiquetaEncontrada, token);
					}
				}
				anteUltimoTokenFueOperador = ultimoTokenFueOperador;
				ultimoTokenFueOperador = FALSE;
			} else { //Es operador
				if (esAsignacion(token) == TRUE) { //El operador es asignacion
					if (anteUltimoTokenFueOperador == TRUE) {
						desencolarToken(aux1);
						insertarAsignacionCompleja(aux1);
					} else {
						desencolarToken(aux2);
						desencolarToken(aux1);
						if (verificarSiEsCadena(aux1) == TRUE) {
							if (concatenacion == TRUE) {
								desencolarToken(aux0);
								insertarAsignacionConcatenadaCadena(aux0, aux1, aux2);
								concatenacion = FALSE;
							} else {
								insertarAsignacionSimpleCadena(aux1, aux2);
							}
						} else {
							insertarAsignacionSimple(aux1, aux2);
						}
					}
				} else { //El operador no es asignacion
					if (ultimoTokenFueOperador == TRUE || anteUltimoTokenFueOperador == TRUE) {
						desencolarToken(aux1);
						insertarOperacionCompleja(aux1, token);
					} else {
						desencolarToken(aux2);
						desencolarToken(aux1);
						insertarOperacionSimple(aux1, aux2, token);
					}
				}
				anteUltimoTokenFueOperador = ultimoTokenFueOperador;
				ultimoTokenFueOperador = TRUE;
			}
		} else { //Es escritura o lectura
			if (esEscritura(token) == TRUE) {
				escritura = TRUE;
			} else {
				lectura = TRUE;
			}
		}
	}
}

void insertarEsperaTecla() {
	char *linea = malloc(sizeof(char) * STRING_SIZE);
	strcpy(linea, "\tmov dx,OFFSET _NEWLINE\n\tmov ah,09\n\tint 21h\n\tmov dx,OFFSET _msgPRESIONE\n\tmov ah,09\n\tint 21h\n\tmov ah, 1\n\tint 21h");
	fprintf(assembler, "%s\n", linea);
	//Seguro
	free(linea);
}

void insertarLectura(char *token) {
	char *linea = malloc(sizeof(char) * STRING_SIZE);
	if (verificarSiEsCadena(token) == TRUE) {
		strcpy(linea, "\tgetString ");
		strcat(linea, token);
	} else {
		strcpy(linea, "\tGetFloat ");
		strcat(linea, token);
	}
	fprintf(assembler, "%s\n", linea);
	//Seguro
	free(linea);
}

void insertarEscritura(char *token) {
	char *linea = malloc(sizeof(char) * STRING_SIZE);
	if (verificarSiEsCadena(token) == TRUE) {
		strcpy(linea, "\tmov dx,OFFSET ");
		strcat(linea, token);
		strcat(linea, "\n\tmov ah,9\n\tint 21h\n\tnewLine 1");
	} else {
		strcpy(linea, "\tdisplayFloat ");
		strcat(linea, token);
		strcat(linea, ",2\n\tnewLine 1");
	}
	fprintf(assembler, "%s\n", linea);
	//Seguro
	free(linea);
}

void insertarOperacionCompleja(char *variable, char *operador) {
	if (verificarSiEsCadena(variable) == TRUE) {
		printf("ERROR FATAL: No se puede realizar la operacion %s sobre la cadena %s\n", operador, variable);
		exit(1);
	}
	obtenerInstruccionDeOperador(operador);
	char *linea = malloc(sizeof(char) * STRING_SIZE);
	strcpy(linea, "\tfld ");
	strcat(linea, variable);
	strcat(linea, "\n\t");
	strcat(linea, operador);
	fprintf(assembler, "%s\n", linea);
	//Seguro
	free(linea);
}

void insertarOperacionSimple(char *valor1, char*valor2, char *operador) {
	if (sonDelMismoTipo(valor1, valor2) == FALSE) {
		printf("ERROR FATAL: Se intento realizar la operacion %s sobre los elementos %s y %s, los cuales no son del mismo tipo\n", operador, valor1, valor2);
		exit(1);
	}
	obtenerInstruccionDeOperador(operador);
	char *linea = malloc(sizeof(char) * STRING_SIZE);
	strcpy(linea, "\tfld ");
	strcat(linea, valor1);
	strcat(linea, "\n\tfld ");
	strcat(linea, valor2);
	strcat(linea, "\n\t");
	strcat(linea, operador);
	fprintf(assembler, "%s\n", linea);
	//Seguro
	free(linea);
}

void insertarComparacion(char *valor1, char*valor2) {
	if (sonDelMismoTipo(valor1, valor2) == FALSE) {
		printf("ERROR FATAL: Se intento comparar los elementos %s y %s, los cuales no son del mismo tipo\n", valor1, valor2);
		exit(1);
	}
	char *linea = malloc(sizeof(char) * STRING_SIZE);
	strcpy(linea, "\tfld ");
	strcat(linea, valor1);
	strcat(linea, "\n\tfld ");
	strcat(linea, valor2);
	strcat(linea, "\n\tfxch\n\tfcomp\n\tfstsw ax\n\tffree st(0)\n\tsahf");
	fprintf(assembler, "%s\n", linea);
	//Seguro
	free(linea);
}

void insertarSalto(char *token) {
	char *linea = malloc(sizeof(char) * STRING_SIZE);
	strcpy(linea, "\t");
	strcat(linea, token);
	strcat(linea, " ");
	strcat(linea, etiquetaEncontrada);
	fprintf(assembler, "%s\n", linea);
	//Seguro
	free(linea);
}

void insertarAsignacionCompleja(char *variable) {
	if (verificarSiEsID(variable) == FALSE) {
		printf("ERROR FATAL: %s no es un ID sobre el que se pueda realizar asignaciones\n", variable);
		exit(1);
	} else if (verificarSiEsCadena(variable) == TRUE) {
		printf("ERROR FATAL: No se puede realizar la asignacion sobre la cadena %s\n", variable);
		exit(1);
	}
	char *linea = malloc(sizeof(char) * STRING_SIZE);
	strcpy(linea, "\tfstp ");
	strcat(linea, variable);
	fprintf(assembler, "%s\n", linea);
	//Seguro
	free(linea);
}

void insertarAsignacionSimple(char *valor, char *variable) {
	if (verificarSiEsID(variable) == FALSE) {
		printf("ERROR FATAL: %s no es un ID sobre el que se pueda realizar asignaciones\n", variable);
		exit(1);
	} else if (sonDelMismoTipo(valor, variable) == FALSE) {
		printf("ERROR FATAL: Se intento asignar %s a %s, los cuales no son del mismo tipo\n", valor, variable);
		exit(1);
	}
	char *linea = malloc(sizeof(char) * STRING_SIZE);
	strcpy(linea, "\tfld ");
	strcat(linea, valor);
	strcat(linea, "\n\tfstp ");
	strcat(linea, variable);
	fprintf(assembler, "%s\n", linea);
	//Seguro
	free(linea);
}

void insertarAsignacionConcatenadaCadena(char *valor1, char *valor2, char *variable) {
	if (verificarSiEsID(variable) == FALSE) {
		printf("ERROR FATAL: %s no es un ID sobre el que se pueda realizar asignaciones\n", variable);
		exit(1);
	} else if (verificarSiEsCadena(valor1) == FALSE) {
		printf("ERROR FATAL: No se puede realizar la concatenacion de %s\n", valor1);
		exit(1);
	} else if (verificarSiEsCadena(valor2) == FALSE) {
		printf("ERROR FATAL: No se puede realizar la concatenacion de %s\n", valor2);
		exit(1);
	} else if (verificarSiEsCadena(variable) == FALSE) {
		printf("ERROR FATAL: No se puede realizar la asignacion de la concatenacion sobre %s\n", variable);
		exit(1);
	}
	char *linea = malloc(sizeof(char) * STRING_SIZE);
	strcpy(linea, "\tmov si,OFFSET ");
	strcat(linea, valor1);
	strcat(linea, "\n\tmov di,OFFSET _aux\n\tcall COPIAR\n\tmov si,OFFSET ");
	strcat(linea, valor2);
	strcat(linea, "\n\tmov di,OFFSET _aux\n\tcall CONCAT\n\tmov si,OFFSET _aux\n\tmov di,OFFSET ");
	strcat(linea, variable);
	strcat(linea, "\n\tcall COPIAR");
	fprintf(assembler, "%s\n", linea);
	//Seguro
	free(linea);
}

void insertarAsignacionSimpleCadena(char *valor, char *variable) {
	if (verificarSiEsID(variable) == FALSE) {
		printf("ERROR FATAL: %s no es un ID sobre el que se pueda realizar asignaciones\n", variable);
		exit(1);
	} else if (verificarSiEsCadena(valor) == FALSE) {
		printf("ERROR FATAL: No se puede realizar la asignacion de %s a una variable cadena\n", valor);
		exit(1);
	} else if (verificarSiEsCadena(variable) == FALSE) {
		printf("ERROR FATAL: No se puede realizar la asignacion de la cadena sobre %s\n", variable);
		exit(1);
	}
	char *linea = malloc(sizeof(char) * STRING_SIZE);
	strcpy(linea, "\tmov si,OFFSET ");
	strcat(linea, valor);
	strcat(linea, "\n\tmov di,OFFSET ");
	strcat(linea, variable);
	strcat(linea, "\n\tcall COPIAR");
	fprintf(assembler, "%s\n", linea);
	//Seguro
	free(linea);
}

void insertarDefEtiquetaASM(char *linea) {
	fprintf(assembler, "%s\n", linea);
}

void declararVariables() {
	int cantLineasTabla = contarLineas(tabla);
	int cantElementosArrayTabla = cantLineasTabla * CANT_ATTR_TABLA;
	char valoresTabla[cantElementosArrayTabla][TAMANIO_ELEM];
	cargarArrayDeTabla(cantLineasTabla, valoresTabla);
	int posElemento = 0;
	int i;
	for (i = 0; i < cantElementosArrayTabla; i++) {
		if (posElemento == CANT_ATTR_TABLA) {
			posElemento = 0;
		}
		if (posElemento == POS_TIPO_TABLA) {
			if (strcmp(valoresTabla[i], TIPO_ID) == TRUE) {
				declararID(valoresTabla[i - 1], valoresTabla[i + 1]);
				printf("%s fue declarado\n", valoresTabla[i - 1]);
			} else {
				declararConstante(valoresTabla[i], valoresTabla[i + 1]);
				printf("%s fue declarado\n", valoresTabla[i - 1]);
			}
		}
		posElemento++;
	}
	declararAux();
}

void copiarElementoAMatrizTabla(char *nombre, char *tipo, char *valorOTipoID) {
	strcpy(matrizTabla[indiceMatrizTabla][POS_NOMBRE_TABLA], nombre);
	strcpy(matrizTabla[indiceMatrizTabla][POS_TIPO_TABLA], tipo);
	strcpy(matrizTabla[indiceMatrizTabla][POS_TIPOID_TABLA], valorOTipoID);
	indiceMatrizTabla++;
}

void declararID(char *nombreID, char *tipoID) {
	char *declaracion = malloc(sizeof(char) * STRING_SIZE);
	char *tipo = malloc(sizeof(char) * 30);
	char *nombreGuionID = malloc(sizeof(char) * STRING_SIZE);
	strcpy(nombreGuionID, "_");
	strcat(nombreGuionID, nombreID);
	copiarElementoAMatrizTabla(nombreGuionID, TIPO_ID, tipoID);
	if (strcmp(tipoID, ID_CADENA) == TRUE) {
		strcpy(tipo, "db\tMAXTEXTSIZE dup (?),'$'");
	} else {
		strcpy(tipo, "dd\t?");
	}
	strcpy(declaracion, "\t");
	strcat(declaracion, nombreGuionID);
	strcat(declaracion, "\t\t\t");
	strcat(declaracion, tipo);
	fprintf(assembler, "%s\n", declaracion);
	//Seguro
	free(tipo);
	//Seguro
	free(nombreGuionID);
	//Seguro
	free(declaracion);
}

void declararConstante(char *tipo, char *valor) {
	char *declaracion = malloc(sizeof(char) * STRING_SIZE);
	strcpy(declaracion, "\t");
	if (strcmp(tipo, TIPO_CADENA) == TRUE) {
		char *nombreCadena = malloc(sizeof(char) * STRING_SIZE);
		strcpy(nombreCadena,concatenarGuionEnCadena(valor));
		copiarElementoAMatrizTabla(nombreCadena, tipo, valor);
		strcat(declaracion, nombreCadena);
		agregarFinCadena(valor);
		int longStr = longString(valor);
		int espacioSobrante = MAX_TAM_TEXT - longStr + 2;
		char buffer[10];
		snprintf(buffer, 10, "%d", espacioSobrante);
		strcat(declaracion, "\t\t\tdb\t");
		strcat(declaracion, valor);
		strcat(declaracion, ",'$', ");
		strcat(declaracion, buffer);
		strcat(declaracion, " dup (?)");
		//free(valor);
		//free(nombreCadena);
	} else {
		char *nombreNumero = malloc(sizeof(char) * 30);
		strcpy(nombreNumero, "_");
		strcat(nombreNumero, valor);
		copiarElementoAMatrizTabla(nombreNumero, tipo, valor);
		strcat(declaracion, nombreNumero);
		strcat(declaracion, "\t\t\tdd\t");
		strcat(declaracion, valor);
		if (tienePuntoDecimal(valor) == FALSE) {
			strcat(declaracion, ".0");
		}
		//Seguro
		free(nombreNumero);
	}
	fprintf(assembler, "%s\n", declaracion);
	//Seguro
	free(declaracion);
}

void declararAux() {
	char *declaracion =
			"\t_aux\t\t\tdb\tMAXTEXTSIZE dup (?),'$'\n\t_msgPRESIONE\t\t\tdb\t0DH,0AH,\"Presione una tecla para continuar...\",'$'\n\t_NEWLINE\t\t\tdb\t0DH,0AH,'$'";
	fprintf(assembler, "%s\n", declaracion);
}

void generarCabecera() {
	char *cabecera = malloc(sizeof(char) * STRING_SIZE);
	strcpy(cabecera, "include macros2.asm\ninclude number.asm\n\n");
	strcat(cabecera, ".MODEL\tLARGE\n.386\n.STACK 200h\n\nMAXTEXTSIZE equ ");
	char buffer[10];
	snprintf(buffer, 10, "%d", MAX_TAM_TEXT);
	strcat(cabecera, buffer);
	strcat(cabecera, "\n\n.DATA\n");
	fprintf(assembler, "%s\n", cabecera);
	//Seguro
	free(cabecera);
}

void generarInicioCodigo() {
	char *inicioCodigo1 = "\n.CODE\n";
	fprintf(assembler, "%s\n", inicioCodigo1);
	fprintf(assembler, "%s\n\n", generarRutinasCadenas());
	char *inicioCodigo2 = "\nSTART:\n\tmov AX,@DATA\n\tmov DS,AX\n\tmov es,ax";
	fprintf(assembler, "%s\n", inicioCodigo2);
}

void generarFinCodigo() {
	insertarEsperaTecla();
	char *finCodigo = "\tmov ax, 4C00h\n\tint 21h\nEND START";
	fprintf(assembler, "%s\n", finCodigo);
}

void iniAssembler() {
	assembler = fopen("assembler.asm", "w+");
	if (assembler == NULL) {
		printf("\nNo se puede abrir el archivo de assembler\n");
		exit(1);
	}
}

void cerrAssembler() {
	fclose(assembler);
}

void encolarToken(char *token) {
	strcpy(colaTokens[indiceColaTokens], token);
	indiceColaTokens++;
}

void desencolarToken(char *token) {
	strcpy(token, colaTokens[indiceColaTokens - 1]);
	indiceColaTokens--;
}

/*********************************************
 *
 *    METODOS DE POLACA
 *
 *********************************************
 */

void iniPolaca() {
	polaca = fopen("intermedia.txt", "r+");
	if (polaca == NULL) {
		printf("\nNo se puede abrir el archivo de la polaca inversa\n");
		exit(1);
	}
}

void cerrPolaca() {
	fclose(polaca);
}

int obtenerSiguienteTokenPolaca(char *token) {
	if (fgets(token, sizeof(char) * TAMANIO_LINEA, polaca) != NULL) {
		strtok(token, "\n"); //Esto elimina el salto de linea
		return TRUE;
	} else {
		return FALSE;
	}
}

/*********************************************
 *
 *    METODOS DE TABLA
 *
 *********************************************
 */

void iniTabla() {
	tabla = fopen("tabla.txt", "r+");
	if (tabla == NULL) {
		printf("\nNo se puede abrir el archivo de la tabla de simbolos\n");
		exit(1);
	}
}

void cerrTabla() {
	fclose(tabla);
}

void cargarArrayDeTabla(int cantLineasTabla, char arreglo[][TAMANIO_ELEM]) {
	char lineasTabla[cantLineasTabla][TAMANIO_LINEA];
	lineasToArray(tabla, lineasTabla);
	int i, j, k;
	j = 0;
	for (i = 0; i < cantLineasTabla; i++) {
		char *linea = malloc(sizeof(char) * TAMANIO_LINEA);
		char *token;
		strcpy(linea, lineasTabla[i]);
		token = strtok(linea, ";");
		for (k = 0; k < CANT_ATTR_TABLA; k++) {
			strcpy(arreglo[j++], token);
			token = strtok(NULL, ";");
		}
		//Seguro
		free(linea);
	}
}

/*********************************************
 *
 *    METODOS AUXILIARES
 *
 *********************************************
 */

int contarLineas(FILE *file) {
	int lines = 0;
	int c;
	int last = '\n';
	while (EOF != (c = fgetc(file))) {
		if (c == '\n' && last != '\n') {
			++lines;
		}
		last = c;
	}
	/* Resetea el puntero al inicio del archivo */
	rewind(file);
	return lines;
}

void lineasToArray(FILE *file, char array[][TAMANIO_LINEA]) {
	int i = 0;
	if (file != NULL) {
		char line[TAMANIO_LINEA];
		while (fgets(line, sizeof line, file) != NULL) {
			strcpy(array[i], line);
			i++;
		}
	} else {
		printf("\nError al pasar las lineas de un archivo a un arreglo\n");
		exit(1);
	}
}

int esEscrituraOLectura(char* token) {
	if (strcmp("escribir", token) == TRUE) {
		return TRUE;
	} else if (strcmp("leer", token) == TRUE) {
		return TRUE;
	} else {
		return FALSE;
	}
}

int esEscritura(char* token) {
	if (strcmp("escribir", token) == TRUE) {
		return TRUE;
	} else {
		return FALSE;
	}
}

int esOperador(char* token) {
	if (strcmp("=", token) == TRUE) {
		return TRUE;
	} else if (strcmp("+", token) == TRUE) {
		return TRUE;
	} else if (strcmp("-", token) == TRUE) {
		return TRUE;
	} else if (strcmp("*", token) == TRUE) {
		return TRUE;
	} else if (strcmp("/", token) == TRUE) {
		return TRUE;
	} else {
		return FALSE;
	}
}

int esAsignacion(char* token) {
	if (strcmp("=", token) == TRUE) {
		return TRUE;
	} else {
		return FALSE;
	}
}

int esComparacion(char* token) {
	if (strcmp("CMP", token) == TRUE) {
		return TRUE;
	} else {
		return FALSE;
	}
}

int esEtiqueta(char* token) {
	if (strstr(token, PREFIJO_ETIQUETAS) != NULL) {
		return TRUE;
	} else {
		return FALSE;
	}
}

int esDefinicionDeEtiqueta(char* token) {
	if (strstr(token, ":") != NULL) {
		return TRUE;
	} else {
		return FALSE;
	}
}

int esSalto(char *token) {
	if (strcmp("JAE", token) == TRUE) {
		return TRUE;
	} else if (strcmp("JA", token) == TRUE) {
		return TRUE;
	} else if (strcmp("JBE", token) == TRUE) {
		return TRUE;
	} else if (strcmp("JB", token) == TRUE) {
		return TRUE;
	} else if (strcmp("JNE", token) == TRUE) {
		return TRUE;
	} else if (strcmp("JE", token) == TRUE) {
		return TRUE;
	} else if (strcmp("JMP", token) == TRUE) {
		return TRUE;
	} else {
		return FALSE;
	}
}

void obtenerInstruccionDeOperador(char *operador) {
	if (strcmp("+", operador) == TRUE) {
		strcpy(operador, "fadd");
	} else if (strcmp("-", operador) == TRUE) {
		strcpy(operador, "fsub");
	} else if (strcmp("*", operador) == TRUE) {
		strcpy(operador, "fmul");
	} else if (strcmp("/", operador) == TRUE) {
		strcpy(operador, "fdiv");
	} else {
		printf("\nERROR FATAL: Operador %s desconocido\n", operador);
	}
}

void concatenarDelante(char* texto, const char* textoPrevio) {
	size_t longitud = strlen(textoPrevio);
	size_t i;
	memmove(texto + longitud, texto, strlen(texto) + 1);
	for (i = 0; i < longitud; ++i) {
		texto[i] = textoPrevio[i];
	}
}

int longString(char *string) {
	size_t longitud = 0;
	char *p = malloc(STRING_SIZE);
	strcpy(p, string);
	while (*p++ != '\0') {
		longitud++;
	}
	longitud = longitud / sizeof(char);
	//free(p);
	return longitud;
}

char* concatenarGuionEnCadena(char* cadena) {
	char *copia;
	copia = malloc(sizeof(char) * strlen(cadena));
	strcpy(copia, cadena);
	char *contenido;
	// Determino el nuevo tamaño
	int newSize = strlen("T_") + strlen(copia) + 1;
	// Malloc del nuevo tamaño en una nueva variable
	char * newBuffer = (char *) malloc(newSize);
	// Copiamos y concatenamos
	strcpy(newBuffer, "T_");
	contenido = strtok(copia, "\"");
	char *puntero = contenido;
	for (; *puntero; ++puntero) {
		if (*puntero == ' ') {
			*puntero = '_';
		}
	}
	strcat(newBuffer, contenido);
	//free(copia);
	return newBuffer;
}

int tienePuntoDecimal(char* token) {
	if (strstr(token, ".") != NULL) {
		return TRUE;
	} else {
		return FALSE;
	}
}

void agregarFinCadena(char *cadena) {
	char *copia;
	copia = malloc(sizeof(char) * strlen(cadena));
	strcpy(copia, cadena);
	char *contenido;
	// Determino el nuevo tamaño
	int newSize = strlen("$") + strlen(copia) + 1;
	// Malloc del nuevo tamaño en una nueva variable
	cadena = (char *) malloc(newSize);
	// Copiamos y concatenamos
	strcpy(cadena, "\"");
	contenido = strtok(copia, "\"");
	strcat(cadena, contenido);
	strcat(cadena, "$\"");
	//free(copia);
}

int sonDelMismoTipo(char* token1, char* token2) {
	int token1EsCadena = verificarSiEsCadena(token1);
	int token2EsCadena = verificarSiEsCadena(token2);
	if (token1EsCadena == TRUE && token2EsCadena == TRUE) {
		return TRUE;
	} else if (token1EsCadena == FALSE && token2EsCadena == FALSE) {
		return TRUE;
	} else {
		return FALSE;
	}
}

int verificarSiEsID(char *token) {
	char* tipoActual;
	int i;
	for (i = 0; i < TAMANIO_COLA; i++) {
		if (strcmp(matrizTabla[i][POS_NOMBRE_TABLA], token) == TRUE) {
			tipoActual = matrizTabla[i][POS_TIPO_TABLA];
			if (strcmp(tipoActual, TIPO_ID) == TRUE) {
				return TRUE;
			} else {
				return FALSE;
			}
		}
	}
	return FALSE;
}

int verificarSiEsCadena(char *token) {
	char* tipoActual;
	int i;
	for (i = 0; i < TAMANIO_COLA; i++) {
		if (strcmp(matrizTabla[i][POS_NOMBRE_TABLA], token) == TRUE) {
			tipoActual = matrizTabla[i][POS_TIPO_TABLA];
			if (strcmp(tipoActual, TIPO_ID) == TRUE) {
				if (strcmp(matrizTabla[i][POS_TIPOID_TABLA], ID_CADENA) == TRUE) {
					return TRUE;
				} else {
					return FALSE;
				}
			} else if (strcmp(tipoActual, TIPO_CADENA) == TRUE) {
				return TRUE;
			} else {
				return FALSE;
			}
		}
	}
	return FALSE;
}

int esConcatenacion(char *token) {
	if (strcmp("++", token) == TRUE) {
		return TRUE;
	} else {
		return FALSE;
	}
}

char* generarRutinasCadenas() {
	return "\
;************************************************************\n\
; devuelve en BX la cantidad de caracteres que tiene un string\n\
; DS:SI apunta al string.\n\
;\n\
STRLEN PROC\n\
\tmov bx,0\n\
STRL01:\n\
\tcmp BYTE PTR [SI+BX],'$'\n\
\tje STREND\n\
\tinc BX\n\
\tjmp STRL01\n\
STREND:\n\
\tret\n\
STRLEN ENDP\n\
\n\
\n\
;*********************************************************************8\n\
; copia DS:SI a ES:DI; busca la cantidad de caracteres\n\
;\n\
COPIAR PROC\n\
\tcall STRLEN\n\
\tcmp bx,MAXTEXTSIZE\n\
\tjle COPIARSIZEOK\n\
\tmov bx,MAXTEXTSIZE\n\
COPIARSIZEOK:\n\
\tmov cx,bx\n\
\tcld\n\
\trep movsb\n\
\tmov al,'$'\n\
\tmov BYTE PTR [DI],al\n\
\tret\n\
COPIAR ENDP\n\
\n\
\n\
;*******************************************************\n\
; concatena DS:SI al final de ES:DI.\n\
;\n\
; busco el size del primer string\n\
; sumo el size del segundo string\n\
; si la suma excede MAXTEXTSIZE, copio solamente MAXTEXTSIZE caracteres\n\
; si la suma NO excede MAXTEXTSIZE, copio el total de caracteres que tiene el segundo string\n\
;\n\
CONCAT PROC\n\
\tpush ds\n\
\tpush si\n\
\tcall STRLEN\n\
\tmov dx,bx\n\
\tmov si,di\n\
\tpush es\n\
\tpop ds\n\
\tcall STRLEN\n\
\tadd di,bx\n\
\tadd bx,dx\n\
\tcmp bx,MAXTEXTSIZE\n\
\tjg CONCATSIZEMAL\n\
CONCATSIZEOK:\n\
\tmov cx,dx\n\
\tjmp CONCATSIGO\n\
CONCATSIZEMAL:\n\
\tsub bx,MAXTEXTSIZE\n\
\tsub dx,bx\n\
\tmov cx,dx\n\
CONCATSIGO:\n\
\tpush ds\n\
\tpop es\n\
\tpop si\n\
\tpop ds\n\
\tcld\n\
\trep movsb\n\
\tmov al,'$'\n\
\tmov BYTE PTR [DI],al\n\
\tret\n\
CONCAT ENDP";
}
