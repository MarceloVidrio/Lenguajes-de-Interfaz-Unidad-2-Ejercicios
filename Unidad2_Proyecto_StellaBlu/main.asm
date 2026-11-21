; Materia: Lenguajes de Interfaz - Unidad 2
; Proyecto: Stella Blu - Ventas e inventario de gorras
; Integrantes: [MARCELO VIDRIO OCHOA]
; Horario: [8:00-9:00]
; Docente: Dr. Jose Luis Medina Jimenez


INCLUDE Irvine32.inc
; Funcion adicional de Windows: reemplaza el archivo solo tras escribir y cerrar.
MoveFileExA PROTO STDCALL, origen:DWORD, destino:DWORD, indicadores:DWORD

MAX_PRODUCTOS = 10
TAM_REG = 44
P_CODIGO = 0
P_NOMBRE = 8
P_PRECIO = 36
P_STOCK = 40
TAM_CATALOGO = MAX_PRODUCTOS * TAM_REG
TAM_CAB = 16
MAX_ARCHIVO = TAM_CAB + TAM_CATALOGO

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

.code
; main: sin entradas; menu persistente. Puede modificar todos los registros.
main PROC
    cld
    mov edx, OFFSET banner
    call WriteString
    ; Si no hay archivo, LoadCatalog avisa y conserva el catalogo vacio.
    call LoadCatalog
MenuPrincipal:
    mov edx, OFFSET menuTexto
    call WriteString
    mov edx, OFFSET pOpcion
    mov ebx, 0
    mov edi, 9
    call AskUInt
    cmp eax, 0
    je SolicitarSalida
    cmp eax, 1
    je OpcionAlta
    cmp eax, 2
    je OpcionLista
    cmp eax, 3
    je OpcionBusqueda
    cmp eax, 4
    je OpcionEntrada
    cmp eax, 5
    je OpcionVenta
    cmp eax, 6
    je OpcionResumen
    cmp eax, 7
    je OpcionAlertas
    cmp eax, 8
    je OpcionGuardar
    ; La unica opcion restante es 9.
    cmp cambios, 0
    je CargarDirecto
    mov edx, OFFSET pCargar
    mov ebx, 0
    mov edi, 1
    call AskUInt
    test eax, eax
    jz MenuPrincipal
CargarDirecto:
    call LoadCatalog
    jmp MenuPrincipal
OpcionAlta:
    call RegisterProduct
    jmp MenuPrincipal
OpcionLista:
    call ListInventory
    jmp MenuPrincipal
OpcionBusqueda:
    call SearchProduct
    jmp MenuPrincipal
OpcionEntrada:
    call ReceiveStock
    jmp MenuPrincipal
OpcionVenta:
    call SellProduct
    jmp MenuPrincipal
OpcionResumen:
    call ShowSummary
    jmp MenuPrincipal
OpcionAlertas:
    call LowStockAlerts
    jmp MenuPrincipal
OpcionGuardar:
    call SaveCatalog
    jmp MenuPrincipal
SolicitarSalida:
    cmp cambios, 0
    je SalirPrograma
    mov edx, OFFSET pSalir
    mov ebx, 0
    mov edi, 2
    call AskUInt
    cmp eax, 0
    je MenuPrincipal
    cmp eax, 2
    je SalirPrograma
    call SaveCatalog
    test eax, eax
    jz MenuPrincipal
SalirPrograma:
    mov edx, OFFSET msgAdios
    call WriteString
    exit
main ENDP

; Capture: EDX=mensaje. EAX=longitud; texto en entrada. Conserva otros registros.
; ECX deja un byte para 00h. Una entrada que llena el limite no se procesa.
Capture PROC USES ebx ecx edx esi edi
    call WriteString
    mov edx, OFFSET entrada
    mov ecx, SIZEOF entrada - 1
    call ReadString
    cmp eax, SIZEOF entrada - 1
    jb CaptureFin
    mov BYTE PTR entrada, 0
    mov edx, OFFSET msgLargo
    call WriteString
    xor eax, eax
CaptureFin:
    ret
Capture ENDP

; ParseUInt: ESI=cadena 00h. EAX=DWORD, CF=0 valido / CF=1 error.
; Acepta solo digitos; comprueba EDX tras MUL y CF tras ADD.
; Conserva EBX,ECX,EDX,ESI,EDI. Nunca actualiza el catalogo.
ParseUInt PROC USES ebx ecx edx esi edi
    xor eax, eax
    cmp BYTE PTR [esi], 0
    je UIntError
    mov ebx, 10
UIntDigito:
    movzx edi, BYTE PTR [esi]
    cmp edi, '0'
    jb UIntError
    cmp edi, '9'
    ja UIntError
    sub edi, '0'
    mul ebx
    test edx, edx
    jnz UIntError
    add eax, edi
    jc UIntError
    inc esi
    cmp BYTE PTR [esi], 0
    jne UIntDigito
    clc
    ret
UIntError:
    stc
    ret
ParseUInt ENDP

; AskUInt: EDX=prompt, EBX=minimo, EDI=maximo. EAX=entero aceptado.
; Repite ante formato/rango invalido. Conserva los otros registros.
AskUInt PROC USES ebx ecx edx esi edi ebp
    mov ebp, edx
AskUIntOtra:
    mov edx, ebp
    call Capture
    mov esi, OFFSET entrada
    call ParseUInt
    jc AskUIntError
    cmp eax, ebx
    jb AskUIntError
    cmp eax, edi
    ja AskUIntError
    ret
AskUIntError:
    mov edx, OFFSET msgInvalido
    call WriteString
    jmp AskUIntOtra
AskUInt ENDP

; ValidateCode: ESI=cadena; EAX=1 si es ABC-123 exacto, 0 si invalido.
; Conserva todos los registros salvo EAX. Rechaza mas/menos de siete caracteres.
ValidateCode PROC USES ebx ecx edx esi edi
    mov ecx, 3
CodeLetras:
    mov al, [esi]
    cmp al, 'A'
    jb CodeError
    cmp al, 'Z'
    ja CodeError
    inc esi
    loop CodeLetras
    cmp BYTE PTR [esi], '-'
    jne CodeError
    inc esi
    mov ecx, 3
CodeDigitos:
    mov al, [esi]
    cmp al, '0'
    jb CodeError
    cmp al, '9'
    ja CodeError
    inc esi
    loop CodeDigitos
    cmp BYTE PTR [esi], 0
    jne CodeError
    mov eax, 1
    ret
CodeError:
    xor eax, eax
    ret
ValidateCode ENDP

; ValidateName: ESI=cadena; EAX=1 valido / 0 invalido. Conserva otros.
; ASCII 32..126; de 1 a 25 caracteres; no acepta solo espacios.
ValidateName PROC USES ebx ecx edx esi edi
    xor ecx, ecx
    xor ebx, ebx
NameCaracter:
    mov al, [esi]
    cmp al, 0
    je NameFinal
    inc ecx
    cmp ecx, 25
    ja NameError
    cmp al, 32
    jb NameError
    cmp al, 126
    ja NameError
    cmp al, 32
    je NameAvanzar
    mov ebx, 1
NameAvanzar:
    inc esi
    jmp NameCaracter
NameFinal:
    cmp ecx, 0
    je NameError
    mov eax, ebx
    ret
NameError:
    xor eax, eax
    ret
ValidateName ENDP

; ParseMoney: ESI=precio en pesos; EAX=centavos y CF=0, o CF=1 error.
; Ejemplos: 185.50=18550, 12.05=1205, 12.5=1250, 229=22900.
; Sintaxis: al menos un digito entero y, opcionalmente, punto y 1-2 decimales.
; Conserva EBX,ECX,EDX,ESI,EDI,EBP. No usa coma ni aritmetica flotante.
ParseMoney PROC USES ebx ecx edx esi edi ebp
    xor eax, eax
    xor ecx, ecx
MoneyEnteros:
    movzx ebx, BYTE PTR [esi]
    cmp ebx, 0
    je MoneySinFraccion
    cmp ebx, '.'
    je MoneyPunto
    cmp ebx, '0'
    jb MoneyError
    cmp ebx, '9'
    ja MoneyError
    sub ebx, '0'
    imul eax, eax, 10
    jo MoneyError
    add eax, ebx
    jc MoneyError
    cmp eax, 9999
    ja MoneyError
    inc ecx
    inc esi
    jmp MoneyEnteros
MoneyPunto:
    test ecx, ecx
    jz MoneyError
    inc esi
    xor edi, edi
    xor ebp, ebp
MoneyFraccion:
    movzx ebx, BYTE PTR [esi]
    test ebx, ebx
    jz MoneyFinalFraccion
    cmp ebx, '0'
    jb MoneyError
    cmp ebx, '9'
    ja MoneyError
    inc ebp
    cmp ebp, 2
    ja MoneyError
    sub ebx, '0'
    imul edi, edi, 10
    add edi, ebx
    inc esi
    jmp MoneyFraccion
MoneyFinalFraccion:
    test ebp, ebp
    jz MoneyError
    cmp ebp, 1
    jne MoneyCombinar
    imul edi, edi, 10
MoneyCombinar:
    imul eax, eax, 100
    jo MoneyError
    add eax, edi
    jc MoneyError
    jmp MoneyRango
MoneySinFraccion:
    test ecx, ecx
    jz MoneyError
    imul eax, eax, 100
    jo MoneyError
MoneyRango:
    cmp eax, 1
    jb MoneyError
    cmp eax, 999999
    ja MoneyError
    clc
    ret
MoneyError:
    stc
    ret
ParseMoney ENDP

; UIntToString: EAX=DWORD sin signo, EDI=buffer >=11 bytes.
; Escribe texto decimal 00h y conserva TODOS los registros con PUSHAD/POPAD.
; El cuerpo se ejecuta una vez incluso para 0. Cada PUSH tiene su POP.
UIntToString PROC
    pushad
    mov ebx, 10
    xor ecx, ecx
DecimalExtraer:
    xor edx, edx
    div ebx
    push edx
    inc ecx
    test eax, eax
    jnz DecimalExtraer
DecimalGuardar:
    pop edx
    add dl, '0'
    mov [edi], dl
    inc edi
    loop DecimalGuardar
    mov BYTE PTR [edi], 0
    popad
    ret
UIntToString ENDP

; PrintUInt: EAX=DWORD. Convierte y muestra con WriteString. Conserva todos.
PrintUInt PROC
    pushad
    mov edi, OFFSET numeroTexto
    call UIntToString
    mov edx, OFFSET numeroTexto
    call WriteString
    popad
    ret
PrintUInt ENDP

; PrintMoney: EAX=centavos. Muestra pesos, punto, dos digitos y " MXN".
; DIV 100: EAX=pesos, EDX=centavos. Conserva todos los registros.
PrintMoney PROC
    pushad
    xor edx, edx
    mov ebx, 100
    div ebx
    push edx
    mov edi, OFFSET precioTexto
    call UIntToString
    mov esi, OFFSET precioTexto
MoneyBuscarFin:
    cmp BYTE PTR [esi], 0
    je MoneyEscribirPunto
    inc esi
    jmp MoneyBuscarFin
MoneyEscribirPunto:
    mov BYTE PTR [esi], '.'
    inc esi
    pop eax
    xor edx, edx
    mov ebx, 10
    div ebx
    add al, '0'
    add dl, '0'
    mov [esi], al
    mov [esi+1], dl
    mov BYTE PTR [esi+2], 0
    mov edx, OFFSET precioTexto
    call WriteString
    mov edx, OFFSET sufijoMoneda
    call WriteString
    popad
    ret
PrintMoney ENDP

; FindProduct: EDX=codigo validado; EAX=puntero al producto o 0.
; Recorre con ESI. Conserva EBX,ECX,EDX,ESI,EDI,EBP.
FindProduct PROC USES ebx ecx edx esi edi ebp
    mov ebp, edx
    mov esi, OFFSET catalogo
    mov ebx, cantidadProductos
FindSiguiente:
    test ebx, ebx
    jz FindNo
    mov edi, ebp
    xor ecx, ecx
FindComparar:
    mov al, [esi+ecx]
    cmp al, [edi+ecx]
    jne FindAvanzar
    inc ecx
    cmp ecx, 8
    jb FindComparar
    mov eax, esi
    ret
FindAvanzar:
    add esi, TAM_REG
    dec ebx
    jmp FindSiguiente
FindNo:
    xor eax, eax
    ret
FindProduct ENDP

; AskProduct: EAX=puntero encontrado, o 0 si catalogo vacio. Conserva otros.
; Repite ante codigo incorrecto o inexistente. No modifica productos.
AskProduct PROC USES ebx ecx edx esi edi
    cmp cantidadProductos, 0
    je AskProductVacio
AskProductOtra:
    mov edx, OFFSET pCodigo
    call Capture
    mov esi, OFFSET entrada
    call ValidateCode
    test eax, eax
    jz AskProductFormato
    mov edx, OFFSET entrada
    call FindProduct
    test eax, eax
    jnz AskProductFin
    mov edx, OFFSET msgNoExiste
    call WriteString
    jmp AskProductOtra
AskProductFormato:
    mov edx, OFFSET msgCodigo
    call WriteString
    jmp AskProductOtra
AskProductVacio:
    mov edx, OFFSET msgVacio
    call WriteString
    xor eax, eax
AskProductFin:
    ret
AskProduct ENDP

; RegisterProduct: sin entradas/salidas. Conserva todos con PUSHAD.
; Se construye nuevoProducto y se confirma solo al validar TODOS los campos.
RegisterProduct PROC
    pushad
    cmp cantidadProductos, MAX_PRODUCTOS
    jae RegisterLleno
    mov edi, OFFSET nuevoProducto
    mov ecx, TAM_REG
    xor eax, eax
    cld
    rep stosb
RegisterCodigo:
    mov edx, OFFSET pCodigo
    call Capture
    mov esi, OFFSET entrada
    call ValidateCode
    test eax, eax
    jz RegisterFormato
    mov edx, OFFSET entrada
    call FindProduct
    test eax, eax
    jnz RegisterDuplicado
    mov esi, OFFSET entrada
    mov edi, OFFSET nuevoProducto
    mov ecx, 8
    rep movsb
RegisterNombre:
    mov edx, OFFSET pNombre
    call Capture
    mov esi, OFFSET entrada
    call ValidateName
    test eax, eax
    jz RegisterNombreError
    mov esi, OFFSET entrada
    mov edi, OFFSET nuevoProducto + P_NOMBRE
RegisterCopiarNombre:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    test al, al
    jnz RegisterCopiarNombre
RegisterPrecio:
    mov edx, OFFSET pPrecio
    call Capture
    mov esi, OFFSET entrada
    call ParseMoney
    jc RegisterPrecioError
    mov DWORD PTR nuevoProducto[P_PRECIO], eax
    mov edx, OFFSET pStock
    mov ebx, 0
    mov edi, 100
    call AskUInt
    mov DWORD PTR nuevoProducto[P_STOCK], eax
    ; Confirmacion del alta: antes de aqui no se cambio el catalogo.
    mov eax, cantidadProductos
    imul eax, eax, TAM_REG
    mov edi, OFFSET catalogo
    add edi, eax
    mov esi, OFFSET nuevoProducto
    mov ecx, TAM_REG
    rep movsb
    inc cantidadProductos
    mov cambios, 1
    mov edx, OFFSET msgAlta
    call WriteString
    jmp RegisterFin
RegisterFormato:
    mov edx, OFFSET msgCodigo
    call WriteString
    jmp RegisterCodigo
RegisterDuplicado:
    mov edx, OFFSET msgDuplicado
    call WriteString
    jmp RegisterCodigo
RegisterNombreError:
    mov edx, OFFSET msgNombre
    call WriteString
    jmp RegisterNombre
RegisterPrecioError:
    mov edx, OFFSET msgPrecio
    call WriteString
    jmp RegisterPrecio
RegisterLleno:
    mov edx, OFFSET msgLleno
    call WriteString
RegisterFin:
    popad
    ret
RegisterProduct ENDP

; PrintProduct: ESI=puntero al registro. Muestra todos los campos; conserva todos.
PrintProduct PROC
    pushad
    mov edx, OFFSET msgCodigoEtiqueta
    call WriteString
    lea edx, [esi+P_CODIGO]
    call WriteString
    mov edx, OFFSET msgNombreEtiqueta
    call WriteString
    lea edx, [esi+P_NOMBRE]
    call WriteString
    mov edx, OFFSET msgPrecioEtiqueta
    call WriteString
    mov eax, [esi+P_PRECIO]
    call PrintMoney
    mov edx, OFFSET msgStockEtiqueta
    call WriteString
    mov eax, [esi+P_STOCK]
    call PrintUInt
    call Crlf
    popad
    ret
PrintProduct ENDP

; ListInventory: sin entradas/salidas; recorrido con ESI += 44. Conserva todos.
ListInventory PROC
    pushad
    cmp cantidadProductos, 0
    je ListVacia
    mov esi, OFFSET catalogo
    mov ecx, cantidadProductos
ListSiguiente:
    push ecx
    call PrintProduct
    pop ecx
    add esi, TAM_REG
    loop ListSiguiente
    jmp ListFin
ListVacia:
    mov edx, OFFSET msgVacio
    call WriteString
ListFin:
    popad
    ret
ListInventory ENDP

; SearchProduct: sin entradas/salidas; busca y muestra. Conserva todos.
SearchProduct PROC
    pushad
    call AskProduct
    test eax, eax
    jz SearchFin
    mov esi, eax
    call PrintProduct
SearchFin:
    popad
    ret
SearchProduct ENDP

; ReceiveStock: suma solo despues de validar limite y acarreo. Conserva todos.
ReceiveStock PROC
    pushad
    call AskProduct
    test eax, eax
    jz ReceiveFin
    mov esi, eax
ReceiveCantidad:
    mov edx, OFFSET pCantidad
    mov ebx, 1
    mov edi, 100
    call AskUInt
    add eax, [esi+P_STOCK]
    jc ReceiveOverflow
    cmp eax, 100
    ja ReceiveExceso
    mov [esi+P_STOCK], eax
    mov cambios, 1
    mov edx, OFFSET msgEntrada
    call WriteString
    mov eax, [esi+P_STOCK]
    call PrintUInt
    call Crlf
    jmp ReceiveFin
ReceiveExceso:
    mov edx, OFFSET msgExceso
    call WriteString
    jmp ReceiveCantidad
ReceiveOverflow:
    mov edx, OFFSET msgOverflow
    call WriteString
ReceiveFin:
    popad
    ret
ReceiveStock ENDP

; SellProduct: valida todo antes de cambiar stock e ingresos. Conserva todos.
; MUL: EDX:EAX=precio*cantidad; EDX!=0 significa que no cabe en DWORD.
; ADD: CF detecta desbordamiento sin signo en ingresos acumulados.
SellProduct PROC
    pushad
    call AskProduct
    test eax, eax
    jz SellFin
    mov esi, eax
    cmp DWORD PTR [esi+P_STOCK], 0
    je SellSinStock
SellCantidad:
    mov edx, OFFSET pCantidad
    mov ebx, 1
    mov edi, 100
    call AskUInt
    cmp eax, [esi+P_STOCK]
    ja SellInsuficiente
    mov ventaCantidad, eax
    mul DWORD PTR [esi+P_PRECIO]
    test edx, edx
    jnz SellOverflow
    mov ventaImporte, eax
    add eax, ingresosSesion
    jc SellOverflow
    mov ventaIngresos, eax
    mov eax, [esi+P_STOCK]
    sub eax, ventaCantidad
    jc SellOverflow
    ; Confirmacion: ambas cantidades nuevas ya se comprobaron.
    mov [esi+P_STOCK], eax
    mov eax, ventaIngresos
    mov ingresosSesion, eax
    mov cambios, 1
    mov edx, OFFSET msgVenta
    call WriteString
    mov eax, ventaImporte
    call PrintMoney
    call Crlf
    cmp DWORD PTR [esi+P_STOCK], 5
    ja SellFin
    mov edx, OFFSET msgAlerta
    call WriteString
    jmp SellFin
SellInsuficiente:
    mov edx, OFFSET msgInsuficiente
    call WriteString
    jmp SellCantidad
SellSinStock:
    mov edx, OFFSET msgSinStock
    call WriteString
    jmp SellFin
SellOverflow:
    mov edx, OFFSET msgOverflow
    call WriteString
SellFin:
    popad
    ret
SellProduct ENDP

; ShowSummary: suma unidades y precio*stock. Conserva todos.
; Las variables total* son resultados temporales, no modifican productos.
ShowSummary PROC
    pushad
    mov totalUnidades, 0
    mov totalValor, 0
    mov esi, OFFSET catalogo
    mov ecx, cantidadProductos
    jecxz SummaryMostrar
SummarySiguiente:
    mov eax, [esi+P_STOCK]
    add totalUnidades, eax
    jc SummaryOverflow
    mul DWORD PTR [esi+P_PRECIO]
    test edx, edx
    jnz SummaryOverflow
    add totalValor, eax
    jc SummaryOverflow
    add esi, TAM_REG
    loop SummarySiguiente
SummaryMostrar:
    mov edx, OFFSET msgUnidades
    call WriteString
    mov eax, totalUnidades
    call PrintUInt
    call Crlf
    mov edx, OFFSET msgValor
    call WriteString
    mov eax, totalValor
    call PrintMoney
    call Crlf
    mov edx, OFFSET msgIngresos
    call WriteString
    mov eax, ingresosSesion
    call PrintMoney
    call Crlf
    jmp SummaryFin
SummaryOverflow:
    mov edx, OFFSET msgOverflow
    call WriteString
SummaryFin:
    popad
    ret
ShowSummary ENDP

; LowStockAlerts: regla adicional, muestra productos con stock <=5 (incluye 0).
; No cambia datos; conserva todos los registros. ESI recorre el catalogo.
LowStockAlerts PROC
    pushad
    mov esi, OFFSET catalogo
    mov ecx, cantidadProductos
    xor ebx, ebx
    jecxz AlertsFinal
AlertsSiguiente:
    cmp DWORD PTR [esi+P_STOCK], 5
    ja AlertsAvanzar
    call PrintProduct
    inc ebx
AlertsAvanzar:
    add esi, TAM_REG
    loop AlertsSiguiente
AlertsFinal:
    test ebx, ebx
    jnz AlertsFin
    mov edx, OFFSET msgSinAlertas
    call WriteString
AlertsFin:
    popad
    ret
LowStockAlerts ENDP

; Checksum: ESI=datos, ECX=numero de bytes. EAX=suma de los bytes.
; Conserva los otros registros. Con <=440 bytes no hay overflow de DWORD.
; Es detector simple de errores accidentales, no firma ni autenticacion.
Checksum PROC USES ebx ecx esi
    xor eax, eax
    jecxz ChecksumFin
ChecksumSiguiente:
    movzx ebx, BYTE PTR [esi]
    add eax, ebx
    inc esi
    loop ChecksumSiguiente
ChecksumFin:
    ret
Checksum ENDP

; SaveCatalog: EAX=1 exito, 0 error. Conserva los demas registros.
; Cabecera: firma[8], count DWORD, checksum DWORD. Despues count*44 bytes.
; Escribe temporal, comprueba bytes y cierre, y solo entonces lo reemplaza.
SaveCatalog PROC USES ebx ecx edx esi edi ebp
    cld
    mov esi, OFFSET firma
    mov edi, OFFSET archivoBuffer
    mov ecx, 8
    rep movsb
    mov eax, cantidadProductos
    mov DWORD PTR archivoBuffer[8], eax
    imul eax, eax, TAM_REG
    mov ecx, eax
    add eax, TAM_CAB
    mov bytesArchivo, eax
    mov esi, OFFSET catalogo
    mov edi, OFFSET archivoBuffer + TAM_CAB
    rep movsb
    mov eax, cantidadProductos
    imul ecx, eax, TAM_REG
    mov esi, OFFSET archivoBuffer + TAM_CAB
    call Checksum
    mov DWORD PTR archivoBuffer[12], eax
    mov edx, OFFSET nombreTemporal
    call CreateOutputFile
    cmp eax, INVALID_HANDLE_VALUE
    je SaveError
    mov handleActual, eax
    mov edx, OFFSET archivoBuffer
    mov ecx, bytesArchivo
    call WriteToFile
    jc SaveCerrarError
    cmp eax, bytesArchivo
    jne SaveCerrarError
    mov eax, handleActual
    call CloseFile
    test eax, eax
    jz SaveError
    ; STDCALL: argumentos de derecha a izquierda; la funcion limpia 12 bytes.
    push 9
    push OFFSET nombreArchivo
    push OFFSET nombreTemporal
    call MoveFileExA
    test eax, eax
    jz SaveError
    mov cambios, 0
    mov edx, OFFSET msgGuardado
    call WriteString
    mov eax, 1
    ret
SaveCerrarError:
    mov eax, handleActual
    call CloseFile
SaveError:
    mov edx, OFFSET msgErrorArchivo
    call WriteString
    xor eax, eax
    ret
SaveCatalog ENDP

; ValidateFile: archivoBuffer + bytesArchivo ya capturados; EAX=1/0.
; Revisa firma, count, tamano EXACTO, checksum, campos, relleno y duplicados.
; El catalogo activo NO se usa como destino de ninguna escritura aqui.
; Conserva EBX,ECX,EDX,ESI,EDI,EBP. conteoCandidato se usa solo si EAX=1.
ValidateFile PROC USES ebx ecx edx esi edi ebp
    cmp bytesArchivo, TAM_CAB
    jb FileInvalid
    cmp bytesArchivo, MAX_ARCHIVO
    ja FileInvalid
    mov esi, OFFSET archivoBuffer
    mov edi, OFFSET firma
    mov ecx, 8
    cld
    repe cmpsb
    jne FileInvalid
    mov eax, DWORD PTR archivoBuffer[8]
    cmp eax, MAX_PRODUCTOS
    ja FileInvalid
    mov conteoCandidato, eax
    imul eax, eax, TAM_REG
    mov ecx, eax
    add eax, TAM_CAB
    cmp eax, bytesArchivo
    jne FileInvalid
    mov esi, OFFSET archivoBuffer + TAM_CAB
    call Checksum
    cmp eax, DWORD PTR archivoBuffer[12]
    jne FileInvalid
    mov esi, OFFSET archivoBuffer + TAM_CAB
    xor ebp, ebp
FileRegistro:
    cmp ebp, conteoCandidato
    jae FileValid
    call ValidateCode
    test eax, eax
    jz FileInvalid
    ; ValidateName conserva ESI: guardar y recuperar puntero del registro.
    push esi
    add esi, P_NOMBRE
    call ValidateName
    pop esi
    test eax, eax
    jz FileInvalid
    ; Tras el primer 00h del nombre, el resto del campo debe ser 0.
    mov edi, 0
FileBuscarNulo:
    cmp BYTE PTR [esi+edi+P_NOMBRE], 0
    je FileRelleno
    inc edi
    cmp edi, 26
    jb FileBuscarNulo
    jmp FileInvalid
FileRelleno:
    cmp edi, 28
    jae FileNumeros
    cmp BYTE PTR [esi+edi+P_NOMBRE], 0
    jne FileInvalid
    inc edi
    jmp FileRelleno
FileNumeros:
    cmp DWORD PTR [esi+P_PRECIO], 1
    jb FileInvalid
    cmp DWORD PTR [esi+P_PRECIO], 999999
    ja FileInvalid
    cmp DWORD PTR [esi+P_STOCK], 100
    ja FileInvalid
    ; Buscar duplicados solamente entre registros anteriores del candidato.
    mov edi, OFFSET archivoBuffer + TAM_CAB
    mov ebx, ebp
FilePrevio:
    test ebx, ebx
    jz FileAvanzar
    xor ecx, ecx
FileCompararCodigo:
    mov al, [esi+ecx]
    cmp al, [edi+ecx]
    jne FilePrevioSiguiente
    inc ecx
    cmp ecx, 8
    jb FileCompararCodigo
    jmp FileInvalid
FilePrevioSiguiente:
    add edi, TAM_REG
    dec ebx
    jmp FilePrevio
FileAvanzar:
    add esi, TAM_REG
    inc ebp
    jmp FileRegistro
FileValid:
    mov eax, 1
    ret
FileInvalid:
    xor eax, eax
    ret
ValidateFile ENDP

; LoadCatalog: EAX=1 cargado / 0 error. Conserva demas registros.
; Lee maximo permitido+1: un archivo con bytes extra se rechaza.
; Confirma el nuevo catalogo SOLO despues de leer, cerrar y validar TODO.
; ingresosSesion nunca se carga ni se reinicia mediante esta opcion.
LoadCatalog PROC USES ebx ecx edx esi edi ebp
    mov edx, OFFSET nombreArchivo
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je LoadAusente
    mov handleActual, eax
    mov edx, OFFSET archivoBuffer
    mov ecx, SIZEOF archivoBuffer
    call ReadFromFile
    jc LoadCerrarError
    mov bytesArchivo, eax
    mov eax, handleActual
    call CloseFile
    test eax, eax
    jz LoadError
    call ValidateFile
    test eax, eax
    jz LoadInvalid
    ; Confirmar el reemplazo del catalogo y limpiar los registros no usados.
    mov edi, OFFSET catalogo
    mov ecx, TAM_CATALOGO
    xor eax, eax
    cld
    rep stosb
    mov eax, conteoCandidato
    mov cantidadProductos, eax
    imul ecx, eax, TAM_REG
    mov esi, OFFSET archivoBuffer + TAM_CAB
    mov edi, OFFSET catalogo
    rep movsb
    mov cambios, 0
    mov edx, OFFSET msgCargado
    call WriteString
    mov eax, 1
    ret
LoadCerrarError:
    mov eax, handleActual
    call CloseFile
LoadError:
    mov edx, OFFSET msgErrorArchivo
    jmp LoadAviso
LoadAusente:
    mov edx, OFFSET msgAusente
    jmp LoadAviso
LoadInvalid:
    mov edx, OFFSET msgArchivoInvalido
LoadAviso:
    call WriteString
    xor eax, eax
    ret
LoadCatalog ENDP

END main
