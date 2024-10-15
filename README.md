### Este repositorio es un ejercicio de un analizador léxico escrito en Flex, es una de las prácticas de la asignatura de Procesadores del Lenguaje de la Universidad de Burgos.

El enunciado de la práctica fue: 
Usando flex crear un programa para procesar diagramas UML en la 
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

> [!TIP]
> Es más fácil añadir la entrada mediante fichero que por medio de la entrada estándar (teclado).

> [!CAUTION]
> Este código solo funciona si tienes instalado flex y un compilador de C como gcc.

Hemos añadido alguna entrada de ejemplo para probarlas, de todos modos se puede ir a la web citada al principio y probar otros diagramas UML.
