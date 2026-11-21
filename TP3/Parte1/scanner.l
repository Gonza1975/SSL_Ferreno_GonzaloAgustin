%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

extern int yylexerrs;
%}

%option noyywrap
%option yylineno

DIGITO              [0-9]
LETRA               [a-zA-Z]
IDENTIFICADOR       {LETRA}({LETRA}|{DIGITO})*
CONSTANTE_ENTERA    {DIGITO}+

%%

"inicio"            { return INICIO; }
"fin"               { return FIN; }
"leer"              { return LEER; }
"escribir"          { return ESCRIBIR; }
{IDENTIFICADOR}     {
                        if (yyleng > 32) {
                            yylexerrs++;
                            printf("Error lexico en linea %d: el identificador '%s' supera los 32 caracteres\n", yylineno, yytext);
                            yytext[32] = '\0';
                        }
                        yylval.identificador = strdup(yytext);
                        return ID;
                    }
{CONSTANTE_ENTERA}  { yylval.constante = atoi(yytext); return CONSTANTE; }
"+"                 { return MAS; }
"-"                 { return MENOS; }
":="                { return ASIGNACION; }
"("                 { return PARENTESISIZQ; }
")"                 { return PARENTESISDER; }
","                 { return COMA; }
";"                 { return PUNTOCOMA; }
[ \t\n\r]+          { ; }
.                   {
                        yylexerrs++;
                        printf("Error lexico en linea %d: caracter '%s' no reconocido\n", yylineno, yytext);
                    }

%%
