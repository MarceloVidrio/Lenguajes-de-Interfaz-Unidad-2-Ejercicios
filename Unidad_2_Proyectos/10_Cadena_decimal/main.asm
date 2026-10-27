; Materia: Lenguajes de Interfaz - Unidad 2
; Nombre: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
; Practica: 10. Cadena decimal: avance de descarga


INCLUDE Irvine32.inc

.data
tamArchivo DWORD 100000
bloques DWORD 125
tamBloque DWORD 512
descargados DWORD ?
pendientes DWORD ?
porcentaje DWORD ?
grupos DWORD ?
residuo DWORD ?
msg1 BYTE "Bytes descargados: ",0
msg2 BYTE "Bytes pendientes: ",0
msg3 BYTE "Porcentaje entero de avance: ",0
msg4 BYTE "Grupos completos de 1024: ",0
msg5 BYTE "Residuo del agrupamiento: ",0
buffer BYTE 11 DUP(0)

.code
main PROC
; Todos los calculos se realizan en main y se almacenan en DWORD.
    ; Calcula los bytes descargados: numero de bloques por bytes de cada bloque.
    mov eax, bloques
    mul tamBloque
    mov descargados, eax
    ; Resta los bytes descargados al total para obtener los pendientes.
    mov eax, tamArchivo
    sub eax, descargados
    mov pendientes, eax
    ; Calcula el porcentaje entero: descargados por 100 dividido entre el total.
    mov eax, descargados
    mov ebx, 100
    mul ebx
    div tamArchivo
    mov porcentaje, eax
    mov eax, descargados
    xor edx, edx
    ; Divide los bytes descargados en grupos de 1024 y conserva el residuo.
    mov ebx, 1024
    div ebx
    mov grupos, eax
    mov residuo, edx
    ; Convierte cada resultado a texto decimal y lo muestra con su etiqueta.
    mov edx, OFFSET msg1
    call WriteString
    mov eax, descargados
    mov esi, OFFSET buffer
    call convertirDecimal
    mov edx, OFFSET buffer
    call WriteString
    call Crlf
    mov edx, OFFSET msg2
    call WriteString
    mov eax, pendientes
    mov esi, OFFSET buffer
    call convertirDecimal
    mov edx, OFFSET buffer
    call WriteString
    call Crlf
    mov edx, OFFSET msg3
    call WriteString
    mov eax, porcentaje
    mov esi, OFFSET buffer
    call convertirDecimal
    mov edx, OFFSET buffer
    call WriteString
    call Crlf
    mov edx, OFFSET msg4
    call WriteString
    mov eax, grupos
    mov esi, OFFSET buffer
    call convertirDecimal
    mov edx, OFFSET buffer
    call WriteString
    call Crlf
    mov edx, OFFSET msg5
    call WriteString
    mov eax, residuo
    mov esi, OFFSET buffer
    call convertirDecimal
    mov edx, OFFSET buffer
    call WriteString
    call Crlf
    exit
main ENDP

; Entrada: EAX=DWORD sin signo, ESI=buffer de al menos 11 bytes.
; Salida: cadena decimal terminada en 00h. Conserva todos los registros.
convertirDecimal PROC
    pushad
    mov edi, esi
    mov ebx, 10
    xor ecx, ecx
    ; Divide entre 10 repetidamente para obtener los digitos desde el ultimo.
ExtraerDigito:
    xor edx, edx
    div ebx
    ; El residuo es un digito. Se guarda para invertir el orden.
    push edx
    inc ecx
    test eax, eax
    jnz ExtraerDigito
    ; Recupera los digitos de la pila y suma ASCII cero para formar la cadena.
GuardarDigito:
    pop edx
    add dl, '0'
    mov [edi], dl
    inc edi
    loop GuardarDigito
    ; Marca el final del texto para que WriteString sepa donde detenerse.
    mov BYTE PTR [edi], 0
    popad
    ret
convertirDecimal ENDP
END main
