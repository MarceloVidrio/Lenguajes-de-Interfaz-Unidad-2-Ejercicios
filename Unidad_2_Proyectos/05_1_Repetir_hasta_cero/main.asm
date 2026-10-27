; Materia: Lenguajes de Interfaz - Unidad 2
; Nombre: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
; Practica: 5.1. Repetir hasta ingresar 0


INCLUDE Irvine32.inc

.data
pregunta BYTE "Ingresa un entero (0 termina): ",0
mensaje BYTE "Valor recibido: ",0
errorMsg BYTE "Entero invalido.",0
finMsg BYTE "Fin del ciclo.",0
numero SDWORD ?

.code
main PROC
    ; Solicita un entero en cada vuelta del ciclo.
Pedir:
    mov edx, OFFSET pregunta
    call WriteString
    call ReadInt
    jo ErrorEntrada
    ; Comprueba si el entero es cero para terminar la captura.
    test eax, eax
    jz Terminar
    ; Guarda el entero antes de mostrarlo con WriteInt.
    mov numero, eax
    mov edx, OFFSET mensaje
    call WriteString
    mov eax, numero
    call WriteInt
    call Crlf
    jmp Pedir
    ; Informa el error y repite la solicitud de un entero valido.
ErrorEntrada:
    mov edx, OFFSET errorMsg
    call WriteString
    call Crlf
    jmp Pedir
    ; Muestra el aviso de cierre al recibir cero.
Terminar:
    mov edx, OFFSET finMsg
    call WriteString
    call Crlf
    exit
main ENDP


END main
