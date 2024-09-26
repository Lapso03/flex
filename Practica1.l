%{
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

int packages = 0, relaciones = 0;

typedef struct {
    char nombre[100];
    int atributos;
} Clase;

typedef struct {
    char nombre[100];
    int parametros;
} Metodo;

Clase clases[10];
Metodo metodo[10];
int clasesEncontradas = 0;

#define MAX_IGNORE_WORDS 100
char* ignoreWords[MAX_IGNORE_WORDS];
int ignoreWordsCount = 0;

void process_file(const char* filename);
void add_ignore_word(const char* word);
bool is_ignore_word(const char* word);

%}
sp[\ \t]*
spn[\ \t\n]*
arrow "-->"|"<->"|"o<->"|"o->"|"->o"|"o--"|"o-"|"->"|"--"|"-"|"o<-"
%x CLASS ATRS OPS DESC
%%

<INITIAL>"[" {yyless(1);BEGIN(CLASS);};
<INITIAL>{arrow} {relaciones++;};
<CLASS>< {yyless(1);BEGIN(DESC);};
<CLASS>[^\|\]\<\>]+ {strncpy(clases[clasesEncontradas - 1].nombre, yytext, sizeof(clases[clasesEncontradas - 1].nombre) - 1);};
<CLASS>"|" BEGIN(ATRS);
<CLASS>"]" BEGIN(INITIAL);
<DESC>{sp}\<[A-Za-z0-9]+\> {//TODO añadir if package se suma uno a package};
<DESC>^[a-zA-Z0-9]+ {
    if (!is_ignore_word(yytext)) {
        // Procesar la palabra si no está en la lista de palabras a ignorar
    }
}
<DESC>\||\] BEGIN(CLASS);
<ATRS>[^\|\]]+: {clases[clasesEncontradas - 1].atributos++;};
<ATRS>"|" BEGIN(OPS);
<ATRS>"]" BEGIN(INITIAL);
<OPS>"}" BEGIN(INITIAL);
<*>^"//".*\n;
<*>.\n;

%%

void process_file(const char* filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        fprintf(stderr, "No se pudo abrir el archivo: %s\n", filename);
        exit(1);
    }
    yyin = file;
}

void add_ignore_word(const char* word) {
    if (ignoreWordsCount < MAX_IGNORE_WORDS) {
        ignoreWords[ignoreWordsCount] = strdup(word);
        ignoreWordsCount++;
    } else {
        fprintf(stderr, "Se ha alcanzado el número máximo de palabras a ignorar.\n");
    }
}

bool is_ignore_word(const char* word) {
    for (int i = 0; i < ignoreWordsCount; i++) {
        if (strcmp(ignoreWords[i], word) == 0) {
            return true;
        }
    }
    return false;
}

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <archivo> [palabras a ignorar...]\n", argv[0]);
        return 1;
    }

    for (int i = 2; i < argc; i++) {
        add_ignore_word(argv[i]);
    }

    process_file(argv[1]);
    yylex();

    for (int i = 0; i < ignoreWordsCount; i++) {
        free(ignoreWords[i]);
    }

    return 0;
}