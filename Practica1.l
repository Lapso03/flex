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
- Hay 5 relaciones entre elementos.
- La clase Online tiene 2 atributos.
- El método añadir tiene 2 parámetros.
*/
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#define CP(from, to) {free(from); from = strdup(to);}

void claseConMasAtributos();
void metodoConMasParametros();

int packages = 0, relaciones = 0;

char *casoEstudio;
int numEstudio=0;

char *nombreClase;
int atributosClase=0;

char *nombreMetodo;
int parametrosMetodo=0;

%}
sp[\ \t]*
spn[\ \t\n]*
arrow "-"|"->"|"<->"|"-->"|"<-->"|"-:>"|"--:>"|"+-"|"\+->"|"o-"|"o->"|"->o"|"-o)"|"o<-)"|"<-"|"<--"|"<:-"|"<:--"|"-+"|"<-\+"|"-o"|"<-o"|"o<-"|"o)-<"|"o(-"
word [A-Za-z0-9á-ñé]+
words [A-Za-z0-9á-ñé\ ]+
wordsSimbols[A-za-z0-9á-ñé\ \+\-\*\/\%\&\|\^\!\=\<\>\~\?]+
simbolo [\+]

%x CLASS ATRS OPS NOPS DESC
%%
<INITIAL>\-\- {};
<INITIAL>"[" {yyless(1);BEGIN(CLASS);}
<INITIAL>{arrow} {relaciones++;}
<CLASS>< {BEGIN(DESC);}
<CLASS>[^\|\]\<\>]+ {CP(casoEstudio, yytext);}
<CLASS>"|" BEGIN(ATRS);
<CLASS>"]" BEGIN(INITIAL);
<DESC>{sp}*[A-Za-z0-9]+\> {if (strcmp(yytext, "package>") == 0){packages++;};BEGIN(INITIAL);}
<ATRS>{words}(\:{words})?[^\;\]\|] {numEstudio++;}
<ATRS>"|" {claseConMasAtributos();BEGIN(OPS);}
<ATRS>"]" {claseConMasAtributos();BEGIN(INITIAL);}
<OPS>{sp}"]" BEGIN(INITIAL);
<OPS>\:{sp}{wordsSimbols}+[\;\)\]] {}
<OPS>{word}+ {CP(casoEstudio, yytext);BEGIN(NOPS);}
<NOPS>")" {metodoConMasParametros();BEGIN(OPS);}
<NOPS>{words} {numEstudio++;};
<*>^"//".*\n {};
<*>.(\n)? {};

%%
void claseConMasAtributos()
{
    if (numEstudio > atributosClase)
    {
        atributosClase = numEstudio;
        nombreClase = strdup(casoEstudio);
    }
    numEstudio = 0;
}

void metodoConMasParametros()
{
    if (numEstudio > parametrosMetodo)
    {
        parametrosMetodo = numEstudio;
        nombreMetodo = strdup(casoEstudio);
    }
    numEstudio = 0;
}


int main(int argc, char** argv) {
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
    printf("\nExiste/n %d paquete/s.\n", packages);
    printf("Hay %d relaciones entre elementos.\n", relaciones);
    printf("La clase %s tiene %d atributos.\n", nombreClase, atributosClase);
    printf("El método %s tiene %d parámetros.\n", nombreMetodo , parametrosMetodo);
    return 0;
}