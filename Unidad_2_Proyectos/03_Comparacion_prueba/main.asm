; Materia: Lenguajes de Interfaz - Unidad 2
; Nombre: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
; Practica: 3. Comparacion y prueba

INCLUDE Irvine32.inc

.data
igual BYTE "CMP: los valores son iguales.",0
impar BYTE "TEST: el valor es impar.",0
par BYTE "TEST: el valor es par.",0
valor DWORD 10

.code
main PROC
; CMP establece ZF sin cambiar los operandos.
    mov eax, valor
    cmp eax, 10
    ; Si el valor es distinto de 10, omite el mensaje de igualdad.
    jne ProbarBit
    mov edx, OFFSET igual
    call WriteString
    call Crlf
ProbarBit:
    mov eax, valor
    ; El bit 0 distingue pares (0) de impares (1).
    test eax, 1
    ; Si el bit inferior es cero, selecciona el mensaje de numero par.
    jz EsPar
    mov edx, OFFSET impar
    jmp Mostrar
EsPar:
    mov edx, OFFSET par
    ; Imprime el mensaje elegido por la prueba de paridad.
Mostrar:
    call WriteString
    call Crlf
    exit
main ENDP


END main
