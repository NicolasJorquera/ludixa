# Declaraciones de Google Play Console (H8-03)

Respuestas para los formularios de Play Console › Política › Contenido de la app. Criterio: **todo lo declarado coincide con los SDK reales**. Revisado el 4 de noviembre de 2026 contra el código, el manifiesto final de la versión prod y la guía de Google.

Si cambia algún SDK (por ejemplo, Firebase Analytics en H6-05) o lo que hace la app con los datos, hay que revisar esta página, la política (`site/`) y el formulario de Play **antes** de publicar esa versión.

## Inventario de SDK y datos

| Componente | Versión | Qué hace con los datos | Sale del teléfono |
|---|---|---|---|
| Google Mobile Ads (`google_mobile_ads` 9.2.0) | `play-services-ads` 25.5.0 | Anuncios: banner, intersticial y video con recompensa | **Sí**, a Google |
| User Messaging Platform | `user-messaging-platform` 4.0.0 | Formulario de consentimiento donde la ley lo exige | **Sí**, a Google |
| `shared_preferences` | 2.5 | Ajustes y contadores de anuncios | No |
| `drift_flutter` / SQLite | 0.3 | Progreso: partidas, racha, logros, estadísticas | No |
| `file_picker` | 13.3 | Exportar o importar el progreso a un archivo que elige el jugador | No (acción del usuario) |
| `url_launcher` | 6.3 | Abre la política en el navegador | No (acción del usuario) |
| `package_info_plus` | 10.2 | Muestra la versión en Ajustes | No |

- No hay otro código de red: ni cliente HTTP, ni analítica, ni reporte de fallos.
- La copia automática de Android la hace el sistema hacia la cuenta de Google del usuario, no la app. **Interpretación:** no se declara, porque Play define "recopilar" como lo que la app transmite fuera del teléfono.

Fuentes:
- [Datos que recopila el SDK de Google Mobile Ads](https://developers.google.com/admob/android/privacy/play-data-disclosure) (versión 25.5.0, la misma que usa la app).
- [Ayuda de Play sobre la sección de seguridad de los datos](https://support.google.com/googleplay/android-developer/answer/10787469).

## Seguridad de los datos (Data safety)

**Recopilación y seguridad**

| Pregunta | Respuesta |
|---|---|
| ¿La app recopila o comparte alguno de los tipos de datos requeridos? | **Sí** (los del SDK de anuncios) |
| ¿Todos los datos se cifran en tránsito? | **Sí** (el SDK de Google usa TLS; la app no envía nada más) |
| ¿Qué formas de crear una cuenta ofrece la app? | **Ninguna** (la app no tiene cuentas) |
| ¿Ofreces una forma de pedir que se borren los datos? | **No**. La app no guarda datos fuera del teléfono; los del anuncio los gestiona Google (Mi Centro de anuncios), y el progreso se borra desde la app. La política lo explica |
| ¿La app cumple la política de Familias? | No aplica (público de 13 años o más) |
| Revisión de seguridad independiente | No |

**Tipos de datos**

Los cuatro tipos que siguen se declaran igual:

- **Recopilado** y **compartido** (con Google, la red de anuncios).
- **No** se procesa de forma efímera.
- **Obligatorio**: el usuario no puede desactivarlo dentro de la app.
- **Propósitos:** Publicidad o marketing; Estadísticas; Prevención de fraudes, seguridad y cumplimiento.

| Categoría de Play | Tipo | Por qué (guía de Google, 25.5.0) |
|---|---|---|
| Ubicación | Ubicación aproximada | Dirección IP, que puede usarse para estimar la ubicación general |
| Actividad en la app | Interacciones con la app | Apertura de la app, toques y reproducciones de video |
| Información y rendimiento de la app | Diagnóstico | Tiempo de apertura, bloqueos y consumo de energía |
| Dispositivo u otros ID | Dispositivo u otros ID | ID de publicidad de Android y app set ID |

**No se declaran**, porque la app no los recopila: información personal, información financiera, salud y actividad física, mensajes, fotos y videos, audio, archivos y documentos, calendario, contactos, historial web, ubicación precisa, aplicaciones instaladas, registros de fallas y otros datos de rendimiento de la app.

## Clasificación de contenido (cuestionario IARC)

| Pregunta | Respuesta |
|---|---|
| Correo para la clasificación | nicolas.jorqueramartinez@gmail.com |
| Categoría | **Juego** |
| Violencia, miedo o sangre | No |
| Sexualidad o desnudez | No |
| Lenguaje soez u ofensivo | No. La Sopa de letras usa una lista de palabras bloqueadas en cada idioma. |
| Sustancias controladas (drogas, alcohol, tabaco) | No |
| Humor grosero | No |
| Apuestas o juegos de azar simulados | No |
| Interacción entre usuarios (chat, contenido compartido) | No |
| Comparte la ubicación del usuario con otros usuarios | No |
| Compras digitales | No (no hay compras dentro de la app) |
| Navegación web sin restricciones | No (solo abre la política de privacidad) |

Resultado esperado: la clasificación más baja en cada región, por ejemplo ESRB "Everyone" y PEGI 3. El contenido de los anuncios no entra en el cuestionario; la app los limita a aptos como máximo para adolescentes.

## Público objetivo y contenido

| Pregunta | Respuesta |
|---|---|
| Grupos de edad | **13 a 15, 16 a 17 y 18 años o más** (sin menores de 13) |
| ¿La ficha podría atraer sin querer a menores de 13? | **No**. El icono es geométrico, no hay personajes ni estética infantil, y los textos hablan de juegos de lógica |
| Programa de Familias | No participa |

Debe coincidir con la política, que dice "13 años o más".

## Anuncios

| Pregunta | Respuesta |
|---|---|
| ¿La app contiene anuncios? | **Sí** |

## ID de publicidad

| Pregunta | Respuesta |
|---|---|
| ¿La app usa el ID de publicidad? | **Sí** (permiso `com.google.android.gms.permission.AD_ID`, del SDK de anuncios) |
| Propósitos | Publicidad o marketing; Estadísticas; Prevención de fraudes, seguridad y cumplimiento |

Deben coincidir con los propósitos de "Dispositivo u otros ID" en la sección de seguridad de los datos.

## Otras declaraciones

| Formulario | Respuesta |
|---|---|
| Acceso a la app | Toda la funcionalidad está disponible sin acceso especial: no hay inicio de sesión |
| Política de privacidad | `https://ludixa.web.app/privacidad` (publicar antes, ver `site/README.md`) |
| Eliminación de cuentas | No aplica: la app no permite crear cuentas |
| App de noticias | No |
| App gubernamental | No |
| Funciones financieras | Ninguna |
| Apps de salud | No |
| Permisos sensibles | Ninguno. El manifiesto final pide los permisos de abajo, todos normales y sin formulario propio |

**Permisos del manifiesto final (prod):**
- `INTERNET` y `ACCESS_NETWORK_STATE`;
- `WAKE_LOCK` y `FOREGROUND_SERVICE`, sin tipo. Son de las librerías del SDK de anuncios. Play pide declarar los servicios en primer plano **con tipo**, y aquí no hay ninguno;
- `AD_ID` y los de Privacy Sandbox (`ACCESS_ADSERVICES_*`).

## Antes de enviar

1. Publicar el sitio (`site/README.md`) para que la URL de la política responda.
2. Completar los formularios con estas respuestas. La vista previa de la sección pública de seguridad de los datos debe mostrar los cuatro tipos de arriba, compartidos y cifrados.
3. Si la consola muestra alguna advertencia, anotarla aquí con lo que se hizo.
