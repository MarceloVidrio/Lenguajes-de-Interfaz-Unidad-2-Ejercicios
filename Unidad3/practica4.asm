;Materia: Lenguajes de Interfaz
;Alumno: Marcelo Vidrio Ochoa
;Horario: 8:00 AM - 9:00 AM
;Docente: Dr. José Luis Medina Jiménez
;Práctica: PRACTICA 4.
;Descripción: Paso de parametros a un procedimiento por medio de la pila y
;             multiplicacion con signo usando la instruccion IMUL.
;             Tambien se demuestra que el procedimiento respeta (preserva) EBX.

INCLUDE Irvine32.inc

.data
    valorA      SDWORD 7
    valorB      SDWORD -6
    msgTitulo   BYTE "=== Practica 4: Parametros por la pila ===",0
    msgA        BYTE "Primer valor    : ",0
    msgB        BYTE "Segundo valor   : ",0
    msgRes      BYTE "Producto (IMUL) : ",0
    msgEbx      BYTE "EBX despues de la llamada (debe seguir en 10): ",0

.code
main PROC
    mov  edx, OFFSET msgTitulo
    call WriteString
    call Crlf

    mov  ebx, 10                ; valor que el procedimiento NO debe perder

    ; Muestro los valores que se van a multiplicar
    mov  edx, OFFSET msgA
    call WriteString
    mov  eax, valorA
    call WriteInt
    call Crlf

    mov  edx, OFFSET msgB
    call WriteString
    mov  eax, valorB
    call WriteInt
    call Crlf

    ; Paso de parametros: se empujan en la pila antes del CALL
    push valorA                 ; primer parametro  -> quedara en [EBP+12]
    push valorB                 ; segundo parametro -> quedara en [EBP+8]
    call MultiplicarPila        ; EAX = valorA * valorB

    ; Muestro el resultado
    mov  edx, OFFSET msgRes
    call WriteString
    call WriteInt               ; imprime EAX con signo
    call Crlf

    ; Compruebo que EBX no cambio
    mov  edx, OFFSET msgEbx
    call WriteString
    mov  eax, ebx
    call WriteDec
    call Crlf

    exit
main ENDP

;---------------------------------------------------------------
; MultiplicarPila
; Multiplica dos enteros con signo recibidos por la pila.
; Recibe:  [EBP+12] = primer valor, [EBP+8] = segundo valor
; Regresa: EAX = producto
;
; Estado de la pila despues de "mov ebp, esp":
;     [EBP+12]  -> valorA        (primer push)
;     [EBP+8]   -> valorB        (segundo push)
;     [EBP+4]   -> direccion de retorno (la puso CALL)
;     [EBP]     -> EBP anterior  (lo guardamos con push ebp)
;---------------------------------------------------------------
MultiplicarPila PROC
    push ebp                    ; guardo el EBP de quien llama
    mov  ebp, esp               ; EBP = marco de referencia fijo
    push ebx                    ; preservo EBX porque lo voy a usar

    mov  eax, [ebp+12]          ; EAX = valorA
    mov  ebx, [ebp+8]           ; EBX = valorB
    imul eax, ebx               ; EAX = EAX * EBX (con signo)

    pop  ebx                    ; restauro EBX (vuelve a 10)
    pop  ebp                    ; restauro EBP
    ret  8                      ; regresa y limpia los 2 parametros (2 x 4 bytes)
MultiplicarPila ENDP

END main
