;Materia: Lenguajes de Interfaz
;Alumno: Marcelo Vidrio Ochoa
;Horario: 8:00 AM - 9:00 AM
;Docente: Dr. José Luis Medina Jiménez
;Práctica: PRACTICA 5.
;Descripción: Uso de macros para encapsular y reutilizar bloques de codigo.
;             A diferencia de un procedimiento (que se llama con CALL), una macro
;             se EXPANDE: el ensamblador copia su codigo en cada lugar donde se usa.

INCLUDE Irvine32.inc

;---------------------------------------------------------------
; MostrarMensaje texto
; Imprime la cadena 'texto' y un salto de linea. Preserva EDX.
;---------------------------------------------------------------
MostrarMensaje MACRO texto
    push edx
    mov  edx, OFFSET texto
    call WriteString
    call Crlf
    pop  edx
ENDM

;---------------------------------------------------------------
; Multiplicar num1, num2
; Deja en EAX el producto con signo de num1 * num2.
; num1 y num2 pueden ser constantes o variables DWORD.
;---------------------------------------------------------------
Multiplicar MACRO num1, num2
    mov  eax, num1
    imul eax, num2
ENDM

;---------------------------------------------------------------
; ImprimirResultado etiqueta
; Imprime el texto 'etiqueta' seguido del valor de EAX con signo.
;---------------------------------------------------------------
ImprimirResultado MACRO etiqueta
    push edx
    mov  edx, OFFSET etiqueta
    call WriteString
    call WriteInt
    call Crlf
    pop  edx
ENDM

.data
    msgBienvenida BYTE "=== Practica 5: Macros ===",0
    msgOp1        BYTE "4 x 5   = ",0
    msgOp2        BYTE "12 x -3 = ",0
    msgOp3        BYTE "valorX x valorY = ",0
    msgFin        BYTE "Fin del programa. Nos vemos!",0
    valorX        SDWORD 9
    valorY        SDWORD 8

.code
main PROC
    MostrarMensaje msgBienvenida

    ; Misma macro usada con distintos argumentos
    Multiplicar 4, 5                ; constantes
    ImprimirResultado msgOp1

    Multiplicar 12, -3              ; numero negativo
    ImprimirResultado msgOp2

    Multiplicar valorX, valorY      ; variables en memoria
    ImprimirResultado msgOp3

    MostrarMensaje msgFin

    exit                            ; termina el programa correctamente
main ENDP

END main
