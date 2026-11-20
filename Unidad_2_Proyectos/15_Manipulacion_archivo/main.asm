; Materia: Lenguajes de Interfaz - Unidad 2
; Nombre: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
; Practica: 15. Manipulacion de archivo


INCLUDE Irvine32.inc

.data
nombreArchivo BYTE "practica15_salida.txt",0
contenido BYTE "Lenguajes de Interfaz - Unidad 2",13,10
longitudContenido = ($ - contenido)
buffer BYTE 256 DUP(0)
handleArchivo DWORD ?
msgContenido BYTE "Contenido recuperado del archivo:",0
msgError BYTE "Error al crear, escribir, abrir, leer o cerrar el archivo.",0

.code
main PROC
; CreateOutputFile reemplaza el contenido del archivo de demostracion.
    mov edx, OFFSET nombreArchivo
    call CreateOutputFile
    cmp eax, INVALID_HANDLE_VALUE
    je ErrorSinHandle
    ; Conserva el identificador del archivo y escribe el texto preparado.
    mov handleArchivo, eax
    mov edx, OFFSET contenido
    mov ecx, longitudContenido
    call WriteToFile
    jc ErrorConHandle
    ; Comprueba que se haya escrito la cantidad completa de bytes.
    cmp eax, longitudContenido
    jne ErrorConHandle
    mov eax, handleArchivo
    call CloseFile
    test eax, eax
    jz ErrorSinHandle
    ; Abre para lectura el archivo que se acaba de escribir y cerrar.
    mov edx, OFFSET nombreArchivo
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je ErrorSinHandle
    mov handleArchivo, eax
    ; Reserva espacio para leer el contenido y dejar un cero al final.
    mov edx, OFFSET buffer
    mov ecx, SIZEOF buffer - 1
    call ReadFromFile
    jc ErrorConHandle
    ; ReadFromFile no agrega el cero final: se reserva un byte.
    mov buffer[eax], 0
    mov eax, handleArchivo
    call CloseFile
    test eax, eax
    jz ErrorSinHandle
    ; Muestra el contenido recuperado despues de cerrar el archivo.
    mov edx, OFFSET msgContenido
    call WriteString
    call Crlf
    mov edx, OFFSET buffer
    call WriteString
    jmp Fin
ErrorConHandle:
    ; Toda apertura exitosa tiene un intento de cierre.
    mov eax, handleArchivo
    call CloseFile
    ; Muestra el error sin intentar cerrar un identificador no disponible.
ErrorSinHandle:
    mov edx, OFFSET msgError
    call WriteString
    call Crlf
Fin:
    exit
main ENDP


END main
