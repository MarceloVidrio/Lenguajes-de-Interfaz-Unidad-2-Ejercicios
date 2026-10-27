; Materia: Lenguajes de Interfaz - Unidad 2
; Nombre: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
; Practica: 2. Captura y desplegado de mensaje


INCLUDE Irvine32.inc

.data
pregunta BYTE "Escribe un mensaje (maximo 80 caracteres): ",0
salida BYTE "Mensaje capturado: ",0
buffer BYTE 81 DUP(0)

.code
main PROC
    ; Muestra la solicitud de entrada al usuario.
mov edx, OFFSET pregunta
    call WriteString
    ; Prepara el espacio donde ReadString guardara el mensaje.
    mov edx, OFFSET buffer
    ; Limita la captura a 80 caracteres y reserva el cero final.
    mov ecx, SIZEOF buffer - 1
    call ReadString
    ; Muestra la etiqueta de salida y luego el mensaje capturado.
    mov edx, OFFSET salida
    call WriteString
    mov edx, OFFSET buffer
    call WriteString
    call Crlf
    exit
main ENDP


END main
