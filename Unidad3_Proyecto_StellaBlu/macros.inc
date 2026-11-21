; =====================================================================
; macros.inc - Macros de Stella Blu (Version de la Unidad 3)
; Materia: Lenguajes de Interfaz - Unidad 3
; Alumno: Marcelo Vidrio Ochoa
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
;
; Cada macro sustituye una secuencia corta que se repetia en main.asm.
; MASM copia (expande) sus instrucciones en cada punto de uso: el .asm
; queda mas corto, pero el ejecutable conserva las mismas instrucciones.
; Las tareas largas o con varias salidas se dejaron como procedimientos.
; =====================================================================

; ---------------------------------------------------------------------
; mMostrar texto
; Escribe la cadena 'texto' (terminada en 0) en la consola.
; Sustituye:  mov edx, OFFSET texto / call WriteString
; Modifica: EDX.
; ---------------------------------------------------------------------
mMostrar MACRO texto
    mov  edx, OFFSET texto
    call Escribir
ENDM

; ---------------------------------------------------------------------
; mSalto
; Escribe un salto de linea (CR, LF). Sustituye a call Crlf para que
; toda la salida pase por el procedimiento Escribir.
; Modifica: EDX.
; ---------------------------------------------------------------------
mSalto MACRO
    mMostrar txtCRLF
ENDM

; ---------------------------------------------------------------------
; mMostrarValor etiqueta, valor, rutina
; Escribe una etiqueta, el valor con la rutina indicada (PrintUInt o
; PrintMoney) y un salto de linea.
; Sustituye 4 lineas que se repetian en el resumen, la recepcion, la
; venta y la ficha del producto.
; Modifica: EAX, EDX.
; ---------------------------------------------------------------------
mMostrarValor MACRO etiqueta, valor, rutina
    mMostrar etiqueta
    mov  eax, valor
    call rutina
    mSalto
ENDM

; ---------------------------------------------------------------------
; mMostrarCampo etiqueta, desplazamiento
; Escribe una etiqueta y el campo de texto del registro apuntado por ESI.
; Modifica: EDX.
; ---------------------------------------------------------------------
mMostrarCampo MACRO etiqueta, desplazamiento
    mMostrar etiqueta
    lea  edx, [esi + desplazamiento]
    call Escribir
ENDM

; ---------------------------------------------------------------------
; mPedirNumero mensaje, minimo, maximo
; Carga los tres argumentos de AskUInt y la llama.
; Devuelve: EAX = entero aceptado dentro del rango.
; Modifica: EAX, EBX, EDX, EDI.
; ---------------------------------------------------------------------
mPedirNumero MACRO mensaje, minimo, maximo
    mov  edx, OFFSET mensaje
    mov  ebx, minimo
    mov  edi, maximo
    call AskUInt
ENDM

; ---------------------------------------------------------------------
; mCapturar mensaje
; Muestra el mensaje, lee una linea en 'entrada' y deja ESI apuntando
; al texto capturado, listo para el validador.
; Devuelve: EAX = longitud, ESI = OFFSET entrada.
; Modifica: EAX, EDX, ESI.
; ---------------------------------------------------------------------
mCapturar MACRO mensaje
    mov  edx, OFFSET mensaje
    call Capture
    mov  esi, OFFSET entrada
ENDM

; ---------------------------------------------------------------------
; mValidarOReintentar mensajeError, etiquetaReintento
; Para validadores que devuelven EAX=1 (valido) o EAX=0 (invalido).
; Si EAX=0 muestra el error y salta a la etiqueta de reintento; si EAX=1
; continua. Usa LOCAL porque tiene una etiqueta interna y se usa en
; varios procedimientos: cada expansion recibe un nombre distinto.
; Modifica: EDX solo cuando hay error.
; ---------------------------------------------------------------------
mValidarOReintentar MACRO mensajeError, etiquetaReintento
    LOCAL continuar
    test eax, eax
    jnz  continuar
    mMostrar mensajeError
    jmp  etiquetaReintento
continuar:
ENDM

; ---------------------------------------------------------------------
; mSiFueraDeRango valor, minimo, maximo, destino
; Compara sin signo y salta a 'destino' si valor < minimo o valor > maximo.
; Se usa para letras A-Z, digitos 0-9 y caracteres visibles 32-126.
; No modifica registros (solo EFLAGS).
; ---------------------------------------------------------------------
mSiFueraDeRango MACRO valor, minimo, maximo, destino
    cmp  valor, minimo
    jb   destino
    cmp  valor, maximo
    ja   destino
ENDM

; ---------------------------------------------------------------------
; mCopiarBytes destino, origen, cantidad
; Copia 'cantidad' bytes de origen a destino con REP MOVSB (DF=0).
; Modifica: ECX (queda en 0), ESI, EDI.
; ---------------------------------------------------------------------
mCopiarBytes MACRO destino, origen, cantidad
    mov  esi, origen
    mov  edi, destino
    mov  ecx, cantidad
    cld
    rep  movsb
ENDM

; ---------------------------------------------------------------------
; mLlenarCeros destino, cantidad
; Pone en 0 'cantidad' bytes desde destino con REP STOSB (DF=0).
; Modifica: EAX (queda en 0), ECX (queda en 0), EDI.
; ---------------------------------------------------------------------
mLlenarCeros MACRO destino, cantidad
    mov  edi, destino
    mov  ecx, cantidad
    xor  eax, eax
    cld
    rep  stosb
ENDM

; ---------------------------------------------------------------------
; mCerrarArchivoActual
; Cierra el archivo cuyo handle esta en handleActual.
; Devuelve: EAX = resultado de CloseFile (0 si fallo).
; ---------------------------------------------------------------------
mCerrarArchivoActual MACRO
    mov  eax, handleActual
    call CloseFile
ENDM
