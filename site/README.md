# Sitio de Ludixa (P-04)

Política de privacidad en español e inglés y `app-ads.txt`, para Firebase Hosting (plan gratuito Spark). Lo preparé yo; lo publica el responsable de la cuenta.

| Página | URL publicada |
|---|---|
| `public/index.html` | `https://<proyecto>.web.app/` |
| `public/privacidad.html` | `https://<proyecto>.web.app/privacidad` |
| `public/privacy.html` | `https://<proyecto>.web.app/privacy` |
| `public/app-ads.txt` | `https://<proyecto>.web.app/app-ads.txt` |

## Antes de publicar

La política es un **borrador basado en lo que la app hace hoy**: SDK, permisos y datos que guarda, revisados en el código. Lo legal lo define Legal/Administración (P-01). Completar todas las marcas `[[...]]`:

| Marca | Quién la completa |
|---|---|
| Nombre del desarrollador y correo de contacto (el correo público de la ficha de Play) | Tú, con lo que defina P-01 |
| Menores de edad: público objetivo y edad mínima | Legal/Administración, coherente con la declaración de público objetivo de Play (H8-03) |
| Derechos de las personas según la ley aplicable | Legal/Administración |
| Fecha de publicación | Al publicar |
| `app-ads.txt`: reemplazar `pub-0000000000000000` por tu ID de editor | Tú, en AdMob (Cuenta › Información de la cuenta) |

`firebase deploy` corre antes `tool/check_site.sh`, que no deja publicar mientras quede una marca o el ID de ejemplo.

Si la app cambia lo que hace con los datos, hay que actualizar la política **antes** de publicar esa versión. Por ejemplo, Firebase Analytics (H6-05) obliga a cambiarla.

## Publicar

```bash
npm install -g firebase-tools
firebase login
cd site
firebase use --add                  # elegir el proyecto de Firebase de Ludixa
firebase deploy --only hosting
```

## Después de publicar

1. **Play Console:**
   - poner la URL de `/privacidad` como política de privacidad de la app;
   - en la ficha, poner `https://<proyecto>.web.app` como sitio web del desarrollador. AdMob busca `app-ads.txt` en ese dominio.
2. **AdMob:** en Apps › Configuración de app-ads.txt, verificar el archivo. Puede tardar hasta 24 horas.
3. **App:** Ajustes › Información › Política de privacidad abre `https://ludixa.web.app/privacidad` (o `/privacy`). Si el ID del proyecto cambia, actualizar `apps/ludixa/lib/app/links.dart`.
