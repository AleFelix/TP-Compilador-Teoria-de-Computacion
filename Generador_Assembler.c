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
#define PREFIJO_CONSTANTES "zv"
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

char *valorFib = "AUX_valorFib";
char *valorAnt1 = "AUX_valorAnterior1";
char *valorAnt2 = "AUX_valorAnterior2";
char *pos = "AUX_posicion";

void declararVariables();
void declararID(char *nombreID, char *tipoID);
void copiarElementoAMatrizTabla(char *nombre, char *tipo, char *valorOTipoID);
void declararConstante(char *tipo, char *valor);
void declararAux();
void generarCabecera();
void generarInicioCodigo();
void generarCodigo();
void insertarOperacionCompleja(char *variable, char *operador);
void insertarOperacionSimple(char *valor1, char*valor2, char *operador);
void insertarComparacion(char *valor1, char*valor2);
void insertarSalto(char *token);
void insertarAsignacionCompleja(char *variable);
void insertarAsignacionSimple(char *valor, char *variable);
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
void buscarConstanteEnMatrizTabla(char* valor);
int contarLineas(FILE *file);
void lineasToArray(FILE *file, char array[][TAMANIO_LINEA]);
int esOperador(char* token);
int esAsignacion(char* token);
int esComparacion(char* token);
int esEtiqueta(char* token);
int esDefinicionDeEtiqueta(char* token);
int esSalto(char *token);
void obtenerInstruccionDeOperador(char *operador);
void concatenarDelante(char* texto, const char* textoPrevio);

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
	char aux1[TAMANIO_LINEA];
	char aux2[TAMANIO_LINEA];
	while (obtenerSiguienteTokenPolaca(token) == TRUE) {
		if (esOperador(token) == FALSE) {
			if (esEtiqueta(token) == FALSE) {
				if (esComparacion(token) == FALSE) {
					if (esSalto(token) == TRUE) {
						insertarSalto(token);
					} else {
						encolarToken(token);
						printf("ENCOLE: %s\n", token);
					}
				} else {
					desencolarToken(aux2);
					desencolarToken(aux1);
					buscarConstanteEnMatrizTabla(aux1);
					buscarConstanteEnMatrizTabla(aux2);
					insertarComparacion(aux1, aux2);
				}
			} else {
				if (esDefinicionDeEtiqueta(token) == TRUE) {
					insertarDefEtiquetaASM(token);
				} else {
					strcpy(etiquetaEncontrada, token);
				}
			}
			anteUltimoTokenFueOperador = ultimoTokenFueOperador;
			ultimoTokenFueOperador = FALSE;
		} else {
			if (esAsignacion(token) == TRUE) {
				if (anteUltimoTokenFueOperador == TRUE) {
					desencolarToken(aux1);
					insertarAsignacionCompleja(aux1);
				} else {
					desencolarToken(aux2);
					desencolarToken(aux1);
					buscarConstanteEnMatrizTabla(aux1);
					insertarAsignacionSimple(aux1, aux2);
				}
			} else {
				if (ultimoTokenFueOperador == TRUE || anteUltimoTokenFueOperador == TRUE) {
					desencolarToken(aux1);
					insertarOperacionCompleja(aux1, token);
				} else {
					desencolarToken(aux2);
					desencolarToken(aux1);
					buscarConstanteEnMatrizTabla(aux1);
					buscarConstanteEnMatrizTabla(aux2);
					insertarOperacionSimple(aux1, aux2, token);
				}
			}
			anteUltimoTokenFueOperador = ultimoTokenFueOperador;
			ultimoTokenFueOperador = TRUE;
		}
	}
}

void insertarOperacionCompleja(char *variable, char *operador) {
	obtenerInstruccionDeOperador(operador);
	char *linea = malloc(sizeof(char) * STRING_SIZE);
	strcpy(linea, "\tfld ");
	strcat(linea, variable);
	strcat(linea, "\n\t");
	strcat(linea, operador);
	fprintf(assembler, "%s\n", linea);
	free(linea);
}

void insertarOperacionSimple(char *valor1, char*valor2, char *operador) {
	obtenerInstruccionDeOperador(operador);
	char *linea = malloc(sizeof(char) * STRING_SIZE);
	strcpy(linea, "\tfld ");
	strcat(linea, valor1);
	strcat(linea, "\n\tfld ");
	strcat(linea, valor2);
	strcat(linea, "\n\t");
	strcat(linea, operador);
	fprintf(assembler, "%s\n", linea);
	free(linea);
}

void insertarComparacion(char *valor1, char*valor2) {
	char *linea = malloc(sizeof(char) * STRING_SIZE);
	strcpy(linea, "\tfld ");
	strcat(linea, valor1);
	strcat(linea, "\n\tfld ");
	strcat(linea, valor2);
	strcat(linea, "\n\tfxch\n\tfcomp\n\tfstsw ax\n\tffree st(0)\n\tsahf");
	fprintf(assembler, "%s\n", linea);
	free(linea);
}

void insertarSalto(char *token) {
	char *linea = malloc(sizeof(char) * STRING_SIZE);
	strcpy(linea, "\t");
	strcat(linea, token);
	strcat(linea, " ");
	strcat(linea, etiquetaEncontrada);
	fprintf(assembler, "%s\n", linea);
	free(linea);
}

void insertarAsignacionCompleja(char *variable) {
	char *linea = malloc(sizeof(char) * STRING_SIZE);
	strcpy(linea, "\tfstp ");
	strcat(linea, variable);
	fprintf(assembler, "%s\n", linea);
	free(linea);
}

void insertarAsignacionSimple(char *valor, char *variable) {
	char *linea = malloc(sizeof(char) * STRING_SIZE);
	strcpy(linea, "\tfld ");
	strcat(linea, valor);
	strcat(linea, "\n\tfstp ");
	strcat(linea, variable);
	fprintf(assembler, "%s\n", linea);
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
				copiarElementoAMatrizTabla(valoresTabla[i - 1], valoresTabla[i], valoresTabla[i + 1]);
			} else {
				declararConstante(valoresTabla[i], valoresTabla[i + 1]);
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
	if (strcmp(tipoID, ID_CADENA) == TRUE) {
		strcpy(tipo, "db\tMAXTEXTSIZE dup (?),'$'");
	} else {
		strcpy(tipo, "dd\t?");
	}
	strcpy(declaracion, "\t");
	
	//fran
	
	if((strcmp(nombreID,valorFib) != 0) &&  (strcmp(nombreID,valorAnt1) != 0) && (strcmp(nombreID,valorAnt2) != 0) && (strcmp(nombreID,pos)))
	{
	strcat(declaracion, "_");
    }
	strcat(declaracion, nombreID);
	strcat(declaracion, "\t\t\t");
	strcat(declaracion, tipo);
	fprintf(assembler, "%s\n", declaracion);
	free(tipo);
	free(declaracion);
}

void declararConstante(char *tipo, char *valor) {
	char *declaracion = malloc(sizeof(char) * STRING_SIZE);
	strcpy(declaracion, "\t");
	strcat(declaracion, PREFIJO_CONSTANTES);
	char buffer[10];
	snprintf(buffer, 10, "%d", indiceConstantes);
	indiceConstantes++;
	strcat(declaracion, buffer);
	copiarElementoAMatrizTabla(declaracion, tipo, valor);
	if (strcmp(tipo, TIPO_CADENA) == TRUE) {
		strcat(declaracion, "\t\t\tdb\t\"");
		strcat(declaracion, valor);
		strcat(declaracion, "\",'$', XX dup (?)");
	} else {
		char buffer[10];
		snprintf(buffer, 10, "%d", &valor);
		strcat(declaracion, "\t\t\tdd\t");
		strcat(declaracion, buffer);
	}
	fprintf(assembler, "%s\n", declaracion);
	free(declaracion);
}

void declararAux() {
	char *declaracion = "\taux\t\t\tdb\t?";
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
	free(cabecera);
}

void generarInicioCodigo() {
	char *inicioCodigo = "\n.CODE\n\n\tmov AX,@DATA\n\tmov DS,AX\n\tmov es,ax";
	fprintf(assembler, "%s\n", inicioCodigo);
}

void generarFinCodigo() {
	char *finCodigo = "\tmov ax, 4C00h\n\tint 21h\n\nEND";
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
		free(linea);
	}
}

void buscarConstanteEnMatrizTabla(char* valor) {
	char* tipoActual;
	int i;
	for (i = 0; i < TAMANIO_COLA; i++) {
		tipoActual = matrizTabla[i][POS_TIPO_TABLA];
		if (strcmp(tipoActual, TIPO_ID) != 0) {
			if (strcmp(matrizTabla[i][POS_TIPOID_TABLA], valor) == TRUE) {
				strcpy(valor, matrizTabla[i][POS_NOMBRE_TABLA]);
			}
		}
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
	} else if (strcmp("++", token) == TRUE) {
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
	if (strcmp("BGE", token) == TRUE) {
		return TRUE;
	} else if (strcmp("BGT", token) == TRUE) {
		return TRUE;
	} else if (strcmp("BLE", token) == TRUE) {
		return TRUE;
	} else if (strcmp("BLT", token) == TRUE) {
		return TRUE;
	} else if (strcmp("BNE", token) == TRUE) {
		return TRUE;
	} else if (strcmp("BEQ", token) == TRUE) {
		return TRUE;
	} else if (strcmp("BI", token) == TRUE) {
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


