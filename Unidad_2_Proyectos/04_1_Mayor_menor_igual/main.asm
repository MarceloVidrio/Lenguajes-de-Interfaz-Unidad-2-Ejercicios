; Materia: Lenguajes de Interfaz - Unidad 2
; Nombre: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
; Practica: 4.1. Mayor, menor o igual con entrada del usuario


INCLUDE Irvine32.inc

.data
p1 BYTE "Primer entero con signo: ",0
p2 BYTE "Segundo entero con signo: ",0
msgMayor BYTE "El primero es mayor.",0
msgMenor BYTE "El primero es menor.",0
msgIgual BYTE "Son iguales.",0
msgError BYTE "Entrada invalida para un entero de 32 bits.",0
primero SDWORD ?

.code
main PROC
    ; Captura el primer entero; si ReadInt activa OF, pide corregirlo.
PedirPrimero:
    mov edx, OFFSET p1
    call WriteString
    call ReadInt
    jo ErrorPrimero
    mov primero, eax
    ; Captura el segundo entero conservando el primero en memoria.
PedirSegundo:
    mov edx, OFFSET p2
    call WriteString
    call ReadInt
    jo ErrorSegundo
    ; Comparacion con signo: JG y JL, no JA y JB.
    cmp primero, eax
    jg Mayor
    jl Menor
    ; Si no es mayor ni menor, ambos enteros son iguales.
    mov edx, OFFSET msgIgual
    jmp Mostrar
Mayor:
    mov edx, OFFSET msgMayor
    jmp Mostrar
Menor:
    mov edx, OFFSET msgMenor
Mostrar:
    call WriteString
    call Crlf
    jmp Fin
    ; Notifica la entrada invalida y vuelve a pedir el primer entero.
ErrorPrimero:
    mov edx, OFFSET msgError
    call WriteString
    call Crlf
    jmp PedirPrimero
    ; Vuelve a pedir solo el segundo entero cuando su captura falla.
ErrorSegundo:
    mov edx, OFFSET msgError
    call WriteString
    call Crlf
    jmp PedirSegundo
Fin:
    exit
main ENDP


END main
