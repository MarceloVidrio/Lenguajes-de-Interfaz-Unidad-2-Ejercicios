; Materia: Lenguajes de Interfaz - Unidad 2
; Nombre: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
; Practica: Hola mundo

INCLUDE Irvine32.inc

.data
mensaje BYTE "Hola mundo",0

.code
main PROC
; EDX apunta a una cadena terminada en cero.
    mov edx, OFFSET mensaje
    ; Muestra el saludo en pantalla usando la direccion guardada en EDX.
    call WriteString
    ; Agrega un salto de linea despues del saludo.
    call Crlf
    exit
main ENDP


END main
