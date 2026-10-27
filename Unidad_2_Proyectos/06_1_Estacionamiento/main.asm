; Materia: Lenguajes de Interfaz - Unidad 2
; Nombre: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
; Practica: 6.1. Control de ocupacion de estacionamiento


INCLUDE Irvine32.inc

.data
menu BYTE "1=Entrada, 2=Salida, 0=Terminar: ",0
msgEstado BYTE "Ocupacion actual (maximo 20): ",0
msgLleno BYTE "Estacionamiento lleno.",0
msgVacio BYTE "El estacionamiento esta vacio.",0
msgError BYTE "Opcion invalida.",0
ocupacion DWORD 0
capacidad = 20

.code
main PROC
    ; Muestra la ocupacion actual y solicita una opcion del menu.
MenuPrincipal:
    mov edx, OFFSET msgEstado
    call WriteString
    mov eax, ocupacion
    call WriteDec
    call Crlf
    mov edx, OFFSET menu
    call WriteString
    call ReadInt
    jo OpcionInvalida
    ; Dirige la opcion: cero termina, uno registra entrada y dos salida.
    cmp eax, 0
    je Fin
    cmp eax, 1
    je Entrada
    cmp eax, 2
    je Salida
OpcionInvalida:
    mov edx, OFFSET msgError
    jmp Aviso
    ; Comprueba el limite de 20 vehiculos antes de aumentar la ocupacion.
Entrada:
    cmp ocupacion, capacidad
    jae Lleno
    inc ocupacion
    jmp MenuPrincipal
    ; Comprueba que haya vehiculos antes de reducir la ocupacion.
Salida:
    cmp ocupacion, 0
    je Vacio
    dec ocupacion
    jmp MenuPrincipal
Lleno:
    mov edx, OFFSET msgLleno
    jmp Aviso
Vacio:
    mov edx, OFFSET msgVacio
    ; Muestra el aviso seleccionado y regresa al menu.
Aviso:
    call WriteString
    call Crlf
    jmp MenuPrincipal
Fin:
    exit
main ENDP


END main
