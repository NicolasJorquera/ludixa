# Ficha de Google Play (H8-02)

Textos, icono y capturas aprobados el 4 de noviembre de 2026. Cada afirmación está comprobada contra la app (niveles, temas, reglas de anuncios).

## Recursos gráficos

| Recurso | Archivo | Requisito de Play |
|---|---|---|
| Icono | `icono-512.png` | 512 × 512, PNG de 32 bits; Play lo redondea |
| Gráfico destacado | `grafico-destacado-es.png`, `grafico-destacado-en.png` | 1024 × 500, sin transparencia |
| Capturas de teléfono | `capturas/*_{es,en}.png` | 2 a 8 por idioma; lado largo ≤ 2× el corto (son 1080 × 1920) |

- **Capturas propuestas** (6 por idioma, en este orden): `01_inicio_claro`, `02_reto_oscuro`, `03_sudoku_claro`, `04_buscaminas_oscuro`, `05_sopa_claro`, `06_progreso_oscuro`. Alternan claro y oscuro, como pide el criterio.
- **Icono:** una grilla de 3×3 con la diagonal resuelta, sobre el azul primario de la app. El mismo diseño es el icono adaptable de Android, con versión monocroma para los iconos temáticos.
- **Cómo regenerar:**
  - todas las imágenes salvo las capturas: `bash tool/ficha_imagenes.sh`, desde la fuente en `fuente/`;
  - las capturas: con `integration_test/screenshots_test.dart` (ver `docs/qa/punta-a-punta.md`).

## Datos de la ficha

| Campo | Valor |
|---|---|
| Categoría | Juegos › Puzles |
| Etiquetas sugeridas | Sudoku, Buscaminas, Sopa de letras, Lógica, Puzles, Sin conexión |
| Desarrollador | Gonisoma |
| Correo de contacto | nicolas.jorqueramartinez@gmail.com (el mismo de la política) |
| Sitio web | `https://ludixa.web.app` (ahí AdMob busca `app-ads.txt`) |
| Política de privacidad | `https://ludixa.web.app/privacidad` |
| Contiene anuncios | Sí |
| Público objetivo | 13 años o más (declararlo igual en Play, H8-03) |

## Español (es-419 y es-ES)

**Título** (30 como máximo)

> Ludixa: Sudoku y Buscaminas

**Descripción breve** (80 como máximo)

> Sudoku, Buscaminas y Sopa de letras: un reto nuevo cada día, sin conexión.

**Descripción completa** (4.000 como máximo)

```text
Ludixa reúne tres juegos de lógica clásicos, Sudoku, Buscaminas y Sopa de letras, con un reto nuevo cada día.

RETO DIARIO
• Cada día, un Sudoku, un Buscaminas y una Sopa de letras: los mismos para todos.
• Suma días a tu racha y llena el calendario. Cada 7 días seguidos ganas un comodín que cubre un día sin jugar.
• ¿Te perdiste un día? Juega los retos de los últimos 30 días desde el archivo.

TRES JUEGOS
• Sudoku: cuatro niveles, de Fácil a Experto. Las pistas no solo dan el número: muestran la técnica para encontrarlo.
• Buscaminas: tableros que siempre se resuelven con lógica, sin tener que adivinar. De Principiante a Experto.
• Sopa de letras: 20 temas en español y 20 en inglés, en cuatro niveles.

A TU MANERA
• Funciona sin conexión.
• Sin cuentas ni registro: tu progreso queda en tu teléfono y puedes exportarlo.
• Tema claro u oscuro, texto más grande, paleta para daltonismo y compatible con TalkBack.
• Estadísticas por nivel y logros.

ANUNCIOS CON REGLAS CLARAS
Ludixa es gratis gracias a los anuncios, y estas reglas no cambian:
• Nunca verás un anuncio al abrir la app ni en mitad de una partida.
• Como máximo, un anuncio a pantalla completa cada dos puzzles, y nunca en tu primera sesión.
• Los videos con recompensa son siempre opcionales y siempre te dan lo prometido. Después de uno no aparece otro anuncio.
• Fuera de las partidas puede haber un banner pequeño.
```

**Novedades de la versión 1.0**

> Primera versión: Sudoku, Buscaminas y Sopa de letras, con un reto nuevo cada día.

## English (en-US)

**Title** (30 max)

> Ludixa: Sudoku & Minesweeper

**Short description** (80 max)

> Sudoku, Minesweeper and Word search: a new challenge every day, offline.

**Full description** (4,000 max)

```text
Ludixa brings together three classic logic games, Sudoku, Minesweeper and Word search, with a new challenge every day.

DAILY CHALLENGE
• Every day, one Sudoku, one Minesweeper and one Word search: the same for everyone.
• Build your streak and fill the calendar. Every 7 days in a row you earn a saver that covers a missed day.
• Missed a day? Play the challenges from the last 30 days in the archive.

THREE GAMES
• Sudoku: four levels, from Easy to Expert. Hints don't just give you the number: they show you the technique to find it.
• Minesweeper: boards that can always be solved with logic, no guessing needed. From Beginner to Expert.
• Word search: 20 themes in English and 20 in Spanish, across four levels.

YOUR WAY
• Works offline.
• No accounts or sign-up: your progress stays on your phone, and you can export it.
• Light or dark theme, larger text, a colorblind palette and TalkBack support.
• Per-level statistics and achievements.

ADS WITH CLEAR RULES
Ludixa is free thanks to ads, and these rules don't change:
• You'll never see an ad when you open the app or in the middle of a game.
• At most one full-screen ad every two puzzles, and never in your first session.
• Rewarded videos are always optional and always give you what they promise. No other ad shows right after one.
• Outside of games there may be a small banner.
```

**What's new in version 1.0**

> First release: Sudoku, Minesweeper and Word search, with a new challenge every day.

## Palabras de búsqueda

Play no tiene un campo de palabras clave: las toma del título y de las descripciones. Los textos ya incluyen, sin repetirlas de más:
- **Español:** sudoku, buscaminas, sopa de letras, reto diario, lógica, sin conexión, racha, pistas.
- **Inglés:** sudoku, minesweeper, word search, daily challenge, logic, offline, streak, hints.

## Pendiente

- Nombre (P-03): antes de crear la ficha, buscar "Ludixa" en Google Play y en los registros de marcas (INAPI en Chile, EUIPO, USPTO) para descartar conflictos evidentes.
- Si el proyecto de Firebase no puede llamarse `ludixa` (los ID son únicos), cambiar las URL de esta tabla.
- Si se agrega analítica (H6-05) o cambia la política de anuncios, actualizar la descripción.
