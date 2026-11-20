; Materia: Lenguajes de Interfaz - Unidad 2
; Nombre: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
; Practica: 12. Desplazamiento y rotacion


INCLUDE Irvine32.inc

.data


.code
    ; Cada caso muestra registros y banderas; WriteBin imprime EAX completo.
main PROC
; SHL: AL=00h, CF=1.
    mov eax, 0
    mov al, 128
    ; Desplaza a la izquierda: entra cero y el bit saliente pasa a CF.
    shl al, 1
    call DumpRegs
    call WriteBin
    call Crlf
    ; SHR: AL=06h, CF=1.
    mov eax, 0
    mov al, 13
    ; Desplaza a la derecha rellenando con cero el bit mas alto de AL.
    shr al, 1
    call DumpRegs
    call WriteBin
    call Crlf
    ; SAR: -8/2 -> -4 (FCh).
    mov eax, 0
    mov al, -8
    ; Desplaza a la derecha conservando el signo de los ocho bits de AL.
    sar al, 1
    call DumpRegs
    call WriteBin
    call Crlf
    ; SAR: -9 -> -5 (FBh), redondea hacia menos infinito.
    mov eax, 0
    mov al, -9
    sar al, 1
    call DumpRegs
    call WriteBin
    call Crlf
    ; SHL con constante: AL=3Ch.
    mov eax, 0
    mov al, 15
    shl al, 2
    call DumpRegs
    call WriteBin
    call Crlf
    ; SHR con CL: AL=03h.
    mov eax, 0
    mov al, 15
    ; Usa CL como cantidad variable de posiciones a desplazar.
    mov cl, 2
    shr al, cl
    call DumpRegs
    call WriteBin
    call Crlf
    ; ROL: AL=03h, CF=1.
    mov eax, 0
    mov al, 129
    ; Rota los ocho bits: el bit mas alto vuelve por el extremo inferior.
    rol al, 1
    call DumpRegs
    call WriteBin
    call Crlf
    ; ROR: AL=C0h, CF=1.
    mov eax, 0
    mov al, 129
    ; Rota a la derecha: el bit inferior vuelve por el extremo superior.
    ror al, 1
    call DumpRegs
    call WriteBin
    call Crlf
    ; RCL con CF inicial 0: AL=02h, CF=1.
    mov eax, 0
    mov al, 129
    ; Inicializa el acarreo en cero antes de la rotacion a traves de CF.
    clc
    rcl al, 1
    call DumpRegs
    call WriteBin
    call Crlf
    ; RCR con CF inicial 1: AL=C0h, CF=1.
    mov eax, 0
    mov al, 129
    ; Inicializa el acarreo en uno para introducirlo por el bit mas alto.
    stc
    rcr al, 1
    call DumpRegs
    call WriteBin
    call Crlf
    exit
main ENDP


END main
