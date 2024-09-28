%{
    /*Usando flex crear un programa para procesar diagramas UML en la 
sintaxis de https://nomnoml.com/

Realizando las operaciones necesarias para que al finalizar el 
procesado permita mostrar las siguientes estadísticas:
- el número de paquetes
- el número de relaciones/asociaciones (las notas no cuentan)
- el nombre de la clase con mayor número de atributos miembro
- el método que más argumentos tiene

Sólo debe tratar diagramas de clases y paquetes, los demás 
diagramas (componentes, flujo...) deberán ser ignorados así como
los comentarios en línea (precedidos de //).

Se valorará el uso de definiciones regulares, correcto uso de
las expresiones regulares, calidad del código, etc.

El analizador debe ser capaz de analizar tanto la entrada estándar 
como un fichero de texto que reciba como argumento.

------------------------------------------------------------------

Ante una entrada como la siguiente.

[<package> Modelo | 
[Tablero | -matriz : Celda | + Tablero (filas: int, columnas: int) ; + toString() ] -> 
[Celda | | + Celda( coordenada : Coordenada) ] -> [ 
Pieza | | +Pieza (color:Color)]->[Color]
[Jugador|nombre:String|Jugador(nombre:String,color:Color)]->[Color||]
[Celda] -> [Coordenada] ]

Debería dar:
- Existe/n 1 paquete/s.
- Hay 5 relaciones entre elementos.
- La clase Tablero tiene 1 atributos.
- El método Tablero tiene 2 parámetros.



Ante una entrada como la siguiente.

// Los comentarios son en línea y no deben ser considerados

[<actor> Administrador] gestiona -> [Pedido]
[<actor id=client> Cliente] 
[client] crea -> [Pedido] <:-- [Online|dirección: String; CP: Integer]
[Pedido|fecha: Date| añadir(producto, cantidad);+eliminar ( producto )] <:-- [Presencial]
[Pedido] +- [Línea|-producto]
[Pedido] -- [Tener en cuenta todos los posibles tipos de asociación]

Debería dar:
- Existe/n 0 paquete/s.
- Hay 5  relaciones entre elementos.
- La clase Online tiene 2 atributos.
- El método añadir tiene 2 parámetros.
*/
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#define CP(from, to) {free(from); from = strdup(to);}

int packages = 0, relaciones = 0;

char *claseEstudio;
int atributosEstudio=0;

char *nombreClase;
int claseAtributos=0;

char *metodoEstudio;
int parametrosEstudio=0;

char *nombreMetodo;
int metodoParametros=0;

char** ignoradosList = NULL;
int ignorados=0;
int clasesEncontradas = 0;

%}
sp[\ \t]*
spn[\ \t\n]*
arrow "-"|"->"|"<->"|"-->"|"<-->"|"-:>"|"--:>"|"+-"|"\+->"|"o-"|"o->"|"->o"|"-o)"|"o<-)"|"<-"|"<--"|"<:-"|"<:--"|"-+"|"<-\+"|"-o"|"<-o"|"o<-"|"o)-<"|"o(-"
word [A-Za-z0-9]+
words [A-Za-z0-9\ ]+
simbolo [\+]

%x CLASS ATRS OPS NOPS DESC IGN
%%

<INITIAL>"[" {yyless(1);BEGIN(CLASS);};
<INITIAL>"--"{sp}\[{words}\] {};
<INITIAL>{arrow} {relaciones++;};
<CLASS>< {BEGIN(DESC);};
<CLASS>[^\|\]\<\>]+ {CP(claseEstudio, yytext);};
<CLASS>"|" BEGIN(ATRS);
<CLASS>"]" BEGIN(INITIAL);
<DESC>id= {BEGIN(IGN);};
<DESC>{sp}*[A-Za-z0-9]+\> {if (strcmp(yytext, "package>") == 0){packages++;BEGIN(INITIAL);}
                            else{BEGIN(IGN);}
                            ;};
<IGN>[A-Za-z0-9]+({sp}+)?[^\\\>\]] {
                    ignoradosList = (char**)realloc(ignoradosList, (ignorados + 1) * sizeof(char*));
                    ignoradosList[ignorados] = (char*)malloc((strlen(yytext) + 1) * sizeof(char));
                    strcpy(ignoradosList[ignorados], yytext);
                    ignorados++;
                    BEGIN(INITIAL);};
<ATRS>{word}\:{sp}{word}[^\;\]\|] {atributosEstudio++;};
<ATRS>"|" BEGIN(OPS);
<ATRS>"]" BEGIN(INITIAL); //TODO añadir codigo c
<OPS>{sp}{simbolo}?{word}(({sp}{word})+)?[^\(\)\ ] {CP(metodoEstudio, yytext);BEGIN(NOPS);};
<NOPS>\; {BEGIN(OPS);};
<NOPS>"]" BEGIN(INITIAL);//TODO añadir codigo c
<NOPS>\(?({sp}?{word})*[^\,\)] {metodoParametros++;};
<*>^"//".*\n;
<*>.\n;

%%
/* 
bool comprobarIgnorable() {
for (int i = 0; i < ignorados; i++)
{
    if (strcmp(yytext, ignoradosList[i]) == 0 and ignoradosList[i] not in clases or metodo)
    {
        return true;
    }
}
return false;
}

String claseConMasAtributos()
{
    int max = 0;
    String clase = "";
    for (int i = 0; i < clasesEncontradas; i++)
    {
        if (clases[i].atributos > max)
        {
            max = clases[i].atributos;
            clase = clases[i].nombre;
        }
    }
    return clase;
}

int numAtributos() :
{
    int max = 0;
    for (int i = 0; i < clasesEncontradas; i++)
    {
        if (clases[i].atributos > max)
        {
            max = clases[i].atributos;
        }
    }
    return max;
}

String metodoConMasParametros()
{
    int max = 0;
    String metodo = "";
    for (int i = 0; i < clasesEncontradas; i++)
    {
        if (metodo[i].parametros > max)
        {
            max = metodo[i].parametros;
            metodo = metodo[i].nombre;
        }
    }
    return metodo;
} */

int main(int argc, char** argv) {
    ignoradosList = (char**)realloc(ignoradosList, (1) * sizeof(char*));
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            fprintf(stderr, "No se pudo abrir el archivo: %s\n", argv[1]);
            exit(1);
        }
        yyin = file;
        yylex();
        fclose(file);
    } else {
        yylex();
    }
    printf("\nPalabras ignoradas:\n");
    for (int i = 0; i < ignorados; i++) {
        printf("%s\n", ignoradosList[i]);
        free(ignoradosList[i]);
    }
    printf("\nExiste/n %d paquete/s.\n", packages);
    printf("Hay %d relaciones entre elementos.\n", relaciones);
    return 0;
}