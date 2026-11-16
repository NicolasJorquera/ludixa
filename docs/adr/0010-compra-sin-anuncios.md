# ADR 0010: Compra única «Sin anuncios»

- Estado: aceptada
- Fecha: 2026-11-16

## Contexto

Todas las apps del dueño son gratis con anuncios y tienen una compra única que los quita. Trainloop ya la tiene (`lib/features/monetization/` de ese repositorio) y es la referencia de comportamiento. Ludixa la tenía prevista desde H6-03: `NoAdsService` existía "para la futura compra que quita los anuncios". No hay backend y no debe haberlo.

En Ludixa los videos con recompensa también son anuncios y dan ayuda concreta: hasta 3 pistas extra por puzzle y el rescate del Buscaminas (ADR 0008, H6-04). Quitar los anuncios sin más dejaría a quien paga con menos ayuda que quien ve los videos.

## Decisiones

1. **Producto `ludixa_remove_ads`, no consumible**, con Google Play Billing (`in_app_purchase` 3.3.1 y `in_app_purchase_android` 0.5.0, que trae `billing` 8.0.0). Se crea en Play Console; la app muestra el precio que devuelve Play y nunca uno fijo. Si Play no informa el precio, el botón dice solo "Quitar anuncios".
2. **`RemoveAds` en `packages/monetization`**, junto a AdMob, como pide la arquitectura. No conoce Riverpod ni las preferencias: recibe un `InAppPurchase` y un `RemoveAdsStore`. La app lo conecta (`features/ads/remove_ads.dart`) y guarda el estado en las preferencias del dispositivo (`ads.removed`), como los contadores de anuncios: no se exporta con el progreso.
3. **Estado local, reverificado con Play al abrir.** El valor guardado se lee antes del primer fotograma (sin parpadeo de un banner). Al crear `RemoveAds` se escuchan las compras y se consulta a Play (`restorePurchases`) en segundo plano:
   - si Play responde, **su respuesta manda**: restaura en un teléfono nuevo y también **revoca** (reembolso, o un estado copiado por la copia automática de Android desde otra cuenta);
   - sin red, sin Play Store o si la consulta falla, se mantiene lo guardado: quien compró sigue sin anuncios sin conexión.
   - La validación es en el teléfono, sin servidor propio. Se acepta el riesgo de fraude, como en Trainloop.
4. **Flujos**: comprar, **reconocer** cada compra (`completePurchase`; si no, Play la reembolsa a los 3 días; también se reconoce al abrir una que Play confirmó con la app cerrada), "Restaurar compra", pendiente (los anuncios siguen hasta que Play la confirme; el botón de compra queda desactivado), cancelada, error y **no disponible** (sin Play, sin red o producto inexistente). Nada de esto lanza: sin Play Billing la app sigue con anuncios. Dos detalles de `in_app_purchase_android` 0.5.0 que la referencia de Trainloop no cubría:
   - cuando la hoja se cierra sin compra (cancelada, error o ITEM_ALREADY_OWNED), el aviso llega con **`productID` vacío**. Mientras hay una compra en curso, ese aviso se toma como del producto: cancelada, error o, si la cuenta ya la tiene, restaurar. Si se descartara, la tarjeta quedaría esperando. Fuera de una compra en curso se ignora;
   - si la cuenta ya la tiene, `buyNonConsumable` **devuelve false sin lanzar**. Entonces se reverifica con Play: si la cuenta la tiene, queda restaurada; si no, error.
5. **Con la compra, sin anuncios**: `adServiceProvider` devuelve `NoAdsService` (ni banners ni intersticiales). Lo mira antes que `adsReady`, que conserva su valor anterior mientras se recalcula.
6. **Con la compra no se pide consentimiento ni se inicia el SDK de anuncios** (`adsReadyProvider`), y "Opciones de privacidad" no aparece: la app no usa anuncios. Si Play revoca la compra, `adsReady` se recalcula y corre el arranque normal (UMP y SDK). En una instalación nueva el primer arranque todavía no sabe de la compra y arranca los anuncios como siempre hasta que Play responde.
7. **Pistas y rescate sin video (lo que hoy da el video, sin verlo)**:
   - Las **2 gratis** siguen igual. Las **3 extra** por puzzle se entregan **directo, sin hoja ni video**, con el mismo límite (`HintDenial.limitReached` después de 5). Nadie que paga queda con menos ayuda que quien ve videos, y tampoco con más: el límite del puzzle es el mismo.
   - El contador del botón Pista incluye las extra que quedan (5 al empezar), porque para quien compró no piden nada.
   - Nuevo `HintSource.adFree` en `game_api`. Se guarda como pista "con video" (`rewardedHints`): al retomar una partida, las extra usadas no vuelven, compre o no a mitad de puzzle.
   - La **cortesía del día** no hace falta: no se ofrece ni se gasta.
   - **Rescate del Buscaminas**: nuevo `GameHost.adFree` en el contrato. Con la compra, el host lo concede sin video (una vez por partida, lo sigue aplicando el motor) y la derrota muestra "Deshacer el último toque" / "Una vez por partida." sin icono de video, aunque no haya un video cargado.
   - El host lee la compra en cada pedido: si Play confirma una compra pendiente con la partida abierta, las extra que quedan pasan a ser sin video.
8. **UI**: sección "Sin anuncios" en Ajustes, entre Juegos y Datos y privacidad, con una tarjeta: qué incluye, "Quitar anuncios · <precio de Play>", "Restaurar compra" y el estado (anunciado al lector de pantalla). Con la compra activa, la tarjeta solo agradece. El precio se consulta al abrir Ajustes, no al abrir la app. Textos en `app_es.arb` / `app_en.arb` (la pseudolocalización se regenera) y en los textos del Buscaminas.
9. **Pruebas con un `InAppPurchase` falso** (`package:monetization/testing.dart`, `FakeInAppPurchase`), como en Trainloop. Imita a Android: `restorePurchases` entrega las compras de la cuenta como restauradas, también las pendientes (su estado real va en `billingClientPurchase`), y lleva la cuenta de lo reconocido.

## Consecuencias

- `docs/ficha/declaraciones.md` declara compras dentro de la app, el permiso `BILLING` y la nueva respuesta del cuestionario de clasificación (compras digitales: sí). La política del sitio (`site/public/`) explica la compra; hay que publicar el sitio antes de la versión que la trae.
- **Probar una compra real** necesita la variante prod (el ID `com.gonisoma.ludixa`; la variante dev, `.dev`, no tiene el producto y muestra "no disponible"), el producto activo en Play Console, una versión subida a una pista de prueba y una cuenta de prueba de licencias. Esto no se pudo hacer al implementarla: las pruebas son con Play falso.
- Un cambio en el contrato `GameHost` obliga a implementar `adFree` en cada host (app, tutorial y los de prueba).
