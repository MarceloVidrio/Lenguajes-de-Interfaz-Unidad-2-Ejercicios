; Materia: Lenguajes de Interfaz - Unidad 2
; Nombre: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
; Practica: 13. String hexadecimal


INCLUDE Irvine32.inc

.data
valor DWORD 2AB34CD0h
bufferHex BYTE 9 DUP(0)

.code
main PROC
    ; Prepara ocho digitos hexadecimales y comienza por la ultima posicion.
mov eax, valor
    mov esi, 7
    mov ecx, 8
ConvertirHex:
    ; Extraer el nibble inferior sin destruir el numero restante.
    mov ebx, eax
    and ebx, 0Fh
    ; Distingue los valores de 0 a 9 de los valores de 10 a 15.
    cmp ebx, 10
    jb EsNumero
    ; Ajusta los valores de 10 a 15 para obtener las letras A a F al sumar ASCII cero.
    add ebx, 7
EsNumero:
    add ebx, '0'
    mov bufferHex[esi], bl
    ; Descarta el grupo de cuatro bits ya convertido y continua con el siguiente.
    shr eax, 4
    dec esi
    loop ConvertirHex
    ; Termina la cadena con cero y la muestra en pantalla.
    mov bufferHex[8], 0
    mov edx, OFFSET bufferHex
    call WriteString
    call Crlf
    exit
main ENDP


END main
