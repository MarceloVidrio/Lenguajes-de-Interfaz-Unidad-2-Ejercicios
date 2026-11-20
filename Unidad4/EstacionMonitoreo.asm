;Materia: Lenguajes de Interfaz (SCC-1014)
;Alumno: Marcelo Vidrio Ochoa
;Horario: 8:00 AM - 9:00 AM
;Docente: Dr. José Luis Medina Jiménez
;Proyecto: PROYECTO UNIDAD 4 - Estacion de monitoreo (simulado con USB)
;Descripción: El programa espera a que se conecte una memoria USB. Cuando aparece
;             una unidad nueva busca sensor.ini en su raiz, lee el sitio y el
;             intervalo, abre lecturas.csv, muestra cada temperatura en un renglon
;             fijo de la consola (con color segun el estado) y guarda las lecturas
;             en resultados.csv dentro de la misma memoria. Al retirar la USB vuelve
;             a esperar una nueva conexion.

INCLUDE Irvine32.inc

;---------------------------------------------------------------
; Funciones de Windows que no vienen declaradas en Irvine32.inc
;---------------------------------------------------------------
GetLogicalDrives PROTO                      ; regresa en EAX un bit por cada unidad (bit0=A:, bit1=B:, ...)
SetErrorMode     PROTO :DWORD               ; evita ventanas de error de Windows al revisar unidades

;---------------------------------------------------------------
; Prototipos de los procedimientos propios que se usan con INVOKE
;---------------------------------------------------------------
LeerArchivo    PROTO :PTR BYTE, :PTR BYTE, :DWORD
EscribirCadena PROTO :DWORD, :PTR BYTE
BuscarClave    PROTO :PTR BYTE, :PTR BYTE

;---------------------------------------------------------------
; Constantes de la API de archivos de Windows
;---------------------------------------------------------------
K_GENERIC_READ    = 80000000h
K_GENERIC_WRITE   = 40000000h
K_SHARE_READ      = 1
K_CREATE_ALWAYS   = 2
K_OPEN_EXISTING   = 3
K_ATTR_NORMAL     = 80h
K_HANDLE_INVALIDO = -1
K_SEM_SIN_ERRORES = 1                       ; SEM_FAILCRITICALERRORS

;---------------------------------------------------------------
; Constantes de la pantalla
;---------------------------------------------------------------
COLUMNA      = 4                            ; columna donde empiezan los mensajes
FILA_ESTADO  = 7                            ; renglon fijo del estado / lecturas
FILA_INFO    = 9                            ; renglon con unidad e intervalo
ANCHO_CAMPO  = 64                           ; ancho del campo que se limpia

COLOR_TITULO    = yellow     + (black * 16)
COLOR_ESPERA    = lightGray  + (black * 16)
COLOR_DETECTADA = cyan       + (black * 16)
COLOR_LEYENDO   = white      + (blue  * 16)
COLOR_LECTURA   = lightGreen + (black * 16)
COLOR_FINAL     = lightGreen + (black * 16)
COLOR_ERROR     = lightRed   + (black * 16)
COLOR_INFO      = lightGray  + (black * 16)

;---------------------------------------------------------------
; Otras constantes
;---------------------------------------------------------------
ESPERA_SONDEO   = 500                       ; ms entre revisiones de unidades
PAUSA_DETECCION = 1500                      ; ms que se ve el mensaje de USB detectada
INTERVALO_DEF   = 2000                      ; intervalo si sensor.ini no lo trae
MAX_SITIO       = 32
MAX_VALOR       = 16

;---------------------------------------------------------------
; mEstado texto, color
; Macro que coloca un mensaje con su color en el renglon de estado.
;---------------------------------------------------------------
mEstado MACRO texto, color
    mov  edx, OFFSET texto
    mov  eax, color
    call MostrarEstado
ENDM

.data
    ; --- Encabezado de la pantalla ---
    txtTitulo1   BYTE "ESTACION DE MONITOREO (SIMULADO CON USB)",0
    txtTitulo2   BYTE "TecNM Campus Culiacan | Lenguajes de Interfaz | Unidad 4",0
    txtTitulo3   BYTE "Alumno: Marcelo Vidrio Ochoa",0
    txtLinea     BYTE "--------------------------------------------------------",0
    txtEtiqueta  BYTE "Estado:",0
    txtAyuda     BYTE "Cierre la ventana para terminar el programa.",0

    ; --- Mensajes de estado ---
    txtEsperando     BYTE "Esperando memoria USB...",0
    txtDetectada     BYTE "USB detectada: ",0
    txtLeyendo       BYTE "Leyendo archivo...",0
    txtTerminado     BYTE "Proceso terminado. Puede retirar la USB.",0
    txtErrorEntrada  BYTE "Error al abrir lecturas.csv",0
    txtErrorFormato  BYTE "Error: lecturas.csv no tiene la columna temperatura_c",0
    txtErrorVacio    BYTE "Error: lecturas.csv no contiene temperaturas",0
    txtErrorSalida   BYTE "Error al escribir resultados.csv",0
    txtVacio         BYTE 0

    ; --- Piezas para armar textos ---
    txtLectura       BYTE "Lectura ",0
    txtDosPuntos     BYTE ": ",0
    txtGrados        BYTE " C",0
    txtComa          BYTE ",",0
    txtCRLF          BYTE 13,10,0
    txtInfoUnidad    BYTE "Unidad: ",0
    txtInfoIntervalo BYTE ":\    Intervalo: ",0
    txtMs            BYTE " ms",0
    txtSitioDef      BYTE "SIN_SITIO",0

    ; --- Claves que se buscan en los archivos ---
    claveSitio       BYTE "SITIO=",0
    claveIntervalo   BYTE "INTERVALO_MS=",0
    claveColumna     BYTE "temperatura_c",0
    encabezadoRes    BYTE "sitio,numero,temperatura_c",13,10,0

    ; --- Rutas: el primer caracter se cambia por la letra de la unidad ---
    rutaIni   BYTE "?:\sensor.ini",0
    rutaCsv   BYTE "?:\lecturas.csv",0
    rutaRes   BYTE "?:\resultados.csv",0

    ; --- Buffers ---
    bufIni    BYTE 1024 DUP(0)
    bufCsv    BYTE 8192 DUP(0)
    lineaMsg  BYTE 128 DUP(0)
    lineaInfo BYTE 128 DUP(0)
    filaRes   BYTE 128 DUP(0)
    valorTxt  BYTE MAX_VALOR DUP(0)
    sitio     BYTE MAX_SITIO DUP(0)

    ; --- Variables de control ---
    mascaraPrev DWORD 0                     ; unidades que ya conociamos
    bitUnidad   DWORD 0                     ; bit de la USB en sesion
    letra       BYTE  0                     ; letra de la USB en sesion
    intervalo   DWORD INTERVALO_DEF
    hSalida     DWORD 0                     ; handle de resultados.csv
    punteroCsv  DWORD 0                     ; posicion actual dentro de bufCsv
    numLectura  DWORD 0

.code
;===============================================================
; main: coordina las etapas (esperar -> detectar -> sesion ->
;       esperar retiro -> esperar)
;===============================================================
main PROC
    INVOKE SetErrorMode, K_SEM_SIN_ERRORES

    mov  eax, COLOR_ESPERA
    call SetTextColor
    call Clrscr
    call DibujarEncabezado

    mov  mascaraPrev, 0                     ; al inicio se revisan todas las unidades

EstadoEspera:
    call MostrarEspera                      ; Etapa 1 y 6: esperar

CicloEspera:
    INVOKE Sleep, ESPERA_SONDEO
    INVOKE GetLogicalDrives                 ; EAX = mascara actual
    mov  ebx, eax
    mov  eax, mascaraPrev
    not  eax
    and  eax, ebx                           ; nuevas = actual AND NOT anterior
    mov  mascaraPrev, ebx                   ; (MOV no cambia las banderas)
    jz   CicloEspera                        ; no aparecio ninguna unidad

    ; Recorro los 26 bits buscando las unidades nuevas
    mov  edi, eax                           ; EDI = bits de unidades nuevas
    xor  ecx, ecx                           ; ECX = indice (0 = A:)
RevisarBit:
    bt   edi, ecx                           ; CF = bit ECX de EDI
    jnc  SiguienteBit
    push ecx
    push edi
    mov  eax, ecx
    call ProbarUnidad                       ; CF=0 si la unidad tiene sensor.ini
    pop  edi
    pop  ecx
    jnc  UnidadValida
SiguienteBit:
    inc  ecx
    cmp  ecx, 26
    jb   RevisarBit
    jmp  CicloEspera                        ; ninguna tenia perfil: sigo esperando

UnidadValida:
    mov  eax, 1
    shl  eax, cl                            ; bit de la unidad detectada
    mov  bitUnidad, eax
    call EjecutarSesion                     ; Etapas 2 a 5 (una sola vez)

    ; Mantengo el estado final o de error mientras la USB siga conectada
EsperarRetiro:
    INVOKE Sleep, ESPERA_SONDEO
    INVOKE GetLogicalDrives
    mov  mascaraPrev, eax
    test eax, bitUnidad
    jnz  EsperarRetiro
    jmp  EstadoEspera                       ; la retiraron: vuelvo a esperar

    exit
main ENDP

;===============================================================
; ProbarUnidad
; Recibe:  EAX = indice de la unidad (0=A, 1=B, 2=C, ...)
; Regresa: CF=0 si se encontro y leyo sensor.ini (sitio e
;          intervalo quedan cargados), CF=1 si no hay perfil.
;===============================================================
ProbarUnidad PROC USES ebx
    add  al, 'A'
    mov  letra, al
    mov  rutaIni, al                        ; "E:\sensor.ini"
    mov  rutaCsv, al
    mov  rutaRes, al

    mov  ebx, 3                             ; hasta 3 intentos (la USB tarda en montarse)
pu_intento:
    INVOKE LeerArchivo, ADDR rutaIni, ADDR bufIni, SIZEOF bufIni
    jnc  pu_encontrado
    INVOKE Sleep, 400
    dec  ebx
    jnz  pu_intento
    stc                                     ; no tiene perfil
    ret

pu_encontrado:
    call InterpretarPerfil
    clc
    ret
ProbarUnidad ENDP

;===============================================================
; InterpretarPerfil
; Lee SITIO= e INTERVALO_MS= desde bufIni.
; Regresa: sitio (cadena) e intervalo (DWORD) cargados.
;===============================================================
InterpretarPerfil PROC USES eax ebx ecx esi edi
    ; ---- SITIO ----
    mov  edi, OFFSET sitio
    INVOKE BuscarClave, ADDR bufIni, ADDR claveSitio
    test eax, eax
    jz   ip_sitioDefecto
    mov  esi, eax
ip_espacios:                                ; salto espacios despues del '='
    cmp  BYTE PTR [esi], ' '
    jne  ip_copiar
    inc  esi
    jmp  ip_espacios
ip_copiar:
    mov  ecx, MAX_SITIO - 1
ip_ciclo:
    mov  al, [esi]
    cmp  al, 0
    je   ip_finSitio
    cmp  al, 13
    je   ip_finSitio
    cmp  al, 10
    je   ip_finSitio
    mov  [edi], al
    inc  esi
    inc  edi
    loop ip_ciclo
ip_finSitio:
    mov  BYTE PTR [edi], 0
    cmp  edi, OFFSET sitio                  ; quedo vacio?
    jne  ip_intervalo
ip_sitioDefecto:
    mov  edi, OFFSET sitio
    mov  esi, OFFSET txtSitioDef
    call CopiarCadena

    ; ---- INTERVALO_MS ----
ip_intervalo:
    mov  intervalo, INTERVALO_DEF
    INVOKE BuscarClave, ADDR bufIni, ADDR claveIntervalo
    test eax, eax
    jz   ip_fin
    mov  esi, eax
    xor  ebx, ebx                           ; EBX = numero acumulado
ip_digito:
    movzx eax, BYTE PTR [esi]
    cmp  al, '0'
    jb   ip_finNumero
    cmp  al, '9'
    ja   ip_finNumero
    sub  eax, '0'
    imul ebx, ebx, 10
    add  ebx, eax
    inc  esi
    jmp  ip_digito
ip_finNumero:
    cmp  ebx, 0                             ; 0 o vacio: dejo el valor por defecto
    je   ip_fin
    mov  intervalo, ebx
ip_fin:
    ret
InterpretarPerfil ENDP

;===============================================================
; EjecutarSesion
; Etapas 2 a 5: muestra la deteccion, lee lecturas.csv, presenta
; cada temperatura con el intervalo indicado y genera resultados.csv.
;===============================================================
EjecutarSesion PROC
    ; ---- Etapa 2: USB detectada ----
    mov  edi, OFFSET lineaMsg
    mov  esi, OFFSET txtDetectada
    call CopiarCadena
    mov  esi, OFFSET sitio
    call CopiarCadena
    mEstado lineaMsg, COLOR_DETECTADA
    call MostrarInfo
    INVOKE Sleep, PAUSA_DETECCION

    ; ---- Etapa 3: abrir y leer lecturas.csv ----
    mEstado txtLeyendo, COLOR_LEYENDO
    INVOKE LeerArchivo, ADDR rutaCsv, ADDR bufCsv, SIZEOF bufCsv
    jc   es_errorEntrada

    ; El encabezado debe identificar la columna
    INVOKE BuscarClave, ADDR bufCsv, ADDR claveColumna
    test eax, eax
    jz   es_errorFormato

    ; Creo (o reemplazo) resultados.csv
    INVOKE CreateFile, ADDR rutaRes, K_GENERIC_WRITE, 0, 0, K_CREATE_ALWAYS, K_ATTR_NORMAL, 0
    cmp  eax, K_HANDLE_INVALIDO
    je   es_errorSalida
    mov  hSalida, eax
    INVOKE EscribirCadena, hSalida, ADDR encabezadoRes
    jc   es_errorEscritura

    ; ---- Etapa 4: mostrar las lecturas ----
    mov  punteroCsv, OFFSET bufCsv
    call SaltarEncabezado
    mov  numLectura, 0

es_siguienteFila:
    call ExtraerValor                       ; EAX = longitud, CF=1 si ya no hay datos
    jc   es_finLecturas
    test eax, eax
    jz   es_siguienteFila                   ; renglon vacio: lo ignoro
    inc  numLectura

    INVOKE Sleep, intervalo                 ; una lectura por intervalo

    ; Consola: "Lectura N: valor C"
    mov  edi, OFFSET lineaMsg
    mov  esi, OFFSET txtLectura
    call CopiarCadena
    mov  eax, numLectura
    call NumATexto
    mov  esi, OFFSET txtDosPuntos
    call CopiarCadena
    mov  esi, OFFSET valorTxt
    call CopiarCadena
    mov  esi, OFFSET txtGrados
    call CopiarCadena
    mEstado lineaMsg, COLOR_LECTURA

    ; Archivo: "sitio,N,valor" + CRLF
    mov  edi, OFFSET filaRes
    mov  esi, OFFSET sitio
    call CopiarCadena
    mov  esi, OFFSET txtComa
    call CopiarCadena
    mov  eax, numLectura
    call NumATexto
    mov  esi, OFFSET txtComa
    call CopiarCadena
    mov  esi, OFFSET valorTxt
    call CopiarCadena
    mov  esi, OFFSET txtCRLF
    call CopiarCadena
    INVOKE EscribirCadena, hSalida, ADDR filaRes
    jc   es_errorEscritura
    jmp  es_siguienteFila

    ; ---- Etapa 5: guardar y finalizar ----
es_finLecturas:
    INVOKE CloseHandle, hSalida
    cmp  numLectura, 0
    je   es_errorVacio
    mEstado txtTerminado, COLOR_FINAL
    ret

    ; ---- Manejo de errores ----
es_errorEntrada:
    mEstado txtErrorEntrada, COLOR_ERROR
    ret
es_errorFormato:
    mEstado txtErrorFormato, COLOR_ERROR
    ret
es_errorVacio:
    mEstado txtErrorVacio, COLOR_ERROR
    ret
es_errorEscritura:
    INVOKE CloseHandle, hSalida             ; cierro el archivo abierto
es_errorSalida:
    mEstado txtErrorSalida, COLOR_ERROR
    ret
EjecutarSesion ENDP

;===============================================================
; LeerArchivo
; Abre un archivo, lo lee completo en un buffer y lo cierra.
; Recibe:  pRuta = ruta, pBuf = buffer, capacidad = tamano del buffer
; Regresa: EAX = bytes leidos, CF=0 si todo bien; CF=1 si fallo.
;          El buffer queda terminado en 0.
;===============================================================
LeerArchivo PROC USES ebx esi, pRuta:PTR BYTE, pBuf:PTR BYTE, capacidad:DWORD
    LOCAL hArch:DWORD, total:DWORD, leidos:DWORD

    INVOKE CreateFile, pRuta, K_GENERIC_READ, K_SHARE_READ, 0, K_OPEN_EXISTING, K_ATTR_NORMAL, 0
    cmp  eax, K_HANDLE_INVALIDO
    je   la_falla
    mov  hArch, eax
    mov  total, 0

la_ciclo:
    mov  ebx, capacidad
    dec  ebx                                ; dejo un byte para el 0 final
    sub  ebx, total                         ; EBX = espacio libre
    jz   la_listo                           ; buffer lleno
    mov  esi, pBuf
    add  esi, total                         ; ESI = donde continuar
    INVOKE ReadFile, hArch, esi, ebx, ADDR leidos, 0
    test eax, eax
    jz   la_errorLectura
    mov  eax, leidos                        ; solo cuento lo que ReadFile entrego
    test eax, eax
    jz   la_listo                           ; 0 bytes = fin del archivo
    add  total, eax
    jmp  la_ciclo

la_listo:
    mov  esi, pBuf
    add  esi, total
    mov  BYTE PTR [esi], 0
    INVOKE CloseHandle, hArch
    mov  eax, total
    clc
    ret

la_errorLectura:
    INVOKE CloseHandle, hArch
la_falla:
    stc
    ret
LeerArchivo ENDP

;===============================================================
; EscribirCadena
; Escribe una cadena terminada en 0 en un archivo abierto y
; verifica que se guardaron todos los bytes.
; Regresa: CF=0 si se escribio completa, CF=1 si fallo.
;===============================================================
EscribirCadena PROC USES ebx, hArch:DWORD, pCad:PTR BYTE
    LOCAL escritos:DWORD

    INVOKE Str_length, pCad
    mov  ebx, eax                           ; bytes previstos
    INVOKE WriteFile, hArch, pCad, ebx, ADDR escritos, 0
    test eax, eax
    jz   ec_error
    cmp  escritos, ebx                      ; se guardo todo?
    jne  ec_error
    clc
    ret
ec_error:
    stc
    ret
EscribirCadena ENDP

;===============================================================
; BuscarClave
; Busca la cadena pClave dentro de pTexto.
; Regresa: EAX = direccion justo despues de la clave, o 0.
;===============================================================
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
    je   bc_encontrada                      ; se recorrio toda la clave
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

;===============================================================
; SaltarEncabezado
; Avanza punteroCsv al inicio del segundo renglon de bufCsv.
;===============================================================
SaltarEncabezado PROC USES eax esi
    mov  esi, punteroCsv
se_ciclo:
    mov  al, [esi]
    cmp  al, 0
    je   se_fin
    inc  esi
    cmp  al, 10                             ; LF = fin del renglon
    jne  se_ciclo
se_fin:
    mov  punteroCsv, esi
    ret
SaltarEncabezado ENDP

;===============================================================
; ExtraerValor
; Copia el renglon actual de bufCsv (sin espacios, sin CR/LF y
; solo la primera columna) a valorTxt y avanza punteroCsv.
; Regresa: EAX = longitud del valor, CF=1 si ya no hay renglones.
;===============================================================
ExtraerValor PROC USES ecx edx esi edi
    mov  esi, punteroCsv
    cmp  BYTE PTR [esi], 0
    je   ev_finDatos

ev_espacios:                                ; espacios al inicio
    mov  al, [esi]
    cmp  al, ' '
    je   ev_saltar
    cmp  al, 9
    jne  ev_empezar
ev_saltar:
    inc  esi
    jmp  ev_espacios

ev_empezar:
    mov  edi, OFFSET valorTxt
    xor  ecx, ecx                           ; ECX = caracteres copiados
    xor  edx, edx                           ; EDX = 1 despues de una coma
ev_ciclo:
    mov  al, [esi]
    cmp  al, 0
    je   ev_finRenglon
    cmp  al, 10
    je   ev_lf
    cmp  al, 13
    je   ev_avanzar                         ; ignoro el CR
    cmp  al, ','
    jne  ev_revisar
    mov  edx, 1                             ; solo uso la primera columna
ev_revisar:
    test edx, edx
    jnz  ev_avanzar
    cmp  ecx, MAX_VALOR - 1
    jae  ev_avanzar
    mov  [edi], al
    inc  edi
    inc  ecx
ev_avanzar:
    inc  esi
    jmp  ev_ciclo

ev_lf:
    inc  esi                                ; consumo el LF
ev_finRenglon:
ev_recortar:                                ; quito espacios al final
    test ecx, ecx
    jz   ev_listo
    cmp  BYTE PTR [edi-1], ' '
    jne  ev_listo
    dec  edi
    dec  ecx
    jmp  ev_recortar
ev_listo:
    mov  BYTE PTR [edi], 0
    mov  punteroCsv, esi
    mov  eax, ecx
    clc
    ret

ev_finDatos:
    xor  eax, eax
    stc
    ret
ExtraerValor ENDP

;===============================================================
; MostrarEstado
; Recibe: EDX = mensaje, EAX = color. Lo escribe en el renglon
;         de estado y limpia los caracteres sobrantes.
;===============================================================
MostrarEstado PROC USES ebx
    mov  bl, FILA_ESTADO
    call EscribirCampo
    ret
MostrarEstado ENDP

;===============================================================
; EscribirCampo
; Recibe: EDX = mensaje, EAX = color, BL = renglon.
; Coloca el cursor con Gotoxy, pone el color con SetTextColor,
; escribe el mensaje y rellena con espacios hasta ANCHO_CAMPO.
;===============================================================
EscribirCampo PROC USES eax ecx edx
    call SetTextColor                       ; color antes de escribir
    push edx
    mov  dh, bl                             ; renglon
    mov  dl, COLUMNA                        ; columna
    call Gotoxy
    pop  edx
    call WriteString

    INVOKE Str_length, edx                  ; EAX = longitud del mensaje
    mov  ecx, ANCHO_CAMPO
    sub  ecx, eax
    jbe  ecp_fin                            ; el mensaje ya ocupa todo el campo
    mov  al, ' '
ecp_relleno:
    call WriteChar                          ; borro restos del mensaje anterior
    loop ecp_relleno
ecp_fin:
    mov  eax, COLOR_ESPERA
    call SetTextColor
    mov  dh, FILA_INFO + 3                  ; dejo el cursor fuera del campo
    mov  dl, 0
    call Gotoxy
    ret
EscribirCampo ENDP

;===============================================================
; MostrarEspera
; Etapa 1/6: mensaje de espera y limpia el renglon de informacion.
;===============================================================
MostrarEspera PROC USES eax ebx edx
    mEstado txtEsperando, COLOR_ESPERA
    mov  edx, OFFSET txtVacio
    mov  eax, COLOR_INFO
    mov  bl, FILA_INFO
    call EscribirCampo
    ret
MostrarEspera ENDP

;===============================================================
; MostrarInfo
; Escribe "Unidad: X:\    Intervalo: N ms" debajo del estado.
;===============================================================
MostrarInfo PROC USES eax ebx edx esi edi
    mov  edi, OFFSET lineaInfo
    mov  esi, OFFSET txtInfoUnidad
    call CopiarCadena
    mov  al, letra
    mov  [edi], al
    inc  edi
    mov  esi, OFFSET txtInfoIntervalo
    call CopiarCadena
    mov  eax, intervalo
    call NumATexto
    mov  esi, OFFSET txtMs
    call CopiarCadena

    mov  edx, OFFSET lineaInfo
    mov  eax, COLOR_INFO
    mov  bl, FILA_INFO
    call EscribirCampo
    ret
MostrarInfo ENDP

;===============================================================
; DibujarEncabezado: titulo y etiquetas fijas de la pantalla
;===============================================================
DibujarEncabezado PROC USES eax edx
    mov  eax, COLOR_TITULO
    call SetTextColor
    mov  dh, 1
    mov  dl, COLUMNA
    call Gotoxy
    mov  edx, OFFSET txtTitulo1
    call WriteString

    mov  eax, COLOR_INFO
    call SetTextColor
    mov  dh, 2
    mov  dl, COLUMNA
    call Gotoxy
    mov  edx, OFFSET txtTitulo2
    call WriteString
    mov  dh, 3
    mov  dl, COLUMNA
    call Gotoxy
    mov  edx, OFFSET txtTitulo3
    call WriteString
    mov  dh, 4
    mov  dl, COLUMNA
    call Gotoxy
    mov  edx, OFFSET txtLinea
    call WriteString
    mov  dh, FILA_ESTADO - 1
    mov  dl, COLUMNA
    call Gotoxy
    mov  edx, OFFSET txtEtiqueta
    call WriteString
    mov  dh, FILA_INFO + 2
    mov  dl, COLUMNA
    call Gotoxy
    mov  edx, OFFSET txtAyuda
    call WriteString
    ret
DibujarEncabezado ENDP

;===============================================================
; CopiarCadena
; Recibe: ESI = origen, EDI = destino.
; Copia hasta el 0. Al terminar EDI apunta al 0 copiado, para
; poder seguir agregando texto (concatenar).
;===============================================================
CopiarCadena PROC USES eax
cc_ciclo:
    mov  al, [esi]
    mov  [edi], al
    cmp  al, 0
    je   cc_fin
    inc  esi
    inc  edi
    jmp  cc_ciclo
cc_fin:
    ret
CopiarCadena ENDP

;===============================================================
; NumATexto
; Recibe: EAX = numero sin signo, EDI = destino.
; Escribe los digitos en decimal; EDI queda en el 0 final.
;===============================================================
NumATexto PROC USES eax ebx ecx edx
    mov  ebx, 10
    xor  ecx, ecx
nt_dividir:
    xor  edx, edx
    div  ebx                                ; EAX = cociente, EDX = digito
    push edx
    inc  ecx
    test eax, eax
    jnz  nt_dividir
nt_escribir:
    pop  eax
    add  al, '0'
    mov  [edi], al
    inc  edi
    loop nt_escribir
    mov  BYTE PTR [edi], 0
    ret
NumATexto ENDP

END main
