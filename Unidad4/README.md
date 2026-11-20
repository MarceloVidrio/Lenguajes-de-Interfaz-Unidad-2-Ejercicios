# Proyecto Unidad 4: Estación de monitoreo (simulado con USB)

**Materia:** Lenguajes de Interfaz (SCC-1014)
**Alumno:** Marcelo Vidrio Ochoa
**Horario:** 8:00 AM - 9:00 AM
**Docente:** Dr. José Luis Medina Jiménez

Programa en ensamblador x86 de 32 bits (MASM + Irvine32). Detecta la conexión de una memoria USB y busca `sensor.ini` en su raíz. Después lee las temperaturas de `lecturas.csv`, las muestra una por una en un renglón fijo de la consola, con un color distinto para cada estado, y guarda los resultados en `resultados.csv` dentro de la misma memoria.

## Archivos

| Archivo | Descripción |
|---------|-------------|
| [EstacionMonitoreo.asm](./EstacionMonitoreo.asm) | Código fuente del programa |
| EstacionMonitoreo.sln / .vcxproj | Proyecto de Visual Studio 2022 (MASM, Debug \| Win32) |
| [sensor.ini](./sensor.ini) | Configuración de la sesión (va en la raíz de la USB) |
| [lecturas.csv](./lecturas.csv) | Mediciones simuladas (va en la raíz de la USB) |
| [Reporte_Proyecto_U4_Marcelo_Vidrio.pdf](./Reporte_Proyecto_U4_Marcelo_Vidrio.pdf) | Reporte del proyecto |
| [capturas/](./capturas) | Evidencias de las pruebas |

## Estados del programa

| Estado | Mensaje | Color |
|--------|---------|-------|
| Esperar | Esperando memoria USB... | Gris claro sobre negro |
| Detectar | USB detectada: Tanque_A | Cian sobre negro |
| Abrir archivo | Leyendo archivo... | Blanco sobre azul |
| Mostrar | Lectura 1: 24.6 C | Verde claro sobre negro |
| Finalizar | Proceso terminado. Puede retirar la USB. | Verde claro sobre negro |
| Error | Error al abrir lecturas.csv | Rojo claro sobre negro |

## Cómo ejecutarlo

1. Instalar Visual Studio 2022 con "Desarrollo para el escritorio con C++" (incluye MASM).
2. Colocar la librería Irvine32 en `C:\Irvine` (no se incluye aquí; se descarga del repositorio del autor, [surferkip/asmbook](https://github.com/surferkip/asmbook)).
3. Abrir `EstacionMonitoreo.sln` y compilar en **Debug | Win32**.
4. Copiar `sensor.ini` y `lecturas.csv` a la raíz de la memoria USB.
5. Ejecutar con **Ctrl + F5** con la memoria desconectada y luego conectarla.
