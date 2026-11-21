# Stella Blu: ventas e inventario de gorras

Proyecto integrado de la Unidad 2 de Lenguajes de Interfaz.

**Integrantes:** MARCELO VIDRIO OCHOA 
**Horario:** 8:00-9:00am
**Docente:** Dr. José Luis Medina Jiménez.

## Menú

| Opción | Función |
|---|---|
| 1 | Alta de producto, con validación y rechazo de duplicados |
| 2 | Inventario completo |
| 3 | Búsqueda por código |
| 4 | Recepción de mercancía, sin superar 100 unidades |
| 5 | Venta de un solo producto |
| 6 | Unidades, valor de inventario e ingresos de la sesión |
| 7 | Productos con cinco unidades o menos |
| 8 | Guardado del catálogo |
| 9 | Carga con validación y confirmación si hay cambios pendientes |
| 0 | Salida y aviso por cambios sin guardar |

## Reglas de captura

- Máximo 10 productos. Código exacto de tres mayúsculas, guion y tres dígitos, como `MUN-001`.
- Nombre de 1 a 25 caracteres ASCII visibles (letras sin acento, números y signos). Los espacios están permitidos, pero un nombre compuesto solo por espacios se rechaza.
- Precios válidos: `229`, `185.50`, `12.5`, `12.05`. Rango de `0.01` a `9999.99`.
- Se rechazan `12.`, `.50`, `12.345`, `$229`, `1,000`, espacios y signos. Para fracciones se requiere la parte entera, por ejemplo `0.50`.
- Existencia inicial de 0 a 100. Entradas y ventas de 1 a 100, sujetas a capacidad y stock.
- Las cantidades aceptan únicamente dígitos. Se permiten ceros a la izquierda; el valor final debe estar en el rango.
- Ante un error en un campo se solicita nuevamente. Una venta de un producto agotado vuelve al menú. Ningún rechazo modifica productos o ingresos.
- Un ingreso acumulado se limita a un DWORD sin signo en centavos: 42949672.95 MXN. Se rechaza la venta que lo desborde.

## Archivos incluidos

- `main.asm`: único programa integrado, con contratos de procedimientos y comentarios.
- `StellaBlu_U2.sln`, `.vcxproj` e `Irvine.props`: configuración para Visual Studio.
- `inventario.sbi`: catálogo inicial utilizable, tres productos.
- `datos_prueba/`: copia original, catálogo vacío y archivos inválidos para las demostraciones.
- `docs/INFORME_BREVE.pdf`: negocio, regla, memoria, archivo y decisiones con fuentes.
- `docs/TABLA_PRUEBAS.md`: entradas, resultados esperados y resultados obtenidos, con su alcance.


