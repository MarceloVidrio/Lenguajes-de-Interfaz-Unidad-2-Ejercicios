# Sesiones de prueba

Ejecutadas el 21/11/2026 en Windows 11 con Visual Studio 2022, configuración **Prueba**.

| Sesión | `inventario.sbi` al iniciar | Entradas | Salida |
|---|---|---|---|
| A | `datos_prueba/inventario_original.sbi` | `A_entradas.txt` | `A_salida.txt` |
| B | `datos_prueba/inventario_original.sbi` | `B_entradas.txt` | `B_salida.txt` (guarda 4 productos) |
| C | El archivo guardado por B | `C_entradas.txt` | `C_salida.txt` |
| D | Cada archivo de `datos_prueba/` (inválidos y vacío) | `D_entradas.txt` | `D_salida_*.txt` |
