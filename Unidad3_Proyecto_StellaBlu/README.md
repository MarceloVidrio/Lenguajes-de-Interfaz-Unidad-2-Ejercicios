# Stella Blu: ventas e inventario de gorras (Versión de la Unidad 3)

Proyecto de la Unidad 3 de Lenguajes de Interfaz: el sistema de la Unidad 2, reorganizado con **procedimientos, macros y USES**, con las mismas funciones, validaciones y regla de negocio.

**Alumno:** Marcelo Vidrio Ochoa
**Horario:** 8:00-9:00
**Docente:** Dr. José Luis Medina Jiménez

## Archivos

| Archivo | Contenido |
|---|---|
| `main.asm` | Datos, `main` y procedimientos, cada uno con su contrato (recibe, devuelve, conserva) |
| `macros.inc` | Las 11 macros nuevas (`mMostrar`, `mMostrarValor`, `mPedirNumero`, `mValidarOReintentar` con `LOCAL`, etc.) |
| `StellaBlu_U3.sln`, `StellaBlu_U3.vcxproj`, `Irvine.props` | Proyecto de Visual Studio 2022 (MASM, Win32) |
| `compilar.bat` | Compilación desde Developer Command Prompt |
| `inventario.sbi` | Inventario de prueba: MUN-001, ART-002 y BAL-003 |
| `datos_prueba/` | Copia del inventario original, catálogo vacío y archivos inválidos para probar la carga |
| `pruebas/` | Entradas y salidas de las sesiones de prueba ejecutadas |
| `docs/` | Reporte actualizado (Unidad 2 + Versión de la Unidad 3) en PDF y Word |

## Instrucciones de compilación

1. Instalar Visual Studio 2022 con la carga de trabajo **Desarrollo para el escritorio con C++** (incluye MASM).
2. Colocar la librería Irvine32 en `C:\Irvine`. `Irvine.props` también la busca en `D:\Irvine\Irvine`; para otra ruta, edite `IrvineDir` en ese archivo.
3. Abrir `StellaBlu_U3.sln`, elegir **Debug** y **x86** y compilar con **Ctrl+Mayús+B**.
4. Ejecutar con **Ctrl+F5**. El programa lee y guarda `inventario.sbi` en la carpeta del proyecto.

También se puede compilar con `compilar.bat` desde *Developer Command Prompt for VS 2022*.

## Menú

| Opción | Función |
|---|---|
| 1 | Alta de producto, con validación y rechazo de duplicados |
| 2 | Inventario completo |
| 3 | Búsqueda por código |
| 4 | Recepción de mercancía, sin superar 100 unidades |
| 5 | Venta de un solo producto |
| 6 | Unidades, valor de inventario e ingresos de la sesión |
| 7 | Productos con cinco unidades o menos (regla adicional) |
| 8 | Guardado del catálogo |
| 9 | Carga con validación y confirmación si hay cambios pendientes |
| 0 | Salida y aviso por cambios sin guardar |

## Repetir las pruebas automáticas

La configuración **Prueba** define `MODO_PRUEBA`. En ella, las capturas se leen de `entradas_prueba.txt` y toda la salida se copia a `salida_prueba.txt`. La configuración Debug no incluye ese código.

1. Copiar `datos_prueba/inventario_original.sbi` como `inventario.sbi`.
2. Copiar `pruebas/A_entradas.txt` como `entradas_prueba.txt` en la carpeta del proyecto.
3. Elegir la configuración **Prueba** y ejecutar con **Ctrl+F5**.
4. Comparar `salida_prueba.txt` con `pruebas/A_salida.txt`.

Si Windows muestra *"Una directiva de Control de aplicaciones bloqueó este archivo"*, es **Control inteligente de aplicaciones**, que bloquea los ejecutables sin firma digital.
