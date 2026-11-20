# Lenguajes de Interfaz — Unidad 2

19 ejercicios de ensamblador MASM x86 (32 bits) con Irvine32.

## Datos generales

- **Materia:** Lenguajes de Interfaz.
- **Unidad:** 2.
- **Alumno:** MARCELO VIDRIO OCHOA.
- **Horario:** 8:00-9:00am.
- **Docente:** Dr. José Luis Medina Jiménez.

## Índice de ejercicios

Cada carpeta contiene su código `main.asm` comentado y su archivo de proyecto `.vcxproj`.

| Práctica | Código |
|---|---|
| Hola mundo | [Ver código](Unidad_2_Proyectos/00_Hola_mundo/main.asm) |
| 1. Ciclos numéricos | [Ver código](Unidad_2_Proyectos/01_Ciclos_numericos/main.asm) |
| 2. Captura y desplegado de mensaje | [Ver código](Unidad_2_Proyectos/02_Captura_mensaje/main.asm) |
| 3. Comparación y prueba | [Ver código](Unidad_2_Proyectos/03_Comparacion_prueba/main.asm) |
| 4. Saltos | [Ver código](Unidad_2_Proyectos/04_Saltos/main.asm) |
| 4.1. Mayor, menor o igual | [Ver código](Unidad_2_Proyectos/04_1_Mayor_menor_igual/main.asm) |
| 5. Condicionales | [Ver código](Unidad_2_Proyectos/05_Condicionales/main.asm) |
| 5.1. Repetir hasta ingresar cero | [Ver código](Unidad_2_Proyectos/05_1_Repetir_hasta_cero/main.asm) |
| 6. Incremento y decremento: PIN | [Ver código](Unidad_2_Proyectos/06_Incremento_decremento/main.asm) |
| 6.1. Estacionamiento | [Ver código](Unidad_2_Proyectos/06_1_Estacionamiento/main.asm) |
| 7. Validación de formato | [Ver código](Unidad_2_Proyectos/07_Validacion_formato/main.asm) |
| 8. Operaciones aritméticas | [Ver código](Unidad_2_Proyectos/08_Operaciones_aritmeticas/main.asm) |
| 9. PUSH y POP | [Ver código](Unidad_2_Proyectos/09_Push_pop/main.asm) |
| 10. Cadena decimal | [Ver código](Unidad_2_Proyectos/10_Cadena_decimal/main.asm) |
| 11. Operaciones lógicas | [Ver código](Unidad_2_Proyectos/11_Operaciones_logicas/main.asm) |
| 12. Desplazamiento y rotación | [Ver código](Unidad_2_Proyectos/12_Desplazamiento_rotacion/main.asm) |
| 13. Cadena hexadecimal | [Ver código](Unidad_2_Proyectos/13_String_hexadecimal/main.asm) |
| 14. Captura y almacenamiento | [Ver código](Unidad_2_Proyectos/14_Captura_almacenamiento/main.asm) |
| 15. Manipulación de archivo | [Ver código](Unidad_2_Proyectos/15_Manipulacion_archivo/main.asm) |


## Compilación y ejecución

1. Descarga el repositorio mediante **Code > Download ZIP** y extrae su contenido.
2. Comprueba que Irvine32 esté en `D:\Irvine\Irvine`. Si utilizas otra ruta, modifica el valor `IrvineDir` en `Unidad_2_Proyectos/Irvine.props`.
3. Abre `Unidad_2_Proyectos/Unidad_2.sln` en Visual Studio.
4. Selecciona **Debug** y **Win32**.
5. En el Explorador de soluciones, haz clic derecho en el ejercicio que deseas ejecutar y selecciona **Establecer como proyecto de inicio**.
6. Selecciona **Compilar > Compilar solución**.
7. Presiona **Ctrl + F5** para ejecutar el ejercicio sin depuración.

## Archivos del proyecto

- `main.asm`: código fuente de cada ejercicio.
- `.vcxproj`: configuración de compilación de cada proyecto.
- `Irvine.props`: rutas y configuración compartida para Irvine32.
- `Unidad_2.sln`: solución que agrupa los 19 proyectos.
