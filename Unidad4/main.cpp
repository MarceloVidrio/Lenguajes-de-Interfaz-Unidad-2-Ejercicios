// Materia: Lenguajes de Interfaz (SCC-1014)
// Alumno: Marcelo Vidrio Ochoa
// Horario: 8:00 AM - 9:00 AM
// Docente: Dr. Jose Luis Medina Jimenez
// Proyecto: PROYECTO UNIDAD 4 - Estacion de monitoreo (simulado con USB)
// Archivo: main.cpp  (parte en C++ del programa hibrido)
//
// Programacion hibrida: este archivo en C++ controla el flujo del programa,
// la consola y la comunicacion con Windows (unidades y archivos). Los calculos
// de bajo nivel estan en ensamblador (monitor.asm) y se llaman como funciones
// normales gracias a extern "C".

#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
#include <windows.h>
#include <cstdio>
#include <cstring>
#include <cstdlib>

// ---- Funciones implementadas en ensamblador (monitor.asm) ----
extern "C" {
    unsigned    UnidadesNuevas(unsigned actual, unsigned anterior);
    int         SiguienteUnidad(unsigned* mascara);
    const char* BuscarClave(const char* texto, const char* clave);
    unsigned    TextoANumero(const char* texto);
    int         ExtraerValor(const char** cursor, char* destino, int maximo);
    void        NumeroATexto(unsigned valor, char* destino);
}

// ---- Pantalla ----
const SHORT COLUMNA = 4;
const SHORT FILA_ESTADO = 7;
const SHORT FILA_INFO = 9;
const int   ANCHO_CAMPO = 64;

const WORD COLOR_TITULO    = FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_INTENSITY;            // amarillo
const WORD COLOR_ESPERA    = FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;                 // gris claro
const WORD COLOR_DETECTADA = FOREGROUND_GREEN | FOREGROUND_BLUE;                                  // cian
const WORD COLOR_LEYENDO   = FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE |
                             FOREGROUND_INTENSITY | BACKGROUND_BLUE;                              // blanco sobre azul
const WORD COLOR_LECTURA   = FOREGROUND_GREEN | FOREGROUND_INTENSITY;                             // verde claro
const WORD COLOR_ERROR     = FOREGROUND_RED | FOREGROUND_INTENSITY;                               // rojo claro

// ---- Tiempos ----
const DWORD ESPERA_SONDEO   = 500;    // ms entre revisiones de unidades
const DWORD PAUSA_DETECCION = 1500;   // ms que se ve "USB detectada"
const DWORD INTERVALO_DEF   = 2000;   // si sensor.ini no trae INTERVALO_MS

// ---- Datos de la sesion ----
static HANDLE   consola;
static char     rutaIni[] = "?:\\sensor.ini";
static char     rutaCsv[] = "?:\\lecturas.csv";
static char     rutaRes[] = "?:\\resultados.csv";
static char     bufIni[1024];
static char     bufCsv[8192];
static char     sitio[32];
static unsigned intervalo = INTERVALO_DEF;
static char     letra = '?';

// Escribe un mensaje con su color en un renglon fijo y borra lo que
// sobraba del mensaje anterior rellenando con espacios.
static void EscribirCampo(SHORT fila, const char* texto, WORD color)
{
    COORD pos = { COLUMNA, fila };
    SetConsoleCursorPosition(consola, pos);
    SetConsoleTextAttribute(consola, color);
    printf("%-*.*s", ANCHO_CAMPO, ANCHO_CAMPO, texto);
    fflush(stdout);
    SetConsoleTextAttribute(consola, COLOR_ESPERA);
    COORD fuera = { 0, (SHORT)(FILA_INFO + 3) };
    SetConsoleCursorPosition(consola, fuera);
}

static void MostrarEstado(const char* texto, WORD color) { EscribirCampo(FILA_ESTADO, texto, color); }

static void EscribirEn(SHORT fila, const char* texto, WORD color)
{
    COORD pos = { COLUMNA, fila };
    SetConsoleCursorPosition(consola, pos);
    SetConsoleTextAttribute(consola, color);
    printf("%s", texto);
}

static void DibujarEncabezado()
{
    SetConsoleTextAttribute(consola, COLOR_ESPERA);
    system("cls");
    EscribirEn(1, "ESTACION DE MONITOREO (SIMULADO CON USB) - VERSION HIBRIDA C++ / ASM", COLOR_TITULO);
    EscribirEn(2, "TecNM Campus Culiacan | Lenguajes de Interfaz | Unidad 4", COLOR_ESPERA);
    EscribirEn(3, "Alumno: Marcelo Vidrio Ochoa", COLOR_ESPERA);
    EscribirEn(4, "--------------------------------------------------------", COLOR_ESPERA);
    EscribirEn(FILA_ESTADO - 1, "Estado:", COLOR_ESPERA);
    EscribirEn(FILA_INFO + 2, "Cierre la ventana para terminar el programa.", COLOR_ESPERA);
    fflush(stdout);
}

static void MostrarEspera()
{
    MostrarEstado("Esperando memoria USB...", COLOR_ESPERA);
    EscribirCampo(FILA_INFO, "", COLOR_ESPERA);
}

static void MostrarInfo()
{
    char num[12], linea[96];
    NumeroATexto(intervalo, num);                       // ASM
    sprintf(linea, "Unidad: %c:\\    Intervalo: %s ms", letra, num);
    EscribirCampo(FILA_INFO, linea, COLOR_ESPERA);
}

// Lee un archivo completo con la API de Windows. Regresa los bytes leidos
// o -1 si no se pudo abrir o leer. El buffer queda terminado en 0.
static int LeerArchivo(const char* ruta, char* buf, DWORD capacidad)
{
    HANDLE h = CreateFileA(ruta, GENERIC_READ, FILE_SHARE_READ, NULL,
                           OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (h == INVALID_HANDLE_VALUE) return -1;
    DWORD total = 0, leidos = 0;
    while (total < capacidad - 1) {
        if (!ReadFile(h, buf + total, capacidad - 1 - total, &leidos, NULL)) {
            CloseHandle(h);
            return -1;
        }
        if (leidos == 0) break;            // fin del archivo
        total += leidos;                   // solo cuenta lo que ReadFile entrego
    }
    buf[total] = 0;
    CloseHandle(h);
    return (int)total;
}

// Escribe una cadena y comprueba que se guardaron todos los bytes.
static bool EscribirTexto(HANDLE h, const char* s)
{
    DWORD previstos = (DWORD)strlen(s), escritos = 0;
    return WriteFile(h, s, previstos, &escritos, NULL) && escritos == previstos;
}

// Obtiene SITIO e INTERVALO_MS de bufIni.
static void InterpretarPerfil()
{
    const char* p = BuscarClave(bufIni, "SITIO=");              // ASM
    int n = 0;
    if (p) {
        while (*p == ' ') p++;
        while (*p && *p != '\r' && *p != '\n' && n < (int)sizeof(sitio) - 1) sitio[n++] = *p++;
    }
    sitio[n] = 0;
    if (n == 0) strcpy(sitio, "SIN_SITIO");

    const char* q = BuscarClave(bufIni, "INTERVALO_MS=");       // ASM
    intervalo = q ? TextoANumero(q) : 0;                        // ASM
    if (intervalo == 0) intervalo = INTERVALO_DEF;
}

// Revisa si la unidad indicada tiene sensor.ini (con reintentos, porque
// la memoria tarda en montarse despues de que aparece su letra).
static bool ProbarUnidad(int indice)
{
    letra = (char)('A' + indice);
    rutaIni[0] = rutaCsv[0] = rutaRes[0] = letra;
    for (int intento = 0; intento < 3; intento++) {
        if (LeerArchivo(rutaIni, bufIni, sizeof(bufIni)) >= 0) {
            InterpretarPerfil();
            return true;
        }
        Sleep(400);
    }
    return false;
}

// Etapas 2 a 5: deteccion, lectura, presentacion y guardado.
static void EjecutarSesion()
{
    char linea[128], valor[16], num[12], fila[128];

    // Etapa 2: USB detectada
    sprintf(linea, "USB detectada: %s", sitio);
    MostrarEstado(linea, COLOR_DETECTADA);
    MostrarInfo();
    Sleep(PAUSA_DETECCION);

    // Etapa 3: abrir y leer lecturas.csv
    MostrarEstado("Leyendo archivo...", COLOR_LEYENDO);
    if (LeerArchivo(rutaCsv, bufCsv, sizeof(bufCsv)) < 0) {
        MostrarEstado("Error al abrir lecturas.csv", COLOR_ERROR);
        return;
    }
    if (!BuscarClave(bufCsv, "temperatura_c")) {                // ASM
        MostrarEstado("Error: lecturas.csv no tiene la columna temperatura_c", COLOR_ERROR);
        return;
    }

    HANDLE salida = CreateFileA(rutaRes, GENERIC_WRITE, 0, NULL,
                                CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    if (salida == INVALID_HANDLE_VALUE) {
        MostrarEstado("Error al escribir resultados.csv", COLOR_ERROR);
        return;
    }
    if (!EscribirTexto(salida, "sitio,numero,temperatura_c\r\n")) {
        CloseHandle(salida);
        MostrarEstado("Error al escribir resultados.csv", COLOR_ERROR);
        return;
    }

    // Etapa 4: mostrar las lecturas
    const char* cursor = bufCsv;
    ExtraerValor(&cursor, valor, sizeof(valor));                // ASM: salta el encabezado
    unsigned numero = 0;
    int largo;
    while ((largo = ExtraerValor(&cursor, valor, sizeof(valor))) != -1) {   // ASM
        if (largo == 0) continue;                               // renglon vacio
        numero++;
        Sleep(intervalo);

        NumeroATexto(numero, num);                              // ASM
        sprintf(linea, "Lectura %s: %s C", num, valor);
        MostrarEstado(linea, COLOR_LECTURA);

        sprintf(fila, "%s,%s,%s\r\n", sitio, num, valor);
        if (!EscribirTexto(salida, fila)) {
            CloseHandle(salida);
            MostrarEstado("Error al escribir resultados.csv", COLOR_ERROR);
            return;
        }
    }

    // Etapa 5: guardar y finalizar
    CloseHandle(salida);
    if (numero == 0)
        MostrarEstado("Error: lecturas.csv no contiene temperaturas", COLOR_ERROR);
    else
        MostrarEstado("Proceso terminado. Puede retirar la USB.", COLOR_LECTURA);
}

int main()
{
    SetErrorMode(SEM_FAILCRITICALERRORS);   // sin ventanas de error por unidades vacias
    consola = GetStdHandle(STD_OUTPUT_HANDLE);
    CONSOLE_CURSOR_INFO cursorInfo = { 1, FALSE };
    SetConsoleCursorInfo(consola, &cursorInfo);
    DibujarEncabezado();

    unsigned anterior = 0;                  // al inicio se revisan todas las unidades
    for (;;) {
        // Etapas 1 y 6: esperar una memoria
        MostrarEspera();
        int unidad = -1;
        while (unidad < 0) {
            Sleep(ESPERA_SONDEO);
            unsigned actual = GetLogicalDrives();
            unsigned nuevas = UnidadesNuevas(actual, anterior);         // ASM
            anterior = actual;
            int indice;
            while ((indice = SiguienteUnidad(&nuevas)) != -1) {          // ASM
                if (ProbarUnidad(indice)) { unidad = indice; break; }
            }
        }

        EjecutarSesion();

        // Mantener el estado final mientras la USB siga conectada
        unsigned bit = 1u << unidad;
        do {
            Sleep(ESPERA_SONDEO);
            anterior = GetLogicalDrives();
        } while (anterior & bit);
    }
    return 0;
}
