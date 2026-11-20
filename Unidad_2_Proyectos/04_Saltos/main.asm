; Materia: Lenguajes de Interfaz - Unidad 2
; Nombre: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
; Practica: 4. Saltos


INCLUDE Irvine32.inc

.data
msgIguales BYTE "Los valores son iguales.",0
msgDistintos BYTE "Los valores son diferentes.",0

.code
main PROC
    ; Carga dos valores de ejemplo para comparar su igualdad.
mov eax, 10
    mov ebx, 10
    cmp eax, ebx
    ; Salta al mensaje de igualdad cuando CMP deja ZF en uno.
    je Iguales
    mov edx, OFFSET msgDistintos
    ; Evita pasar por el mensaje de igualdad si los valores difieren.
    jmp Mostrar
Iguales:
    mov edx, OFFSET msgIguales
    ; Muestra el texto seleccionado y termina el programa.
Mostrar:
    call WriteString
    call Crlf
    exit
main ENDP


END main
