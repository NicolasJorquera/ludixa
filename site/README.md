# Sitio de Ludixa (P-04)

Política de privacidad en español e inglés y `app-ads.txt`, para Firebase Hosting (plan gratuito Spark). Si el proyecto de Firebase no puede llamarse `ludixa` (los ID son únicos), cambiar las URL de este archivo y de `docs/ficha/ficha.md`.

| Página | URL publicada |
|---|---|
| `public/index.html` | `https://ludixa.web.app/` |
| `public/privacidad.html` | `https://ludixa.web.app/privacidad` |
| `public/privacy.html` | `https://ludixa.web.app/privacy` |
| `public/app-ads.txt` | `https://ludixa.web.app/app-ads.txt` |

## Contenido

- Desarrollador: Gonisoma. Contacto: nicolas.jorqueramartinez@gmail.com.
- Público objetivo: 13 años o más. En Play hay que declarar lo mismo (H8-03).
- `app-ads.txt`: ID de editor `pub-3038495459046159`.
- Las secciones de menores y de consultas describen lo que hace la app y cómo escribir. No citan leyes ni son asesoría legal: no hubo revisión legal. Si la app apunta a otros mercados o cambia lo que hace con los datos, conviene que la revise un abogado.

`firebase deploy` corre antes `tool/check_site.sh`, que no deja publicar si queda alguna marca `[[...]]` o el ID de editor de ejemplo.

Si la app cambia lo que hace con los datos, hay que actualizar la política **antes** de publicar esa versión, con su nueva fecha. Por ejemplo, Firebase Analytics (H6-05) obliga a cambiarla.

## Publicar

```bash
npm install -g firebase-tools
firebase login
cd site
firebase use --add                  # elegir el proyecto de Firebase (ID previsto: ludixa)
firebase deploy --only hosting
```

## Después de publicar

1. **Play Console:**
   - poner la URL de `/privacidad` como política de privacidad de la app;
   - en la ficha, poner `https://ludixa.web.app` como sitio web del desarrollador. AdMob busca `app-ads.txt` en ese dominio.
2. **AdMob:** en Apps › Configuración de app-ads.txt, verificar el archivo. Puede tardar hasta 24 horas.
3. **App:** agregar el enlace a la política en Ajustes › Información, con la URL definitiva.
