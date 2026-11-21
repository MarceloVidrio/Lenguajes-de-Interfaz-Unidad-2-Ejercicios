; Materia: Lenguajes de Interfaz - Unidad 3
; Proyecto: Stella Blu - Ventas e inventario de gorras (Version de la Unidad 3)
; Integrantes: MARCELO VIDRIO OCHOA
; Horario: 8:00-9:00
; Docente: Dr. Jose Luis Medina Jimenez
;
; Version de la Unidad 3: misma funcionalidad, validaciones y regla de negocio
; que la Unidad 2, reorganizada con procedimientos, macros (macros.inc) y USES.
; Convencion de los contratos:
;   Recibe   = registros o variables de entrada
;   Devuelve = registros de salida (nunca se incluyen en USES)
;   Modifica = registros que cambian ademas de la salida
;   Conserva = registros restaurados con USES
; EFLAGS puede cambiar en todos los procedimientos; CF es salida solo donde
; se indica.

INCLUDE Irvine32.inc
INCLUDE macros.inc
; Funcion adicional de Windows: reemplaza el archivo solo tras escribir y cerrar.
MoveFileExA PROTO STDCALL, origen:DWORD, destino:DWORD, indicadores:DWORD

MAX_PRODUCTOS = 10
TAM_REG = 44
P_CODIGO = 0
P_NOMBRE = 8
P_PRECIO = 36
P_STOCK = 40
TAM_CODIGO = 8
TAM_CATALOGO = MAX_PRODUCTOS * TAM_REG
TAM_CAB = 16
MAX_ARCHIVO = TAM_CAB + TAM_CATALOGO
EXISTENCIA_MINIMA = 5
MAX_EXISTENCIA = 100

.data
firma BYTE "SBINV02",0
nombreArchivo BYTE "inventario.sbi",0
nombreTemporal BYTE "inventario.tmp",0
catalogo BYTE TAM_CATALOGO DUP(0)
cantidadProductos DWORD 0
ingresosSesion DWORD 0
cambios BYTE 0
; Candidatos separados: nunca escribir sobre el catalogo antes de validar.
nuevoProducto BYTE TAM_REG DUP(0)
archivoBuffer BYTE (MAX_ARCHIVO + 1) DUP(0)
entrada BYTE 256 DUP(0)
numeroTexto BYTE 11 DUP(0)
precioTexto BYTE 20 DUP(0)
handleActual DWORD ?
bytesArchivo DWORD ?
conteoCandidato DWORD ?
ventaCantidad DWORD ?
ventaImporte DWORD ?
ventaIngresos DWORD ?
totalUnidades DWORD ?
totalValor DWORD ?

; Tabla de opciones del menu: la opcion N llama a tablaOpciones[N*4].
; La opcion 0 (salir) se atiende en main porque termina el programa.
tablaOpciones DWORD 0
              DWORD RegisterProduct      ; 1
              DWORD ListInventory        ; 2
              DWORD SearchProduct        ; 3
              DWORD ReceiveStock         ; 4
              DWORD SellProduct          ; 5
              DWORD ShowSummary          ; 6
              DWORD LowStockAlerts       ; 7
              DWORD SaveCatalog          ; 8
              DWORD ConfirmLoad          ; 9

banner BYTE 13,10,"STELLA BLU - VENTAS E INVENTARIO",13,10,0
menuTexto BYTE 13,10,"1. Registrar producto",13,10
          BYTE "2. Mostrar inventario",13,10
          BYTE "3. Buscar por codigo",13,10
          BYTE "4. Recibir mercancia",13,10
          BYTE "5. Vender",13,10
          BYTE "6. Resumen de la sesion",13,10
          BYTE "7. Alertas de existencia minima (5 o menos)",13,10
          BYTE "8. Guardar catalogo",13,10
          BYTE "9. Cargar catalogo",13,10
          BYTE "0. Salir",13,10,0
pOpcion BYTE "Opcion (0-9): ",0
pCodigo BYTE "Codigo (ABC-123): ",0
pNombre BYTE "Nombre (1-25 caracteres ASCII visibles): ",0
pPrecio BYTE "Precio en pesos, ej. 229 o 185.50: ",0
pStock BYTE "Existencia inicial (0-100): ",0
pCantidad BYTE "Cantidad de unidades (1-100): ",0
pSalir BYTE "Hay cambios sin guardar. 1=Guardar y salir, 2=Salir sin guardar, 0=Volver: ",0
pCargar BYTE "Cargar descarta cambios sin guardar. 1=Continuar, 0=Cancelar: ",0
msgInvalido BYTE "Entrada invalida. Intente de nuevo.",13,10,0
msgLargo BYTE "Entrada demasiado larga; no se acepto.",13,10,0
msgCodigo BYTE "Formato invalido: tres mayusculas, guion y tres digitos.",13,10,0
msgNombre BYTE "Use 1-25 caracteres visibles, con al menos uno distinto de espacio.",13,10,0
msgPrecio BYTE "Precio invalido. Rango: 0.01 a 9999.99, maximo dos decimales.",13,10,0
msgDuplicado BYTE "Codigo duplicado. Capture otro codigo.",13,10,0
msgLleno BYTE "Capacidad completa: solo se permiten 10 productos.",13,10,0
msgVacio BYTE "El catalogo esta vacio.",13,10,0
msgNoExiste BYTE "No se encontro el producto. Capture otro codigo.",13,10,0
msgAlta BYTE "Producto registrado.",13,10,0
msgEntrada BYTE "Recepcion aceptada. Existencia actual: ",0
msgExceso BYTE "Recepcion rechazada: excede 100 unidades. Capture otra cantidad.",13,10,0
msgSinStock BYTE "Venta rechazada: no hay unidades disponibles.",13,10,0
msgInsuficiente BYTE "Venta rechazada: existencia insuficiente. Capture otra cantidad.",13,10,0
msgVenta BYTE "Venta aceptada. Importe: ",0
msgOverflow BYTE "Operacion rechazada por desbordamiento. Datos conservados.",13,10,0
msgUnidades BYTE "Unidades disponibles: ",0
msgValor BYTE "Valor total del inventario: ",0
msgIngresos BYTE "Ingresos acumulados de esta sesion: ",0
msgCodigoEtiqueta BYTE "Codigo: ",0
msgNombreEtiqueta BYTE " | Nombre: ",0
msgPrecioEtiqueta BYTE " | Precio: ",0
msgStockEtiqueta BYTE " | Existencia: ",0
msgAlerta BYTE "ALERTA: quedan cinco unidades o menos.",13,10,0
msgSinAlertas BYTE "No hay productos con existencia minima.",13,10,0
msgGuardado BYTE "Catalogo guardado en inventario.sbi.",13,10,0
msgCargado BYTE "Catalogo validado y cargado. Los ingresos de sesion se conservan.",13,10,0
msgAusente BYTE "No se pudo abrir inventario.sbi (puede no existir). Catalogo conservado.",13,10,0
msgArchivoInvalido BYTE "Archivo invalido o danado. Catalogo anterior conservado.",13,10,0
msgErrorArchivo BYTE "Error de archivo. No se confirmo la operacion; cambios pendientes conservados.",13,10,0
msgAdios BYTE "Fin del programa.",13,10,0
sufijoMoneda BYTE " MXN",0
txtCRLF BYTE 13,10,0

IFDEF MODO_PRUEBA
; Solo en la configuracion "Prueba": las entradas se leen de un archivo y
; toda la salida se copia a otro, para repetir las pruebas sin teclear.
nombreEntradasPrueba BYTE "entradas_prueba.txt",0
nombreSalidaPrueba BYTE "salida_prueba.txt",0
msgFinPrueba BYTE 13,10,"[FIN DE LAS ENTRADAS DE PRUEBA]",13,10,0
bufferPrueba BYTE 32768 DUP(0)
posicionPrueba DWORD OFFSET bufferPrueba
handleSalidaPrueba DWORD 0
ENDIF

.code
; ---------------------------------------------------------------------
; main: sin entradas; menu persistente. Puede modificar todos los registros.
; La cadena de CMP/JE de la Unidad 2 se sustituyo por la tabla tablaOpciones.
; ---------------------------------------------------------------------
main PROC
    cld
IFDEF MODO_PRUEBA
    call IniciarPrueba
ENDIF
    mMostrar banner
    ; Si no hay archivo, LoadCatalog avisa y conserva el catalogo vacio.
    call LoadCatalog
MenuPrincipal:
    mMostrar menuTexto
    mPedirNumero pOpcion, 0, 9
    test eax, eax
    jz   SolicitarSalida
    call DWORD PTR tablaOpciones[eax*4]     ; opciones 1 a 9
    jmp  MenuPrincipal
SolicitarSalida:
    cmp  cambios, 0
    je   SalirPrograma
    mPedirNumero pSalir, 0, 2
    test eax, eax
    jz   MenuPrincipal
    cmp  eax, 2
    je   SalirPrograma
    call SaveCatalog
    test eax, eax
    jz   MenuPrincipal
SalirPrograma:
    mMostrar msgAdios
IFDEF MODO_PRUEBA
    call TerminarPrueba
ENDIF
    exit
main ENDP

; ---------------------------------------------------------------------
; Escribir (nuevo): punto unico de salida de texto.
; Recibe: EDX = cadena terminada en 0.  Devuelve: nada.
; Conserva: todos los registros (WriteString y RegistrarSalida los conservan).
; ---------------------------------------------------------------------
Escribir PROC
    call WriteString
IFDEF MODO_PRUEBA
    call RegistrarSalida
ENDIF
    ret
Escribir ENDP

; ---------------------------------------------------------------------
; Capture: lee una linea en 'entrada'.
; Recibe: EDX = mensaje.  Devuelve: EAX = longitud; texto en entrada.
; Conserva: EBX, ECX, EDX, ESI, EDI.
; ECX deja un byte para 00h. Una entrada que llena el limite no se procesa.
; ---------------------------------------------------------------------
Capture PROC USES ebx ecx edx esi edi
    call Escribir
IFDEF MODO_PRUEBA
    call LeerEntradaPrueba
ELSE
    mov  edx, OFFSET entrada
    mov  ecx, SIZEOF entrada - 1
    call ReadString
ENDIF
    cmp  eax, SIZEOF entrada - 1
    jb   CaptureFin
    mov  BYTE PTR entrada, 0
    mMostrar msgLargo
    xor  eax, eax
CaptureFin:
    ret
Capture ENDP

; ---------------------------------------------------------------------
; ParseUInt: convierte una cadena de digitos a DWORD.
; Recibe: ESI = cadena 00h.  Devuelve: EAX = valor, CF=0 valido / CF=1 error.
; Conserva: EBX, ECX, EDX, ESI, EDI. Comprueba EDX tras MUL y CF tras ADD.
; ---------------------------------------------------------------------
ParseUInt PROC USES ebx ecx edx esi edi
    xor  eax, eax
    cmp  BYTE PTR [esi], 0
    je   UIntError
    mov  ebx, 10
UIntDigito:
    movzx edi, BYTE PTR [esi]
    mSiFueraDeRango edi, '0', '9', UIntError
    sub  edi, '0'
    mul  ebx
    test edx, edx
    jnz  UIntError
    add  eax, edi
    jc   UIntError
    inc  esi
    cmp  BYTE PTR [esi], 0
    jne  UIntDigito
    clc
    ret
UIntError:
    stc
    ret
ParseUInt ENDP

; ---------------------------------------------------------------------
; AskUInt: pide un entero hasta que este en el rango.
; Recibe: EDX = mensaje, EBX = minimo, EDI = maximo.
; Devuelve: EAX = entero aceptado.
; Conserva: EBX, ECX, EDX, ESI, EDI, EBP.
; ---------------------------------------------------------------------
AskUInt PROC USES ebx ecx edx esi edi ebp
    mov  ebp, edx
AskUIntOtra:
    mov  edx, ebp
    call Capture
    mov  esi, OFFSET entrada
    call ParseUInt
    jc   AskUIntError
    cmp  eax, ebx
    jb   AskUIntError
    cmp  eax, edi
    ja   AskUIntError
    ret
AskUIntError:
    mMostrar msgInvalido
    jmp  AskUIntOtra
AskUInt ENDP

; ---------------------------------------------------------------------
; ValidateCode: comprueba el formato ABC-123 exacto.
; Recibe: ESI = cadena.  Devuelve: EAX = 1 valido / 0 invalido.
; Conserva: ECX, ESI.
; ---------------------------------------------------------------------
ValidateCode PROC USES ecx esi
    mov  ecx, 3
CodeLetras:
    mov  al, [esi]
    mSiFueraDeRango al, 'A', 'Z', CodeError
    inc  esi
    loop CodeLetras
    cmp  BYTE PTR [esi], '-'
    jne  CodeError
    inc  esi
    mov  ecx, 3
CodeDigitos:
    mov  al, [esi]
    mSiFueraDeRango al, '0', '9', CodeError
    inc  esi
    loop CodeDigitos
    cmp  BYTE PTR [esi], 0
    jne  CodeError
    mov  eax, 1
    ret
CodeError:
    xor  eax, eax
    ret
ValidateCode ENDP

; ---------------------------------------------------------------------
; ValidateName: ASCII 32..126, de 1 a 25 caracteres, no solo espacios.
; Recibe: ESI = cadena.  Devuelve: EAX = 1 valido / 0 invalido.
; Conserva: EBX, ECX, ESI.
; ---------------------------------------------------------------------
ValidateName PROC USES ebx ecx esi
    xor  ecx, ecx
    xor  ebx, ebx
NameCaracter:
    mov  al, [esi]
    cmp  al, 0
    je   NameFinal
    inc  ecx
    cmp  ecx, 25
    ja   NameError
    mSiFueraDeRango al, 32, 126, NameError
    cmp  al, 32
    je   NameAvanzar
    mov  ebx, 1
NameAvanzar:
    inc  esi
    jmp  NameCaracter
NameFinal:
    cmp  ecx, 0
    je   NameError
    mov  eax, ebx
    ret
NameError:
    xor  eax, eax
    ret
ValidateName ENDP

; ---------------------------------------------------------------------
; ParseMoney: convierte un precio en pesos a centavos.
; Recibe: ESI = texto.  Devuelve: EAX = centavos, CF=0 valido / CF=1 error.
; Ejemplos: 185.50=18550, 12.05=1205, 12.5=1250, 229=22900.
; Conserva: EBX, ECX, EDX, ESI, EDI, EBP. No usa coma ni punto flotante.
; ---------------------------------------------------------------------
ParseMoney PROC USES ebx ecx edx esi edi ebp
    xor  eax, eax
    xor  ecx, ecx
MoneyEnteros:
    movzx ebx, BYTE PTR [esi]
    cmp  ebx, 0
    je   MoneySinFraccion
    cmp  ebx, '.'
    je   MoneyPunto
    mSiFueraDeRango ebx, '0', '9', MoneyError
    sub  ebx, '0'
    imul eax, eax, 10
    jo   MoneyError
    add  eax, ebx
    jc   MoneyError
    cmp  eax, 9999
    ja   MoneyError
    inc  ecx
    inc  esi
    jmp  MoneyEnteros
MoneyPunto:
    test ecx, ecx
    jz   MoneyError
    inc  esi
    xor  edi, edi
    xor  ebp, ebp
MoneyFraccion:
    movzx ebx, BYTE PTR [esi]
    test ebx, ebx
    jz   MoneyFinalFraccion
    mSiFueraDeRango ebx, '0', '9', MoneyError
    inc  ebp
    cmp  ebp, 2
    ja   MoneyError
    sub  ebx, '0'
    imul edi, edi, 10
    add  edi, ebx
    inc  esi
    jmp  MoneyFraccion
MoneyFinalFraccion:
    test ebp, ebp
    jz   MoneyError
    cmp  ebp, 1
    jne  MoneyCombinar
    imul edi, edi, 10
MoneyCombinar:
    imul eax, eax, 100
    jo   MoneyError
    add  eax, edi
    jc   MoneyError
    jmp  MoneyRango
MoneySinFraccion:
    test ecx, ecx
    jz   MoneyError
    imul eax, eax, 100
    jo   MoneyError
MoneyRango:
    cmp  eax, 1
    jb   MoneyError
    cmp  eax, 999999
    ja   MoneyError
    clc
    ret
MoneyError:
    stc
    ret
ParseMoney ENDP

; ---------------------------------------------------------------------
; UIntToString: escribe un DWORD en decimal.
; Recibe: EAX = valor, EDI = buffer de al menos 11 bytes.
; Devuelve: texto 00h en el buffer.
; Conserva: EAX, EBX, ECX, EDX, EDI (antes PUSHAD/POPAD).
; El cuerpo se ejecuta una vez incluso para 0. Cada PUSH tiene su POP.
; ---------------------------------------------------------------------
UIntToString PROC USES eax ebx ecx edx edi
    mov  ebx, 10
    xor  ecx, ecx
DecimalExtraer:
    xor  edx, edx
    div  ebx
    push edx
    inc  ecx
    test eax, eax
    jnz  DecimalExtraer
DecimalGuardar:
    pop  edx
    add  dl, '0'
    mov  [edi], dl
    inc  edi
    loop DecimalGuardar
    mov  BYTE PTR [edi], 0
    ret
UIntToString ENDP

; ---------------------------------------------------------------------
; PrintUInt: muestra EAX en decimal.
; Recibe: EAX = valor.  Conserva: EDX, EDI (EAX no se modifica).
; ---------------------------------------------------------------------
PrintUInt PROC USES edx edi
    mov  edi, OFFSET numeroTexto
    call UIntToString
    mov  edx, OFFSET numeroTexto
    call Escribir
    ret
PrintUInt ENDP

; ---------------------------------------------------------------------
; PrintMoney: muestra centavos como pesos con dos decimales y " MXN".
; Recibe: EAX = centavos. DIV 100: EAX = pesos, EDX = centavos.
; Conserva: EAX, EBX, EDX, ESI, EDI.
; ---------------------------------------------------------------------
PrintMoney PROC USES eax ebx edx esi edi
    xor  edx, edx
    mov  ebx, 100
    div  ebx
    push edx                        ; centavos
    mov  edi, OFFSET precioTexto
    call UIntToString
    mov  esi, OFFSET precioTexto
MoneyBuscarFin:
    cmp  BYTE PTR [esi], 0
    je   MoneyEscribirPunto
    inc  esi
    jmp  MoneyBuscarFin
MoneyEscribirPunto:
    mov  BYTE PTR [esi], '.'
    inc  esi
    pop  eax                        ; equilibra el PUSH de los centavos
    xor  edx, edx
    mov  ebx, 10
    div  ebx
    add  al, '0'
    add  dl, '0'
    mov  [esi], al
    mov  [esi+1], dl
    mov  BYTE PTR [esi+2], 0
    mMostrar precioTexto
    mMostrar sufijoMoneda
    ret
PrintMoney ENDP

; ---------------------------------------------------------------------
; CompararCodigo (nuevo): compara dos codigos de 8 bytes.
; Recibe: ESI, EDI = direcciones de los codigos.
; Devuelve: EAX = 1 iguales / 0 distintos.
; Conserva: ECX, EDX.
; Antes este ciclo estaba repetido en FindProduct y ValidateFile.
; ---------------------------------------------------------------------
CompararCodigo PROC USES ecx edx
    xor  ecx, ecx
CompararByte:
    mov  dl, [esi+ecx]
    cmp  dl, [edi+ecx]
    jne  CompararDistintos
    inc  ecx
    cmp  ecx, TAM_CODIGO
    jb   CompararByte
    mov  eax, 1
    ret
CompararDistintos:
    xor  eax, eax
    ret
CompararCodigo ENDP

; ---------------------------------------------------------------------
; FindProduct: busca un codigo en el catalogo.
; Recibe: EDX = codigo validado.  Devuelve: EAX = puntero al producto o 0.
; Conserva: EBX, ESI, EDI.
; ---------------------------------------------------------------------
FindProduct PROC USES ebx esi edi
    mov  edi, edx
    mov  esi, OFFSET catalogo
    mov  ebx, cantidadProductos
FindSiguiente:
    test ebx, ebx
    jz   FindNo
    call CompararCodigo
    test eax, eax
    jz   FindAvanzar
    mov  eax, esi
    ret
FindAvanzar:
    add  esi, TAM_REG
    dec  ebx
    jmp  FindSiguiente
FindNo:
    xor  eax, eax
    ret
FindProduct ENDP

; ---------------------------------------------------------------------
; PedirCodigoValido (nuevo): pide un codigo hasta que tenga formato ABC-123.
; Devuelve: el codigo en 'entrada'.  Conserva: EAX, EDX, ESI.
; Antes esta captura estaba duplicada en RegisterProduct y AskProduct.
; ---------------------------------------------------------------------
PedirCodigoValido PROC USES eax edx esi
PedirCodigoOtra:
    mCapturar pCodigo
    call ValidateCode
    mValidarOReintentar msgCodigo, PedirCodigoOtra
    ret
PedirCodigoValido ENDP

; ---------------------------------------------------------------------
; AskProduct: pide un codigo existente.
; Devuelve: EAX = puntero al producto, o 0 si el catalogo esta vacio.
; Conserva: EDX. Repite ante codigo incorrecto o inexistente.
; ---------------------------------------------------------------------
AskProduct PROC USES edx
    cmp  cantidadProductos, 0
    je   AskProductVacio
AskProductOtra:
    call PedirCodigoValido
    mov  edx, OFFSET entrada
    call FindProduct
    mValidarOReintentar msgNoExiste, AskProductOtra
    ret
AskProductVacio:
    mMostrar msgVacio
    xor  eax, eax
    ret
AskProduct ENDP

; ---------------------------------------------------------------------
; RegisterProduct: alta de un producto. Sin entradas ni salidas.
; Conserva: EAX, EBX, ECX, EDX, ESI, EDI (antes PUSHAD/POPAD).
; Se construye nuevoProducto y se confirma solo al validar TODOS los campos.
; ---------------------------------------------------------------------
RegisterProduct PROC USES eax ebx ecx edx esi edi
    cmp  cantidadProductos, MAX_PRODUCTOS
    jae  RegisterLleno
    mLlenarCeros OFFSET nuevoProducto, TAM_REG
RegisterCodigo:
    call PedirCodigoValido
    mov  edx, OFFSET entrada
    call FindProduct
    test eax, eax
    jz   RegisterCodigoLibre
    mMostrar msgDuplicado
    jmp  RegisterCodigo
RegisterCodigoLibre:
    mCopiarBytes OFFSET nuevoProducto, OFFSET entrada, TAM_CODIGO
RegisterNombre:
    mCapturar pNombre
    call ValidateName
    mValidarOReintentar msgNombre, RegisterNombre
    mov  edi, OFFSET nuevoProducto + P_NOMBRE
RegisterCopiarNombre:
    mov  al, [esi]
    mov  [edi], al
    inc  esi
    inc  edi
    test al, al
    jnz  RegisterCopiarNombre
RegisterPrecio:
    mCapturar pPrecio
    call ParseMoney
    jnc  RegisterPrecioValido
    mMostrar msgPrecio
    jmp  RegisterPrecio
RegisterPrecioValido:
    mov  DWORD PTR nuevoProducto[P_PRECIO], eax
    mPedirNumero pStock, 0, MAX_EXISTENCIA
    mov  DWORD PTR nuevoProducto[P_STOCK], eax
    ; Confirmacion del alta: antes de aqui no se cambio el catalogo.
    mov  eax, cantidadProductos
    imul eax, eax, TAM_REG
    add  eax, OFFSET catalogo
    mCopiarBytes eax, OFFSET nuevoProducto, TAM_REG
    inc  cantidadProductos
    mov  cambios, 1
    mMostrar msgAlta
    ret
RegisterLleno:
    mMostrar msgLleno
    ret
RegisterProduct ENDP

; ---------------------------------------------------------------------
; PrintProduct: muestra todos los campos del registro.
; Recibe: ESI = puntero al registro.  Conserva: EAX, EDX.
; ---------------------------------------------------------------------
PrintProduct PROC USES eax edx
    mMostrarCampo msgCodigoEtiqueta, P_CODIGO
    mMostrarCampo msgNombreEtiqueta, P_NOMBRE
    mMostrar msgPrecioEtiqueta
    mov  eax, [esi+P_PRECIO]
    call PrintMoney
    mMostrarValor msgStockEtiqueta, [esi+P_STOCK], PrintUInt
    ret
PrintProduct ENDP

; ---------------------------------------------------------------------
; ListInventory: muestra el catalogo; recorre con ESI += 44.
; Conserva: ECX, EDX, ESI. PrintProduct conserva ECX, por eso ya no se
; necesita el PUSH/POP de la Unidad 2 alrededor de la llamada.
; ---------------------------------------------------------------------
ListInventory PROC USES ecx edx esi
    cmp  cantidadProductos, 0
    je   ListVacia
    mov  esi, OFFSET catalogo
    mov  ecx, cantidadProductos
ListSiguiente:
    call PrintProduct
    add  esi, TAM_REG
    loop ListSiguiente
    ret
ListVacia:
    mMostrar msgVacio
    ret
ListInventory ENDP

; ---------------------------------------------------------------------
; SearchProduct: busca y muestra un producto. Conserva: EAX, ESI.
; ---------------------------------------------------------------------
SearchProduct PROC USES eax esi
    call AskProduct
    test eax, eax
    jz   SearchFin
    mov  esi, eax
    call PrintProduct
SearchFin:
    ret
SearchProduct ENDP

; ---------------------------------------------------------------------
; ReceiveStock: entrada de mercancia; suma solo despues de validar el
; limite y el acarreo. Conserva: EAX, EBX, EDX, ESI, EDI.
; ---------------------------------------------------------------------
ReceiveStock PROC USES eax ebx edx esi edi
    call AskProduct
    test eax, eax
    jz   ReceiveFin
    mov  esi, eax
ReceiveCantidad:
    mPedirNumero pCantidad, 1, MAX_EXISTENCIA
    add  eax, [esi+P_STOCK]
    jc   ReceiveOverflow
    cmp  eax, MAX_EXISTENCIA
    ja   ReceiveExceso
    mov  [esi+P_STOCK], eax
    mov  cambios, 1
    mMostrarValor msgEntrada, [esi+P_STOCK], PrintUInt
    ret
ReceiveExceso:
    mMostrar msgExceso
    jmp  ReceiveCantidad
ReceiveOverflow:
    mMostrar msgOverflow
ReceiveFin:
    ret
ReceiveStock ENDP

; ---------------------------------------------------------------------
; SellProduct: valida todo antes de cambiar existencia e ingresos.
; Conserva: EAX, EBX, EDX, ESI, EDI.
; MUL: EDX:EAX = precio*cantidad; EDX != 0 significa que no cabe en DWORD.
; ADD: CF detecta desbordamiento sin signo en los ingresos acumulados.
; ---------------------------------------------------------------------
SellProduct PROC USES eax ebx edx esi edi
    call AskProduct
    test eax, eax
    jz   SellFin
    mov  esi, eax
    cmp  DWORD PTR [esi+P_STOCK], 0
    je   SellSinStock
SellCantidad:
    mPedirNumero pCantidad, 1, MAX_EXISTENCIA
    cmp  eax, [esi+P_STOCK]
    ja   SellInsuficiente
    mov  ventaCantidad, eax
    mul  DWORD PTR [esi+P_PRECIO]
    test edx, edx
    jnz  SellOverflow
    mov  ventaImporte, eax
    add  eax, ingresosSesion
    jc   SellOverflow
    mov  ventaIngresos, eax
    mov  eax, [esi+P_STOCK]
    sub  eax, ventaCantidad
    jc   SellOverflow
    ; Confirmacion: ambas cantidades nuevas ya se comprobaron.
    mov  [esi+P_STOCK], eax
    mov  eax, ventaIngresos
    mov  ingresosSesion, eax
    mov  cambios, 1
    mMostrarValor msgVenta, ventaImporte, PrintMoney
    cmp  DWORD PTR [esi+P_STOCK], EXISTENCIA_MINIMA
    ja   SellFin
    mMostrar msgAlerta
    ret
SellInsuficiente:
    mMostrar msgInsuficiente
    jmp  SellCantidad
SellSinStock:
    mMostrar msgSinStock
    ret
SellOverflow:
    mMostrar msgOverflow
SellFin:
    ret
SellProduct ENDP

; ---------------------------------------------------------------------
; ShowSummary: suma unidades y precio*existencia; muestra ingresos.
; Conserva: EAX, ECX, EDX, ESI. Las variables total* son temporales.
; ---------------------------------------------------------------------
ShowSummary PROC USES eax ecx edx esi
    mov  totalUnidades, 0
    mov  totalValor, 0
    mov  esi, OFFSET catalogo
    mov  ecx, cantidadProductos
    jecxz SummaryMostrar
SummarySiguiente:
    mov  eax, [esi+P_STOCK]
    add  totalUnidades, eax
    jc   SummaryOverflow
    mul  DWORD PTR [esi+P_PRECIO]
    test edx, edx
    jnz  SummaryOverflow
    add  totalValor, eax
    jc   SummaryOverflow
    add  esi, TAM_REG
    loop SummarySiguiente
SummaryMostrar:
    mMostrarValor msgUnidades, totalUnidades, PrintUInt
    mMostrarValor msgValor, totalValor, PrintMoney
    mMostrarValor msgIngresos, ingresosSesion, PrintMoney
    ret
SummaryOverflow:
    mMostrar msgOverflow
    ret
ShowSummary ENDP

; ---------------------------------------------------------------------
; LowStockAlerts: regla adicional; muestra productos con existencia <= 5
; (incluye 0). No cambia datos. Conserva: EBX, ECX, EDX, ESI.
; ---------------------------------------------------------------------
LowStockAlerts PROC USES ebx ecx edx esi
    mov  esi, OFFSET catalogo
    mov  ecx, cantidadProductos
    xor  ebx, ebx
    jecxz AlertsFinal
AlertsSiguiente:
    cmp  DWORD PTR [esi+P_STOCK], EXISTENCIA_MINIMA
    ja   AlertsAvanzar
    call PrintProduct
    inc  ebx
AlertsAvanzar:
    add  esi, TAM_REG
    loop AlertsSiguiente
AlertsFinal:
    test ebx, ebx
    jnz  AlertsFin
    mMostrar msgSinAlertas
AlertsFin:
    ret
LowStockAlerts ENDP

; ---------------------------------------------------------------------
; ConfirmLoad (nuevo): opcion 9. Si hay cambios pendientes pide confirmar
; antes de cargar. Antes este bloque estaba dentro de main.
; Conserva: EBX, EDX, EDI. EAX se modifica (main no lo usa).
; ---------------------------------------------------------------------
ConfirmLoad PROC USES ebx edx edi
    cmp  cambios, 0
    je   ConfirmCargar
    mPedirNumero pCargar, 0, 1
    test eax, eax
    jz   ConfirmFin
ConfirmCargar:
    call LoadCatalog
ConfirmFin:
    ret
ConfirmLoad ENDP

; ---------------------------------------------------------------------
; Checksum: suma de bytes.
; Recibe: ESI = datos, ECX = numero de bytes.  Devuelve: EAX = suma.
; Conserva: EBX, ECX, ESI. Con <= 440 bytes no hay overflow de DWORD.
; Es un detector simple de errores accidentales, no una firma.
; ---------------------------------------------------------------------
Checksum PROC USES ebx ecx esi
    xor  eax, eax
    jecxz ChecksumFin
ChecksumSiguiente:
    movzx ebx, BYTE PTR [esi]
    add  eax, ebx
    inc  esi
    loop ChecksumSiguiente
ChecksumFin:
    ret
Checksum ENDP

; ---------------------------------------------------------------------
; SaveCatalog: guarda el catalogo.
; Devuelve: EAX = 1 exito / 0 error.  Conserva: EBX, ECX, EDX, ESI, EDI.
; Cabecera: firma[8], count DWORD, checksum DWORD. Despues count*44 bytes.
; Escribe un temporal, comprueba bytes y cierre, y solo entonces lo reemplaza.
; ---------------------------------------------------------------------
SaveCatalog PROC USES ebx ecx edx esi edi
    mCopiarBytes OFFSET archivoBuffer, OFFSET firma, TAM_CODIGO
    mov  eax, cantidadProductos
    mov  DWORD PTR archivoBuffer[8], eax
    imul ebx, eax, TAM_REG                  ; EBX = bytes de los registros
    lea  eax, [ebx + TAM_CAB]
    mov  bytesArchivo, eax
    mCopiarBytes OFFSET archivoBuffer + TAM_CAB, OFFSET catalogo, ebx
    mov  ecx, ebx
    mov  esi, OFFSET archivoBuffer + TAM_CAB
    call Checksum
    mov  DWORD PTR archivoBuffer[12], eax
    mov  edx, OFFSET nombreTemporal
    call CreateOutputFile
    cmp  eax, INVALID_HANDLE_VALUE
    je   SaveError
    mov  handleActual, eax
    mov  edx, OFFSET archivoBuffer
    mov  ecx, bytesArchivo
    call WriteToFile
    jc   SaveCerrarError
    cmp  eax, bytesArchivo
    jne  SaveCerrarError
    mCerrarArchivoActual
    test eax, eax
    jz   SaveError
    ; 9 = MOVEFILE_REPLACE_EXISTING + MOVEFILE_WRITE_THROUGH.
    INVOKE MoveFileExA, OFFSET nombreTemporal, OFFSET nombreArchivo, 9
    test eax, eax
    jz   SaveError
    mov  cambios, 0
    mMostrar msgGuardado
    mov  eax, 1
    ret
SaveCerrarError:
    mCerrarArchivoActual
SaveError:
    mMostrar msgErrorArchivo
    xor  eax, eax
    ret
SaveCatalog ENDP

; ---------------------------------------------------------------------
; ValidateFile: valida archivoBuffer (bytesArchivo ya capturado).
; Devuelve: EAX = 1 valido / 0 invalido. conteoCandidato se usa si EAX=1.
; Conserva: EBX, ECX, EDX, ESI, EDI, EBP.
; Revisa firma, count, tamano EXACTO, checksum, campos, relleno y duplicados.
; El catalogo activo NO se usa como destino de ninguna escritura aqui.
; ---------------------------------------------------------------------
ValidateFile PROC USES ebx ecx edx esi edi ebp
    cmp  bytesArchivo, TAM_CAB
    jb   FileInvalid
    cmp  bytesArchivo, MAX_ARCHIVO
    ja   FileInvalid
    mov  esi, OFFSET archivoBuffer
    mov  edi, OFFSET firma
    mov  ecx, TAM_CODIGO
    cld
    repe cmpsb
    jne  FileInvalid
    mov  eax, DWORD PTR archivoBuffer[8]
    cmp  eax, MAX_PRODUCTOS
    ja   FileInvalid
    mov  conteoCandidato, eax
    imul eax, eax, TAM_REG
    mov  ecx, eax
    add  eax, TAM_CAB
    cmp  eax, bytesArchivo
    jne  FileInvalid
    mov  esi, OFFSET archivoBuffer + TAM_CAB
    call Checksum
    cmp  eax, DWORD PTR archivoBuffer[12]
    jne  FileInvalid
    mov  esi, OFFSET archivoBuffer + TAM_CAB
    xor  ebp, ebp
FileRegistro:
    cmp  ebp, conteoCandidato
    jae  FileValid
    call ValidateCode
    test eax, eax
    jz   FileInvalid
    ; ValidateName conserva ESI: guardar y recuperar el puntero del registro.
    push esi
    add  esi, P_NOMBRE
    call ValidateName
    pop  esi
    test eax, eax
    jz   FileInvalid
    ; Tras el primer 00h del nombre, el resto del campo debe ser 0.
    mov  edi, 0
FileBuscarNulo:
    cmp  BYTE PTR [esi+edi+P_NOMBRE], 0
    je   FileRelleno
    inc  edi
    cmp  edi, 26
    jb   FileBuscarNulo
    jmp  FileInvalid
FileRelleno:
    cmp  edi, 28
    jae  FileNumeros
    cmp  BYTE PTR [esi+edi+P_NOMBRE], 0
    jne  FileInvalid
    inc  edi
    jmp  FileRelleno
FileNumeros:
    cmp  DWORD PTR [esi+P_PRECIO], 1
    jb   FileInvalid
    cmp  DWORD PTR [esi+P_PRECIO], 999999
    ja   FileInvalid
    cmp  DWORD PTR [esi+P_STOCK], MAX_EXISTENCIA
    ja   FileInvalid
    ; Buscar duplicados solamente entre los registros anteriores.
    mov  edi, OFFSET archivoBuffer + TAM_CAB
    mov  ebx, ebp
FilePrevio:
    test ebx, ebx
    jz   FileAvanzar
    call CompararCodigo
    test eax, eax
    jnz  FileInvalid
    add  edi, TAM_REG
    dec  ebx
    jmp  FilePrevio
FileAvanzar:
    add  esi, TAM_REG
    inc  ebp
    jmp  FileRegistro
FileValid:
    mov  eax, 1
    ret
FileInvalid:
    xor  eax, eax
    ret
ValidateFile ENDP

; ---------------------------------------------------------------------
; LoadCatalog: carga y valida inventario.sbi.
; Devuelve: EAX = 1 cargado / 0 error.  Conserva: EBX, ECX, EDX, ESI, EDI.
; Lee el maximo permitido + 1: un archivo con bytes extra se rechaza.
; Confirma el nuevo catalogo SOLO despues de leer, cerrar y validar TODO.
; ingresosSesion nunca se carga ni se reinicia mediante esta opcion.
; ---------------------------------------------------------------------
LoadCatalog PROC USES ebx ecx edx esi edi
    mov  edx, OFFSET nombreArchivo
    call OpenInputFile
    cmp  eax, INVALID_HANDLE_VALUE
    je   LoadAusente
    mov  handleActual, eax
    mov  edx, OFFSET archivoBuffer
    mov  ecx, SIZEOF archivoBuffer
    call ReadFromFile
    jc   LoadCerrarError
    mov  bytesArchivo, eax
    mCerrarArchivoActual
    test eax, eax
    jz   LoadError
    call ValidateFile
    test eax, eax
    jz   LoadInvalid
    ; Confirmar el reemplazo del catalogo y limpiar los registros no usados.
    mLlenarCeros OFFSET catalogo, TAM_CATALOGO
    mov  eax, conteoCandidato
    mov  cantidadProductos, eax
    imul ebx, eax, TAM_REG
    mCopiarBytes OFFSET catalogo, OFFSET archivoBuffer + TAM_CAB, ebx
    mov  cambios, 0
    mMostrar msgCargado
    mov  eax, 1
    ret
LoadCerrarError:
    mCerrarArchivoActual
LoadError:
    mov  edx, OFFSET msgErrorArchivo
    jmp  LoadAviso
LoadAusente:
    mov  edx, OFFSET msgAusente
    jmp  LoadAviso
LoadInvalid:
    mov  edx, OFFSET msgArchivoInvalido
LoadAviso:
    call Escribir
    xor  eax, eax
    ret
LoadCatalog ENDP

IFDEF MODO_PRUEBA
; =====================================================================
; Modo de prueba (solo en la configuracion "Prueba" de Visual Studio).
; No forma parte de la version que se entrega al usuario final: con la
; configuracion Debug estas lineas no se ensamblan.
; =====================================================================

; IniciarPrueba: carga entradas_prueba.txt y crea salida_prueba.txt.
; Conserva: todos menos EAX, ECX, EDX.
IniciarPrueba PROC
    mov  edx, OFFSET nombreEntradasPrueba
    call OpenInputFile
    cmp  eax, INVALID_HANDLE_VALUE
    je   IniciarSalida
    mov  handleActual, eax
    mov  edx, OFFSET bufferPrueba
    mov  ecx, SIZEOF bufferPrueba - 1
    call ReadFromFile
    mCerrarArchivoActual
IniciarSalida:
    mov  edx, OFFSET nombreSalidaPrueba
    call CreateOutputFile
    cmp  eax, INVALID_HANDLE_VALUE
    je   IniciarFin
    mov  handleSalidaPrueba, eax
IniciarFin:
    ret
IniciarPrueba ENDP

; RegistrarSalida: copia la cadena EDX al archivo de salida de prueba.
; Conserva: todos los registros.
RegistrarSalida PROC USES eax ecx edx
    cmp  handleSalidaPrueba, 0
    je   RegistrarFin
    INVOKE Str_length, edx
    mov  ecx, eax
    mov  eax, handleSalidaPrueba
    call WriteToFile
RegistrarFin:
    ret
RegistrarSalida ENDP

; LeerEntradaPrueba: copia la siguiente linea del archivo a 'entrada' y la
; muestra (eco). Devuelve: EAX = longitud. Conserva: ECX, EDX, ESI, EDI.
; Si ya no hay lineas, termina el programa.
LeerEntradaPrueba PROC USES ecx edx esi edi
    mov  esi, posicionPrueba
    cmp  BYTE PTR [esi], 0
    je   LeerAgotado
    mov  edi, OFFSET entrada
    xor  ecx, ecx
LeerCaracter:
    mov  al, [esi]
    cmp  al, 0
    je   LeerFinLinea
    inc  esi
    cmp  al, 13
    je   LeerCaracter
    cmp  al, 10
    je   LeerFinLinea
    cmp  ecx, SIZEOF entrada - 2
    jae  LeerCaracter
    mov  [edi], al
    inc  edi
    inc  ecx
    jmp  LeerCaracter
LeerFinLinea:
    mov  BYTE PTR [edi], 0
    mov  posicionPrueba, esi
    mMostrar entrada
    mSalto
    mov  eax, ecx
    ret
LeerAgotado:
    mMostrar msgFinPrueba
    call TerminarPrueba
    exit
LeerEntradaPrueba ENDP

; TerminarPrueba: cierra el archivo de salida de prueba.
TerminarPrueba PROC USES eax
    mov  eax, handleSalidaPrueba
    test eax, eax
    jz   TerminarFin
    call CloseFile
    mov  handleSalidaPrueba, 0
TerminarFin:
    ret
TerminarPrueba ENDP
ENDIF

END main
