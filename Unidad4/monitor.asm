;Materia: Lenguajes de Interfaz (SCC-1014)
;Alumno: Marcelo Vidrio Ochoa
;Horario: 8:00 AM - 9:00 AM
;Docente: Dr. José Luis Medina Jiménez
;Proyecto: PROYECTO UNIDAD 4 - Estacion de monitoreo (simulado con USB)
;Archivo: monitor.asm  (parte en ENSAMBLADOR del programa hibrido)
;Descripcion: Procedimientos en MASM x86 de 32 bits que el programa en C++
;             (main.cpp) llama con la convencion C (cdecl):
;               - UnidadesNuevas   : operacion de bits sobre la mascara de unidades
;               - SiguienteUnidad  : obtiene y quita el bit de la siguiente unidad
;               - BuscarClave      : busca una clave de texto (SITIO=, INTERVALO_MS=)
;               - TextoANumero     : convierte texto decimal a entero
;               - ExtraerValor     : obtiene la temperatura del renglon actual del CSV
;               - NumeroATexto     : convierte un entero a texto decimal
;             Convencion C: los parametros llegan por la pila (de derecha a
;             izquierda), el resultado se regresa en EAX, quien llama limpia la
;             pila y el procedimiento debe conservar EBX, ESI, EDI y EBP (USES).

.386
.model flat, C                  ; nombres con "_" y convencion cdecl, como espera C++

MASCARA_AZ = 03FFFFFFh          ; 26 bits: unidades A: a Z:

.code
;---------------------------------------------------------------
; unsigned UnidadesNuevas(unsigned actual, unsigned anterior)
; Recibe: actual   = mascara que regresa GetLogicalDrives
;         anterior = mascara de la revision previa
; Regresa: EAX = bits de las unidades que aparecieron
;          (actual AND NOT anterior), solo A:..Z:
;---------------------------------------------------------------
UnidadesNuevas PROC actual:DWORD, anterior:DWORD
    mov  eax, anterior
    not  eax                    ; bits que antes estaban en 0
    and  eax, actual            ; ... y ahora estan en 1
    and  eax, MASCARA_AZ
    ret
UnidadesNuevas ENDP

;---------------------------------------------------------------
; int SiguienteUnidad(unsigned *mascara)
; Recibe: puntero a una mascara de unidades
; Regresa: EAX = indice de la unidad mas baja (0 = A:, 1 = B:, ...)
;          y apaga ese bit en la mascara; EAX = -1 si ya no hay bits
; Conserva: EBX
;---------------------------------------------------------------
SiguienteUnidad PROC USES ebx, pMascara:PTR DWORD
    mov  ebx, pMascara
    mov  eax, [ebx]
    and  eax, MASCARA_AZ
    jz   su_vacia
    bsf  eax, eax               ; EAX = posicion del primer bit en 1
    btr  DWORD PTR [ebx], eax   ; lo apaga para la siguiente llamada
    ret
su_vacia:
    mov  DWORD PTR [ebx], 0
    mov  eax, -1
    ret
SiguienteUnidad ENDP

;---------------------------------------------------------------
; const char* BuscarClave(const char *texto, const char *clave)
; Regresa: EAX = direccion justo despues de la clave, o 0 (NULL)
; Conserva: EBX, ESI, EDI
;---------------------------------------------------------------
BuscarClave PROC USES ebx esi edi, pTexto:PTR BYTE, pClave:PTR BYTE
    mov  esi, pTexto
bc_externo:
    cmp  BYTE PTR [esi], 0
    je   bc_noEncontrada
    mov  edi, pClave
    mov  ebx, esi
bc_interno:
    mov  al, [edi]
    cmp  al, 0
    je   bc_encontrada          ; se recorrio toda la clave
    cmp  al, [ebx]
    jne  bc_siguiente
    inc  edi
    inc  ebx
    jmp  bc_interno
bc_siguiente:
    inc  esi
    jmp  bc_externo
bc_encontrada:
    mov  eax, ebx
    ret
bc_noEncontrada:
    xor  eax, eax
    ret
BuscarClave ENDP

;---------------------------------------------------------------
; unsigned TextoANumero(const char *texto)
; Salta espacios iniciales y convierte los digitos que siguen.
; Se detiene en el primer caracter que no sea digito.
; Regresa: EAX = valor (0 si no hay digitos o si no cabe en 32 bits)
; Conserva: EBX, ESI
;---------------------------------------------------------------
TextoANumero PROC USES ebx esi, pTexto:PTR BYTE
    mov  esi, pTexto
    xor  eax, eax               ; EAX = numero acumulado
tn_espacios:
    cmp  BYTE PTR [esi], ' '
    jne  tn_digito
    inc  esi
    jmp  tn_espacios
tn_digito:
    movzx ebx, BYTE PTR [esi]
    cmp  bl, '0'
    jb   tn_fin
    cmp  bl, '9'
    ja   tn_fin
    sub  ebx, '0'               ; caracter -> valor
    mov  ecx, 10
    mul  ecx                    ; EDX:EAX = EAX * 10
    test edx, edx
    jnz  tn_desborde
    add  eax, ebx
    jc   tn_desborde
    inc  esi
    jmp  tn_digito
tn_desborde:
    xor  eax, eax
tn_fin:
    ret
TextoANumero ENDP

;---------------------------------------------------------------
; int ExtraerValor(const char **cursor, char *destino, int maximo)
; Copia a destino el renglon apuntado por *cursor: solo la primera
; columna, sin espacios al inicio ni al final y sin CR/LF.
; Despues deja *cursor al inicio del siguiente renglon.
; Regresa: EAX = longitud del valor (0 = renglon vacio)
;          EAX = -1 si ya no hay renglones
; Conserva: EBX, ESI, EDI
;---------------------------------------------------------------
ExtraerValor PROC USES ebx esi edi, ppCursor:PTR DWORD, pDestino:PTR BYTE, maximo:DWORD
    mov  ebx, ppCursor
    mov  esi, [ebx]             ; ESI = posicion actual en el texto
    cmp  BYTE PTR [esi], 0
    je   ev_finDatos
ev_espacios:                    ; espacios y tabuladores iniciales
    mov  al, [esi]
    cmp  al, ' '
    je   ev_saltar
    cmp  al, 9
    jne  ev_empezar
ev_saltar:
    inc  esi
    jmp  ev_espacios
ev_empezar:
    mov  edi, pDestino
    xor  ecx, ecx               ; ECX = caracteres copiados
    xor  edx, edx               ; EDX = 1 despues de una coma
ev_ciclo:
    mov  al, [esi]
    cmp  al, 0
    je   ev_finRenglon
    cmp  al, 10
    je   ev_lf
    cmp  al, 13
    je   ev_avanzar             ; ignora el CR de Windows
    cmp  al, ','
    jne  ev_revisar
    mov  edx, 1                 ; solo se usa la primera columna
ev_revisar:
    test edx, edx
    jnz  ev_avanzar
    mov  eax, maximo
    dec  eax                    ; deja lugar para el 0 final
    cmp  ecx, eax
    jae  ev_avanzar
    mov  al, [esi]
    mov  [edi], al
    inc  edi
    inc  ecx
ev_avanzar:
    inc  esi
    jmp  ev_ciclo
ev_lf:
    inc  esi                    ; consume el LF
ev_finRenglon:
ev_recortar:                    ; quita espacios al final
    test ecx, ecx
    jz   ev_listo
    cmp  BYTE PTR [edi-1], ' '
    jne  ev_listo
    dec  edi
    dec  ecx
    jmp  ev_recortar
ev_listo:
    mov  BYTE PTR [edi], 0
    mov  [ebx], esi             ; actualiza el cursor de quien llama
    mov  eax, ecx
    ret
ev_finDatos:
    mov  eax, -1
    ret
ExtraerValor ENDP

;---------------------------------------------------------------
; void NumeroATexto(unsigned valor, char *destino)
; Escribe valor en decimal y termina la cadena con 0.
; Los digitos se obtienen dividiendo entre 10 y se guardan en la
; pila para escribirlos en el orden correcto.
; Conserva: EBX, EDI
;---------------------------------------------------------------
NumeroATexto PROC USES ebx edi, valor:DWORD, pDestino:PTR BYTE
    mov  eax, valor
    mov  edi, pDestino
    mov  ebx, 10
    xor  ecx, ecx
nt_dividir:
    xor  edx, edx
    div  ebx                    ; EAX = cociente, EDX = digito
    push edx
    inc  ecx
    test eax, eax
    jnz  nt_dividir
nt_escribir:
    pop  eax                    ; un POP por cada PUSH: pila equilibrada
    add  al, '0'
    mov  [edi], al
    inc  edi
    loop nt_escribir
    mov  BYTE PTR [edi], 0
    ret
NumeroATexto ENDP

END
