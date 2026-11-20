; Materia: Lenguajes de Interfaz - Unidad 2
; Nombre: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
; Practica: 7. Validacion de formato AAA-999


INCLUDE Irvine32.inc

.data
pregunta BYTE "Codigo (tres mayusculas, guion, tres digitos; TEC-123): ",0
msgValido BYTE "La cadena cumple con las reglas.",0
msgInvalido BYTE "La cadena no cumple con las reglas.",0
buffer BYTE 256 DUP(0)

.code
main PROC
    ; Solicita y captura el codigo que se va a validar.
mov edx, OFFSET pregunta
    call WriteString
    mov edx, OFFSET buffer
    mov ecx, SIZEOF buffer - 1
    call ReadString
    ; Exige exactamente siete caracteres para el formato AAA-999.
    cmp eax, 7
    jne Invalido
    mov esi, OFFSET buffer
    mov ecx, 3
    ; Recorre las tres primeras posiciones y exige letras de A a Z.
ValidarLetras:
    mov al, [esi]
    cmp al, 'A'
    jb Invalido
    cmp al, 'Z'
    ja Invalido
    inc esi
    loop ValidarLetras
    ; Comprueba el guion central antes de avanzar hacia los digitos.
    cmp BYTE PTR [esi], '-'
    jne Invalido
    inc esi
    mov ecx, 3
    ; Recorre las tres ultimas posiciones y exige digitos de 0 a 9.
ValidarDigitos:
    mov al, [esi]
    cmp al, '0'
    jb Invalido
    cmp al, '9'
    ja Invalido
    inc esi
    loop ValidarDigitos
    mov edx, OFFSET msgValido
    jmp Mostrar
    ; Selecciona el aviso de rechazo si falla cualquiera de las reglas.
Invalido:
    mov edx, OFFSET msgInvalido
Mostrar:
    call WriteString
    call Crlf
    exit
main ENDP


END main
