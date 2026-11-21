#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "TablaSimbolos.h"

extern int yylineno;
extern int yysemerrs;

SIMBOLO TS[TAMANIO_TABLA];
int cantidad = 0;

void iniciar_tabla(void) {
    cantidad = 0;
}

int indice_tabla(char* s) {
    for (int i = 0; i < cantidad; i++)
        if (!strcmp(TS[i].id, s)) return i;
    return -1;
}

int valor_simbolo(char* s) {
    int indice = indice_tabla(s);
    if (indice < 0) {
        yysemerrs++;
        printf("Error semantico en linea %d: la variable '%s' se usa sin tener un valor asignado\n", yylineno, s);
        return 0;
    }
    return TS[indice].valor;
}

void escribir_tabla(char* s, int v) {
    int indice = indice_tabla(s);
    if (indice >= 0) {
        TS[indice].valor = v;
        return;
    }
    if (cantidad == TAMANIO_TABLA) {
        printf("Error: no hay mas espacio en la Tabla de Simbolos\n");
        exit(EXIT_FAILURE);
    }
    strncpy(TS[cantidad].id, s, LARGO_ID);
    TS[cantidad].id[LARGO_ID] = '\0';
    TS[cantidad].valor = v;
    cantidad++;
}

static int es_numero(char* s) {
    int i = (s[0] == '-') ? 1 : 0;
    if (s[i] == '\0') return 0;
    for (; s[i] != '\0'; i++)
        if (!isdigit((unsigned char)s[i])) return 0;
    return 1;
}

void cargar_entradas(char* id) {
    char temp[32];
    printf("Ingresa el valor de %s: ", id);
    if (scanf("%31s", temp) != 1 || !es_numero(temp)) {
        printf("Error: el valor ingresado para '%s' no es un numero entero\n", id);
        exit(EXIT_FAILURE);
    }
    escribir_tabla(id, atoi(temp));
}
