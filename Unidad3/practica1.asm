;Materia: Lenguajes de Interfaz
;Alumno: Marcelo Vidrio Ochoa
;Horario: 8:00 AM - 9:00 AM
;Docente: Dr. José Luis Medina Jiménez
;Práctica: PRACTICA 1.
;Descripción: Uso de procedimientos (CALL/RET) para modularizar y reutilizar codigo.
;             Se llama dos veces al mismo procedimiento y se demuestra que, al
;             terminar cada llamada, el programa continua justo despues del CALL.

INCLUDE Irvine32.inc

.data
    msgInicio   BYTE "=== Practica 1: Procedimientos ===",0
    msgAviso    BYTE ">> Estoy dentro del procedimiento MostrarAviso",0
    msgRegreso  BYTE "<< Regrese a main. Valor actual de EAX: ",0
    msgFin      BYTE "Fin del programa.",0

.code
main PROC
    ; Mensaje de inicio
    mov  edx, OFFSET msgInicio
    call WriteString
    call Crlf

    ; Primera llamada: CALL guarda en la pila la direccion de la
    ; siguiente instruccion y salta al procedimiento
    call MostrarAviso
    mov  eax, 10                ; esta linea se ejecuta al volver del RET
    call MostrarRegreso         ; muestra EAX para comprobar que seguimos en main

    ; Segunda llamada al MISMO procedimiento (reutilizacion de codigo)
    call MostrarAviso
    mov  eax, 20
    call MostrarRegreso

    ; Mensaje final
    mov  edx, OFFSET msgFin
    call WriteString
    call Crlf

    exit
main ENDP

;---------------------------------------------------------------
; MostrarAviso
; Imprime un mensaje indicando que se entro al procedimiento.
; Recibe: nada        Regresa: nada
;---------------------------------------------------------------
MostrarAviso PROC
    push edx                    ; respaldo EDX para no alterar a quien llama
    mov  edx, OFFSET msgAviso
    call WriteString
    call Crlf
    pop  edx                    ; restauro EDX
    ret                         ; saca la direccion de retorno de la pila -> EIP
MostrarAviso ENDP

;---------------------------------------------------------------
; MostrarRegreso
; Imprime un texto seguido del valor de EAX en decimal.
; Recibe: EAX = valor a mostrar     Regresa: nada
;---------------------------------------------------------------
MostrarRegreso PROC
    push edx
    mov  edx, OFFSET msgRegreso
    call WriteString
    call WriteDec               ; imprime EAX como entero sin signo
    call Crlf
    pop  edx
    ret
MostrarRegreso ENDP

END main
