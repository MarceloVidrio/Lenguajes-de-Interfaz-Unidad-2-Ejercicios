; Materia: Lenguajes de Interfaz - Unidad 2
; Nombre: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
; Practica: 11. Operaciones logicas


INCLUDE Irvine32.inc

.data
msgActivo BYTE "TEST: equipo encendido; el estado sigue en 05h.",0

.code
    ; Cada mascara modifica o consulta bits concretos del estado inicial 05h.
main PROC
; Bits: 0=encendido, 1=alarma, 2=conectado.
    ; AND: extrae encendido: BL=01h.
    mov eax, 5
    mov ebx, eax
    and bl, 00000001b
    call DumpRegs
    ; OR: activa alarma, AL=07h.
    mov eax, 5
    or al, 00000010b
    call DumpRegs
    ; XOR: alterna conectado, AL=01h.
    mov eax, 5
    xor al, 00000100b
    call DumpRegs
    ; NOT: invierte los ocho bits de AL, resultado FAh.
    mov eax, 5
    not al
    call DumpRegs
    ; AND: apaga conectado y conserva los otros bits, AL=01h.
    mov eax, 5
    and al, 11111011b
    call DumpRegs
    ; TEST consulta sin modificar AL=05h.
    mov eax, 5
    test al, 00000001b
    ; Omite el mensaje si el bit de encendido no esta activo.
    jz Fin
    mov edx, OFFSET msgActivo
    call WriteString
    call Crlf
Fin:
    exit
main ENDP


END main
