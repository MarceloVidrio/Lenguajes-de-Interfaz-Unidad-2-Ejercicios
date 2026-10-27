; Materia: Lenguajes de Interfaz - Unidad 2
; Nombre: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
; Practica: 9. PUSH y POP


INCLUDE Irvine32.inc

.data


.code
    ; Los ejemplos muestran como la pila guarda y recupera valores de 32 bits.
main PROC
; Copiar 500 mediante la pila: EBX=500.
    mov eax, 500
    push eax
    mov ebx, 0
    pop ebx
    call DumpRegs
    ; LIFO: EAX=30, EBX=20, ECX=10.
    push 10
    push 20
    push 30
    pop eax
    pop ebx
    pop ecx
    call DumpRegs
    ; Conservar y restaurar: EAX=100, EBX=200.
    mov eax, 100
    mov ebx, 200
    push eax
    push ebx
    mov eax, 999
    mov ebx, 888
    pop ebx
    pop eax
    call DumpRegs
    ; CALL/RET: EAX=60; EBX conserva 666.
    mov eax, 50
    mov ebx, 666
    call AumentarDiez
    call DumpRegs
    exit
main ENDP

    ; Recibe EAX y devuelve EAX + 10; guarda EBX para restaurarlo al salir.
AumentarDiez PROC
    push ebx
    mov ebx, 10
    add eax, ebx
    pop ebx
    ; Regresa a la instruccion siguiente al CALL que invoco el procedimiento.
    ret
AumentarDiez ENDP
END main
