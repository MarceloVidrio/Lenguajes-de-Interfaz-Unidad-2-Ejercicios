; Materia: Lenguajes de Interfaz - Unidad 2
; Nombre: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
; Practica: 5. Condicionales


INCLUDE Irvine32.inc

.data
msgInicio BYTE "Condicion al inicio (1 a 10):",0
msgFinal BYTE "Condicion al final (1 a 10):",0
contador DWORD ?

.code
main PROC
    ; Anuncia el ciclo que revisa la condicion antes de imprimir.
mov edx, OFFSET msgInicio
    call WriteString
    call Crlf
    mov contador, 1
    ; Mientras el contador no supere 10, imprime y aumenta su valor.
Mientras:
    cmp contador, 10
    ja SegundoCiclo
    mov eax, contador
    call WriteDec
    call Crlf
    inc contador
    jmp Mientras
    ; Reinicia el contador para mostrar el ciclo con condicion al final.
SegundoCiclo:
    mov edx, OFFSET msgFinal
    call WriteString
    call Crlf
    mov contador, 1
    ; Imprime primero; despues aumenta y comprueba si debe repetir.
Repetir:
    mov eax, contador
    call WriteDec
    call Crlf
    inc contador
    cmp contador, 10
    jbe Repetir
    exit
main ENDP


END main
