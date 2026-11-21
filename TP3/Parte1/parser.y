%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "TablaSimbolos.h"

void yyerror(const char *s);
int yylex(void);

extern int yynerrs;
extern int yylineno;
extern FILE* yyin;
int yylexerrs = 0;
int yysemerrs = 0;
%}

%define parse.error verbose

%union {
    char* identificador;
    int constante;
}

%token INICIO "inicio"
%token FIN "fin"
%token LEER "leer"
%token ESCRIBIR "escribir"
%token PARENTESISIZQ "("
%token PARENTESISDER ")"
%token COMA "coma"
%token PUNTOCOMA ";"
%token MAS "+"
%token MENOS "-"
%token ASIGNACION ":="
%token <identificador> ID "identificador"
%token <constante> CONSTANTE "constante"

%type <constante> expresion primaria

%%

programa:
    INICIO lista_sentencias FIN                     { if (yylexerrs || yynerrs || yysemerrs) YYABORT; }
    ;

lista_sentencias:
    sentencia
    | lista_sentencias sentencia
    ;

sentencia:
    ID ASIGNACION expresion PUNTOCOMA               { escribir_tabla($1, $3); free($1); }
    | LEER PARENTESISIZQ lista_identificadores PARENTESISDER PUNTOCOMA
    | ESCRIBIR PARENTESISIZQ lista_expresiones PARENTESISDER PUNTOCOMA
    | error PUNTOCOMA                               { yyerrok; }
    ;

lista_identificadores:
    ID                                              { cargar_entradas($1); free($1); }
    | lista_identificadores COMA ID                 { cargar_entradas($3); free($3); }
    ;

lista_expresiones:
    expresion                                       { printf("%d\n", $1); }
    | lista_expresiones COMA expresion              { printf("%d\n", $3); }
    ;

expresion:
    primaria                                        { $$ = $1; }
    | expresion MAS primaria                        { $$ = $1 + $3; }
    | expresion MENOS primaria                      { $$ = $1 - $3; }
    ;

primaria:
    ID                                              { $$ = valor_simbolo($1); free($1); }
    | CONSTANTE                                     { $$ = $1; }
    | PARENTESISIZQ expresion PARENTESISDER         { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    const char* original[] = {"syntax error, ", "syntax error", "unexpected ", "expecting ", " or ", "end of file"};
    const char* traduccion[] = {"", "estructura invalida", "se encontro ", "se esperaba ", " o ", "fin de archivo"};
    char mensaje[256] = "";
    const char* p = s;
    while (*p && strlen(mensaje) < sizeof(mensaje) - 20) {
        int reemplazo = 0;
        for (int i = 0; i < 6; i++) {
            int largo = strlen(original[i]);
            if (!strncmp(p, original[i], largo)) {
                strcat(mensaje, traduccion[i]);
                p += largo;
                reemplazo = 1;
                break;
            }
        }
        if (!reemplazo) strncat(mensaje, p++, 1);
    }
    printf("Error sintactico en linea %d: %s\n", yylineno, mensaje);
}

int main(int argc, char** argv) {
    if (argc > 2) {
        printf("Cantidad incorrecta de argumentos.\n");
        return EXIT_FAILURE;
    }
    if (argc == 2) {
        int largo = strlen(argv[1]);
        if (largo < 3 || strcmp(argv[1] + largo - 2, ".m") != 0) {
            printf("Extension incorrecta: el archivo debe terminar en .m\n");
            return EXIT_FAILURE;
        }
        yyin = fopen(argv[1], "r");
        if (yyin == NULL) {
            printf("No se pudo abrir el archivo '%s'\n", argv[1]);
            return EXIT_FAILURE;
        }
    }
    else
        yyin = stdin;

    iniciar_tabla();

    switch (yyparse()) {
        case 0: printf("\nCompilacion exitosa\n"); break;
        case 1: printf("\nErrores de compilacion\n"); break;
        case 2: printf("\nMemoria insuficiente\n"); break;
    }
    printf("\nErrores lexicos: %d\tErrores sintacticos: %d\tErrores semanticos: %d\n", yylexerrs, yynerrs, yysemerrs);

    if (yyin != stdin) fclose(yyin);
    return 0;
}
