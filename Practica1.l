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
#include <stdlib.h>
#include <stdio.h>
#define CP(from, to) {free(from); from = strdup(to);}
int packages = 0, relaciones=0;
typedef struct { //struct para almacenar cada clase junto sus datos relacionados necesarios
    char nombre[100];
    int atributos;
    int parametros;
} Clase;
Clase clases[10];
int clasesEncontradas = 0;


void process_file(const char* filename);
void gaurdarClassData();

%}
sp[\ \t]*
spn[\ \t\n]*
arrow "-->"|"<->"|"o<->"|"o->"|"->o"|"o--"|"o-"|"->"|"--"|"-"|"o<-"
%x CLASS ATRS OPS
%%
<INITIAL>"["[^<] BEGIN(CLASS){clasesEncontradas++};
<INITIAL>"["{sp}"<package>" {packages++;};
<INITIAL>{arrow} {relaciones++;};
<CLASS>[^"|"]* {CP(clases[clasesEncontradas-1].nombre, yytext);};
<CLASS> "|" BEGIN(ATRS);
<CLASS>"]" BEGIN(INITIAL);
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
    yylex();
    fclose(file);
}

void gaurdarClassData(){

}

int main(int argc, char **argv) {
    if (argc > 1) {
        process_file(argv[1]);
    } else {
        yylex();
    }

    printf("\nExiste/n %d paquete/s.\n", packages);
    printf("Hay %d relaciones entre elementos.\n", relaciones);
    return 0;
}