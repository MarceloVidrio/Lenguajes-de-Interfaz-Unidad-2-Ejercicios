; Materia: Lenguajes de Interfaz - Unidad 2
; Nombre: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
; Practica: 14. Captura y almacenamiento: inventario


INCLUDE Irvine32.inc

.data
pregunta BYTE "Ingrese la cantidad recibida (1-99): ",0
errorMsg BYTE "Entrada invalida. Use uno o dos digitos con valor 1-99.",0
msgExistencia BYTE "Existencia actual: ",0
buffer BYTE 256 DUP(0)
cantidadRecibida DWORD ?
existenciaInicial DWORD 25
existenciaActual DWORD ?
outBuffer BYTE 11 DUP(0)

.code
main PROC
    ; Solicita la cantidad recibida y la captura como texto.
PedirDatos:
    mov edx, OFFSET pregunta
    call WriteString
    mov edx, OFFSET buffer
    mov ecx, SIZEOF buffer - 1
    call ReadString
    ; Acepta solo uno o dos caracteres antes de convertir la entrada.
    cmp eax, 1
    jb ErrorEntrada
    cmp eax, 2
    ja ErrorEntrada
    mov ecx, eax
    mov esi, OFFSET buffer
    xor eax, eax
    ; Verifica cada digito ASCII antes de incorporarlo al numero.
ConvertirEntrada:
    movzx ebx, BYTE PTR [esi]
    cmp ebx, '0'
    jb ErrorEntrada
    cmp ebx, '9'
    ja ErrorEntrada
    sub ebx, '0'
    ; EBX conserva el digito: MUL sobrescribiria EDX.
    ; Acumula el numero: valor anterior por diez mas el nuevo digito.
    imul eax, eax, 10
    add eax, ebx
    inc esi
    loop ConvertirEntrada
    ; Comprueba que la cantidad convertida este entre 1 y 99.
    cmp eax, 1
    jb ErrorEntrada
    cmp eax, 99
    ja ErrorEntrada
    ; Guarda la cantidad y la suma a las 25 unidades iniciales.
    mov cantidadRecibida, eax
    add eax, existenciaInicial
    mov existenciaActual, eax
    ; Convierte la existencia actual a texto y muestra el resultado.
    mov edx, OFFSET msgExistencia
    call WriteString
    mov eax, existenciaActual
    mov esi, OFFSET outBuffer
    call convertirDecimal
    mov edx, OFFSET outBuffer
    call WriteString
    call Crlf
    jmp Fin
    ; Muestra el error y solicita nuevamente la cantidad.
ErrorEntrada:
    mov edx, OFFSET errorMsg
    call WriteString
    call Crlf
    jmp PedirDatos
Fin:
    exit
main ENDP

; Entrada: EAX=DWORD sin signo, ESI=buffer de al menos 11 bytes.
; Salida: cadena decimal terminada en 00h. Conserva todos los registros.
convertirDecimal PROC
    pushad
    mov edi, esi
    mov ebx, 10
    xor ecx, ecx
ExtraerDigito:
    xor edx, edx
    div ebx
    ; El residuo es un digito. Se guarda para invertir el orden.
    push edx
    inc ecx
    test eax, eax
    jnz ExtraerDigito
    ; Recupera los digitos en orden y los convierte a caracteres ASCII.
GuardarDigito:
    pop edx
    add dl, '0'
    mov [edi], dl
    inc edi
    loop GuardarDigito
    mov BYTE PTR [edi], 0
    popad
    ret
convertirDecimal ENDP
END main
