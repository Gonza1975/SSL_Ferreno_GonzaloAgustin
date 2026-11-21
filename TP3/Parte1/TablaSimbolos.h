#ifndef TABLA_DE_SIMBOLOS
#define TABLA_DE_SIMBOLOS

#define TAMANIO_TABLA 100
#define LARGO_ID 32

typedef struct {
    char id[LARGO_ID + 1];
    int valor;
} SIMBOLO;

void iniciar_tabla(void);
int indice_tabla(char* s);
int valor_simbolo(char* s);
void cargar_entradas(char* id);
void escribir_tabla(char* s, int v);

#endif
