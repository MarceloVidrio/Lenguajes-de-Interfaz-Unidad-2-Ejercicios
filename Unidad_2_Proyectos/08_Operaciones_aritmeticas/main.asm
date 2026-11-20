; Materia: Lenguajes de Interfaz - Unidad 2
; Nombre: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
; Practica: 8. Operaciones aritmeticas


INCLUDE Irvine32.inc

.data


.code
    ; Cada ejemplo muestra registros y banderas mediante DumpRegs.
main PROC
; 1: EAX = 50 + 20 - 15 = 55.
    mov eax, 50
    mov ebx, 20
    add eax, ebx
    sub eax, 15
    call DumpRegs
    ; 2: AL = 255 + 1 -> 0, CF=1.
    mov eax, 0
    mov al, 255
    add al, 1
    call DumpRegs
    ; 3: AL = 127 + 1 -> 80h (-128), OF=1.
    mov eax, 0
    mov al, 127
    add al, 1
    call DumpRegs
    ; 4: producto sin signo 25*3 = 75.
    mov eax, 25
    mov ebx, 3
    mul ebx
    call DumpRegs
    ; 5: 65537^2 = 00000001:00020001h en EDX:EAX.
    mov eax, 65537
    mov ebx, 65537
    mul ebx
    call DumpRegs
    ; 6: multiplicacion con signo, EAX=-15.
    mov eax, -5
    imul eax, eax, 3
    call DumpRegs
    ; 7: division sin signo, cociente=10, residuo=5.
    mov eax, 125
    ; Prepara EDX:EAX como dividendo sin signo antes de DIV.
    xor edx, edx
    mov ebx, 12
    div ebx
    call DumpRegs
    ; 8: division con signo, cociente=-10, residuo=-5.
    mov eax, -125
    ; Extiende el signo de EAX a EDX para la division con signo IDIV.
    cdq
    mov ebx, 12
    idiv ebx
    call DumpRegs
    exit
main ENDP


END main
