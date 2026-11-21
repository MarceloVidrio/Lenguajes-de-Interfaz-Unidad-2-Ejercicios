# Tabla de pruebas — Stella Blu

## Configuración comprobada en los archivos recibidos

| Comprobación | Resultado obtenido por inspección |
|---|---|
| Solución y proyecto | La solución referencia `StellaBlu_U2.vcxproj` y coincide el identificador del proyecto. |
| Configuraciones | La solución ofrece Debug / x86 y Release / x86; ambas se asignan a las configuraciones Debug / Win32 y Release / Win32 del proyecto. |
| Versión registrada | La solución indica Visual Studio Version 18 y VisualStudioVersion 18.11.12315.225 stable. |
| Tipo de proyecto | La solución utiliza el identificador de tipo de proyecto Visual C++ `{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}`. |
| Presentación | `HideSolutionNode = FALSE`: se muestra el nodo de la solución. |
| Herramientas | Se especifica el conjunto v143 y el SDK de Windows 10.0. Su instalación debe comprobarse en la computadora. |
| Fuente de ensamblador | `main.asm` está incluido como elemento MASM. |
| Arquitectura y subsistema | MachineX86 y aplicación de consola. |
| Biblioteca | Importa `Irvine.props` y enlaza Irvine32.lib, kernel32.lib y user32.lib. La existencia de las bibliotecas debe comprobarse al compilar. |
| Compatibilidad de enlace | SAFESEH está desactivado mediante `ImageHasSafeExceptionHandlers=false`. |
| Directorio de trabajo | La depuración utiliza la carpeta del proyecto, donde debe estar `inventario.sbi`. |
| Copia del inventario | Tras compilar, se copia `inventario.sbi` al directorio de salida si allí no existe uno. |

## Preparación y ejecución de las pruebas

- Extraer el proyecto completo antes de abrir la solución. Usar **Debug / x86** en la solución y ejecutar con Ctrl+F5. La solución asigna x86 a Win32 en el proyecto; ambas denominaciones corresponden a 32 bits.
- Respaldar `inventario.sbi` antes de modificarlo. Cada caso que diga «inventario original» debe comenzar con la copia inicial de tres productos y una sesión nueva.
- P13 y P14 son consecutivas: P14 parte de las 22 unidades que deja P13. P29 constituye una secuencia independiente desde el catálogo original.
- Los casos de conversión interna, desbordamiento y fallos de archivo requieren depuración, archivos preparados o simulación de fallos. No se consideran comprobados únicamente por recorrer el menú.
- Si un caso agrupa varias entradas, registrar los resultados de todas las entradas probadas. No marcar como correcta una prueba no ejecutada.

## Casos de prueba

| ID | Entrada / accion | Resultado esperado | Resultado obtenido en desarrollo | Resultado obtenido en Windows |

| P01 | Iniciar con inventario original; opcion 2 | Tres productos con codigos MUN-001, ART-002 y BAL-003 | Correcto en emulacion |
| P02 | Opcion 6, catalogo original | 25 unidades; 5507.50 MXN; ingresos 0.00 MXN | Correcto en emulacion |
| P03 | Precio 185.50 / 12.05 / 12.5 / 229 | 18550 / 1205 / 1250 / 22900 centavos | Correcto en emulacion |
| P04 | Precio 12.345, 12., .50, $1 o 1,000 | Rechazo de sintaxis; vuelve a capturar | Correcto en emulacion | 
| P05 | Precio 0, 0.00 o 10000 | Rechazo por rango | Correcto en emulacion |
| P06 | Precio 0.01 y 9999.99 | Acepta ambos limites | Correcto en emulacion |
| P07 | Entero 4294967295 / 4294967296 | Parser acepta maximo DWORD y rechaza desbordamiento | Correcto en emulacion | 
| P08 | Cantidad vacia, -1, +1, 1.0, espacio o letra | Rechazo antes de convertir o por formato | Correcto en emulacion | 
| P09 | Codigo ABC-123 / AbC-123 / ABC-1234 | Primero valido; otros rechazados | Correcto en emulacion | 
| P10 | Nombre vacio, solo espacios o 26 caracteres | Rechazados; 25 caracteres visibles aceptados | Correcto en emulacion | 
| P11 | Alta MUN-001 y luego XYZ-004, Gorra prueba, 12.05, 4 | Duplicado rechazado; un solo registro nuevo | Correcto en emulacion |
| P12 | Alta cuando existen diez productos | Rechazo de capacidad; conserva los diez | Correcto en emulacion |
| P13 | Recibir MUN-001: 81 y luego 2, desde stock 20 | 81 rechazada; 2 aceptada y stock 22 | Correcto en emulacion |
| P14 | Vender MUN-001: 23 y luego 3, desde stock 22 | 23 rechazada; 3 aceptada, stock 19 e ingreso 687.00 MXN | Correcto en emulacion | 
| P15 | Convertir 0 y 4294967295 a texto | 0 y 4294967295; sin desequilibrio de pila | Correcto en emulacion |
| P16 | Mostrar centavos 5, 1205, 18550 | 0.05 MXN, 12.05 MXN y 185.50 MXN | Correcto en emulacion |
| P17 | Opcion 7 en catalogo original | ART-002 y BAL-003; no MUN-001 | Correcto en emulacion |
| P18 | Venta de 1 de ART-002, inicialmente 5 | Cobra 185.50 MXN; stock 4 y aviso de existencia minima | Correcto en emulacion | 
| P19 | Ingresos DWORD maximo; intento de nueva venta | Desbordamiento rechazado; stock e ingresos intactos | Correcto en emulacion, valor preparado en memoria |
| P20 | Guardar, finalizar e iniciar de nuevo | Carga el catalogo guardado; ingresos de nueva sesion cero | Correcto en emulacion | 
| P21 | Cargar catalogo durante una misma sesion | Conserva los ingresos de esa sesion | Correcto en emulacion | 
| P22 | Archivo ausente | Aviso y menu disponible; sin reemplazar catalogo | Correcto en emulacion |
| P23 | Archivo truncado, firma incorrecta, bytes extra o checksum incorrecto | Carga rechazada; catalogo, ingresos y cambios intactos | Correcto en emulacion | 
| P24 | Duplicados, codigo/nombre incorrectos, precio o stock fuera de rango con checksum correcto | Carga rechazada aun con suma correcta | Correcto en emulacion |
| P25 | Fallas de crear, escribir, escritura parcial, cerrar o reemplazar al guardar | Conserva archivo definitivo previo y marca de cambios | Correcto con fallas simuladas en emulacion | 
| P26 | Falla de lectura o cierre al cargar | Rechaza carga y cierra el handle | Correcto con fallas simuladas en emulacion | 
| P27 | Cambios pendientes: salir 0 y volver 0; cargar 9 y cancelar 0 | Conserva catalogo y vuelve al menu | Correcto en emulacion | 
| P28 | Vender BAL-003 sin stock | Venta rechazada y regreso al menu | Correcto en emulacion | 
| P29 | Desde el inventario original: alta NUE-004, Gorra nueva, precio 12.05, stock 4; recibir 2 de MUN-001; vender 3 de MUN-001 | Resumen: 28 unidades, 5326.70 MXN, ingresos 687.00 MXN | Correcto en emulacion |
| P30 | Abrir la solución actualizada; seleccionar Debug / x86; compilar MASM; ejecutar con Ctrl+F5 y recorrer con F10 en depuración | La solución compila el proyecto Debug / Win32 y permite ejecutar y demostrar el programa de 32 bits | Configuración x86 a Win32 comprobada por inspección; compilación y ejecución pendientes | 
