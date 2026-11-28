# Proyecto integrador Unidad 4 — Estación de monitoreo (simulado con USB)

**Programación híbrida: C++ + ensamblador MASM x86 (32 bits)**

- **Materia:** Lenguajes de Interfaz (SCC-1014), horario 8:00 AM - 9:00 AM
- **Alumno:** Marcelo Vidrio Ochoa
- **Docente:** Dr. José Luis Medina Jiménez
- **TecNM Campus Culiacán**, 28 de noviembre de 2026

El programa detecta la conexión de una memoria USB y lee la configuración del sensor (`sensor.ini`). Después muestra cada temperatura de `lecturas.csv` en la consola, con colores por estado, y guarda el registro en `resultados.csv` dentro de la misma memoria. No hace falta presionar ninguna tecla.

## Estructura

| Ruta | Contenido |
|---|---|
| `main.cpp` | Programa principal en C++: flujo de estados, consola (posición y colores), archivos y unidades con la API de Windows |
| `monitor.asm` | Procedimientos en MASM x86 que llama C++ (`extern "C"`, `.model flat, C`) |
| `EstacionMonitoreo.sln`, `EstacionMonitoreo.vcxproj` | Solución de Visual Studio 2022 (Win32 / x86, personalización MASM activada) |
| `usb/` | `sensor.ini` y `lecturas.csv` para copiar a la raíz de la USB, y `resultados_ejemplo.csv` generado en las pruebas |
| `docs/` | Reporte en PDF (y DOCX editable) con funcionamiento, pruebas y conclusiones |
| `capturas/` | Capturas de la compilación y de las pruebas |
| `version_anterior_solo_ASM/` | Primera versión del proyecto, escrita solo en ensamblador con Irvine32 |

## Reparto C++ / ensamblador

| Procedimiento ASM | Función |
|---|---|
| `UnidadesNuevas` | Calcula `actual AND NOT anterior` sobre la máscara de `GetLogicalDrives` (NOT, AND) |
| `SiguienteUnidad` | Devuelve la siguiente unidad nueva y apaga su bit (BSF, BTR) |
| `BuscarClave` | Busca `SITIO=`, `INTERVALO_MS=` o `temperatura_c` en el texto |
| `TextoANumero` | Convierte texto a número (MUL, con control de desbordamiento) |
| `ExtraerValor` | Toma la primera columna del siguiente renglón del CSV (ignora CR y espacios) |
| `NumeroATexto` | Convierte el número de lectura a texto (DIV, PUSH/POP) |

C++ se encarga del ciclo de espera, de la consola y de `CreateFileA`, `ReadFile`, `WriteFile` y `CloseHandle`.

## Cómo compilar y ejecutar

1. Abre `EstacionMonitoreo.sln` en Visual Studio 2022. Necesitas la carga de trabajo **Desarrollo para el escritorio con C++**.
2. Selecciona **Debug** y **x86**. MASM ya viene activado en el proyecto (Dependencias de compilación → Personalizaciones de compilación → masm).
3. **Compilar → Recompilar solución.** Se ensambla `monitor.asm`, se compila `main.cpp` y ambos se enlazan en `bin\Debug\EstacionMonitoreo.exe`.
4. Copia `usb/sensor.ini` y `usb/lecturas.csv` a la raíz de la memoria USB.
5. Ejecuta con **Depurar → Iniciar sin depurar** (Ctrl+F5) y conecta la memoria.
6. Al terminar aparece `resultados.csv` en la raíz de la USB. Retira la memoria para volver al estado de espera.

### Formato de archivos

`sensor.ini`
```
[sensor]
SITIO=Tanque_A
INTERVALO_MS=2000
```

`lecturas.csv` → `resultados.csv`
```
temperatura_c          sitio,numero,temperatura_c
24.6                   Tanque_A,1,24.6
24.8                   Tanque_A,2,24.8
...                    ...
```

## Estados en consola

| Estado | Color |
|---|---|
| Esperando memoria USB... | gris claro |
| USB detectada: Tanque_A | cian |
| Leyendo archivo... | blanco sobre azul |
| Lectura N: xx.x C | verde claro |
| Proceso terminado. Puede retirar la USB. | verde claro |
| Error ... | rojo claro |
