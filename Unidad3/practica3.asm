;Materia: Lenguajes de Interfaz
;Alumno: Marcelo Vidrio Ochoa
;Horario: 8:00 AM - 9:00 AM
;Docente: Dr. José Luis Medina Jiménez
;Práctica: PRACTICA 3.
;Descripción: Solicita una cadena al usuario y valida si esta vacia o no.
;             El programa esta dividido en tres procedimientos:
;             PedirCadena, ValidarCadena y MostrarResultado.

INCLUDE Irvine32.inc

.data
    cadena      BYTE 51 DUP(0)      ; hasta 50 caracteres + el 0 final
    msgTitulo   BYTE "=== Practica 3: Validacion de cadenas ===",0
    msgPedir    BYTE "Escribe una cadena (Enter para dejarla vacia): ",0
    msgLong     BYTE "Caracteres capturados: ",0
    msgVacia    BYTE "Resultado: la cadena ESTA vacia.",0
    msgNoVacia  BYTE "Resultado: la cadena NO esta vacia.",0

.code
main PROC
    mov  edx, OFFSET msgTitulo
    call WriteString
    call Crlf

    call PedirCadena            ; lee la cadena del teclado
    call ValidarCadena          ; EAX = 1 si esta vacia, 0 si no
    call MostrarResultado       ; imprime el mensaje segun EAX

    exit
main ENDP

;---------------------------------------------------------------
; PedirCadena
; Pide la cadena, la guarda en 'cadena' y muestra cuantos
; caracteres se capturaron.
; Regresa: EAX = numero de caracteres leidos
;---------------------------------------------------------------
PedirCadena PROC
    mov  edx, OFFSET msgPedir
    call WriteString

    mov  edx, OFFSET cadena         ; donde se guarda el texto
    mov  ecx, SIZEOF cadena - 1     ; maximo de caracteres (deja lugar al 0)
    call ReadString                 ; EAX = cantidad de caracteres leidos

    push eax                        ; respaldo la longitud
    mov  edx, OFFSET msgLong
    call WriteString
    call WriteDec                   ; imprime EAX
    call Crlf
    pop  eax
    ret
PedirCadena ENDP

;---------------------------------------------------------------
; ValidarCadena
; Revisa el primer byte de 'cadena': si es 0 (terminador nulo)
; significa que el usuario no escribio nada.
; Regresa: EAX = 1 si esta vacia, EAX = 0 si tiene texto
;---------------------------------------------------------------
ValidarCadena PROC
    mov  eax, 0                     ; por defecto: NO vacia
    cmp  BYTE PTR cadena, 0         ; primer caracter = 0 ?
    jne  FinValidar                 ; si no es 0, tiene texto
    mov  eax, 1                     ; es 0 -> vacia
FinValidar:
    ret
ValidarCadena ENDP

;---------------------------------------------------------------
; MostrarResultado
; Recibe: EAX = 1 (vacia) o 0 (no vacia) e imprime el mensaje
;---------------------------------------------------------------
MostrarResultado PROC
    cmp  eax, 1
    je   CadenaVacia

    mov  edx, OFFSET msgNoVacia
    jmp  Imprimir

CadenaVacia:
    mov  edx, OFFSET msgVacia

Imprimir:
    call WriteString
    call Crlf
    ret
MostrarResultado ENDP

END main
