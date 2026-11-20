;Materia: Lenguajes de Interfaz
;Alumno: Marcelo Vidrio Ochoa
;Horario: 8:00 AM - 9:00 AM
;Docente: Dr. José Luis Medina Jiménez
;Práctica: PRACTICA 2.
;Descripción: Funcionamiento de la pila (stack) y de las direcciones de retorno.
;             En cada nivel (main -> ProcUno -> ProcDos) se lee la cima de la pila
;             con [ESP] y se muestra tambien el valor de ESP, para ver como cada
;             CALL empuja 4 bytes (la direccion de retorno) y cada RET los saca.

INCLUDE Irvine32.inc

.data
    msgTitulo    BYTE "=== Practica 2: Pila y direcciones de retorno ===",0
    msgEsperada  BYTE "Direccion de la instruccion despues de CALL ProcUno: ",0
    msgMain      BYTE "[main]    cima [ESP] = ",0
    msgUno       BYTE "[ProcUno] cima [ESP] = ",0
    msgDos       BYTE "[ProcDos] cima [ESP] = ",0
    msgEsp       BYTE "   ESP = ",0
    msgVuelta    BYTE "[main]    de regreso, ESP = ",0

.code
main PROC
    mov  edx, OFFSET msgTitulo
    call WriteString
    call Crlf

    ; Muestro a que direccion DEBERIA regresar ProcUno
    mov  edx, OFFSET msgEsperada
    call WriteString
    mov  eax, OFFSET RegresoMain
    call WriteHex
    call Crlf

    ; Cima de la pila en main (direccion de retorno hacia el sistema)
    mov  edx, OFFSET msgMain
    call WriteString
    mov  eax, [esp]
    call WriteHex
    mov  edx, OFFSET msgEsp
    call WriteString
    mov  eax, esp
    call WriteHex
    call Crlf

    call ProcUno                ; empuja la direccion de RegresoMain
RegresoMain:
    ; Al volver, ESP debe ser igual al que se mostro en main
    mov  edx, OFFSET msgVuelta
    call WriteString
    mov  eax, esp
    call WriteHex
    call Crlf

    exit
main ENDP

;---------------------------------------------------------------
; ProcUno: muestra la direccion de retorno hacia main y llama a ProcDos
;---------------------------------------------------------------
ProcUno PROC
    mov  edx, OFFSET msgUno
    call WriteString
    mov  eax, [esp]             ; debe coincidir con OFFSET RegresoMain
    call WriteHex
    mov  edx, OFFSET msgEsp
    call WriteString
    mov  eax, esp               ; ESP bajo 4 bytes respecto a main
    call WriteHex
    call Crlf

    call ProcDos                ; empuja otra direccion de retorno
    ret                         ; regresa a main
ProcUno ENDP

;---------------------------------------------------------------
; ProcDos: muestra la direccion de retorno hacia ProcUno
;---------------------------------------------------------------
ProcDos PROC
    mov  edx, OFFSET msgDos
    call WriteString
    mov  eax, [esp]             ; direccion dentro de ProcUno (despues del CALL)
    call WriteHex
    mov  edx, OFFSET msgEsp
    call WriteString
    mov  eax, esp               ; ESP bajo otros 4 bytes
    call WriteHex
    call Crlf
    ret                         ; regresa a ProcUno
ProcDos ENDP

END main
