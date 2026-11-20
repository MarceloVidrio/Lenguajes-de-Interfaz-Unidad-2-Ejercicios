; Materia: Lenguajes de Interfaz - Unidad 2
; Nombre: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
; Practica: 6. Incremento y decremento: PIN


INCLUDE Irvine32.inc

.data
pregunta BYTE "Ingrese el PIN: ",0
msgError BYTE "PIN incorrecto.",0
msgIntentos BYTE "Intentos restantes: ",0
msgAcceso BYTE "Acceso permitido.",0
msgBloqueado BYTE "Acceso bloqueado.",0
intentos DWORD 3
pinCorrecto = 1234

.code
main PROC
    ; Solicita el PIN; una entrada invalida tambien consume un intento.
Intentar:
    mov edx, OFFSET pregunta
    call WriteString
    call ReadInt
    jo Incorrecto
    ; Compara la entrada con 1234 para decidir si permite el acceso.
    cmp eax, pinCorrecto
    je Acceso
Incorrecto:
    mov edx, OFFSET msgError
    call WriteString
    call Crlf
    ; DEC actualiza ZF: cero significa que no quedan intentos.
    dec intentos
    jz Bloqueado
    ; Muestra cuantos intentos quedan antes de volver a solicitar el PIN.
    mov edx, OFFSET msgIntentos
    call WriteString
    mov eax, intentos
    call WriteDec
    call Crlf
    jmp Intentar
    ; Selecciona el mensaje de acceso cuando el PIN es correcto.
Acceso:
    mov edx, OFFSET msgAcceso
    jmp Mostrar
    ; Selecciona el bloqueo cuando se agotan los tres intentos.
Bloqueado:
    mov edx, OFFSET msgBloqueado
Mostrar:
    call WriteString
    call Crlf
    ; Demostracion independiente de INC: 0 pasa a 1.
    mov eax, 0
    inc eax
    nop
    exit
main ENDP


END main
