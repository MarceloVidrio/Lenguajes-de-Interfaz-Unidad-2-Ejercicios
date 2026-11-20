; Materia: Lenguajes de Interfaz - Unidad 2
; Nombre: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
; Practica: 1. Ciclos numericos


INCLUDE Irvine32.inc

.data


.code
main PROC
    ; Inicia un contador de cinco repeticiones para mostrar del 5 al 1.
mov ecx, 5
Ciclo:
    ; Se conserva el contador durante las llamadas de salida.
    push ecx
    ; Copia el contador a EAX para imprimirlo como numero decimal.
    mov eax, ecx
    call WriteDec
    call Crlf
    pop ecx
    ; Reduce ECX en uno y repite mientras no llegue a cero.
    loop Ciclo
    exit
main ENDP


END main
