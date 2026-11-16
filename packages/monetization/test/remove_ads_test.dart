import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:monetization/monetization.dart';
import 'package:monetization/testing.dart';

/// Compra única «Sin anuncios» con un Play Billing falso. [play] es la
/// cuenta de Google Play, compartida entre «instalaciones».
void main() {
  late FakeInAppPurchase play;

  setUp(() => play = FakeInAppPurchase());
  tearDown(() => play.close());

  /// Una instalación: almacenamiento propio y un [RemoveAds] nuevo, ya
  /// iniciado (escucha las compras y reverifica con Play).
  Future<(RemoveAds, InMemoryRemoveAdsStore)> install({bool savedOwned = false}) async {
    final store = InMemoryRemoveAdsStore(savedOwned);
    final billing = RemoveAds(iap: play, store: store);
    addTearDown(billing.dispose);
    await billing.start();
    await pumpEventQueue();
    return (billing, store);
  }

  test('comprar quita los anuncios, muestra el precio de Play, se reconoce y se guarda', () async {
    final (billing, store) = await install();
    expect(billing.owned, isFalse);
    expect(billing.state.value.price, isNull);

    await billing.loadProduct();
    expect(billing.state.value.price, r'US$2.99');

    play.price = '\$2.990 CLP';
    final other = RemoveAds(iap: play, store: InMemoryRemoveAdsStore());
    addTearDown(other.dispose);
    await other.loadProduct();
    expect(other.state.value.price, '\$2.990 CLP', reason: 'el precio viene siempre de Play');

    await billing.buy();
    await pumpEventQueue();
    expect(billing.owned, isTrue);
    expect(billing.state.value.flow, PurchaseFlow.purchased);
    expect(play.completed, [removeAdsProductId]);
    expect(play.acknowledged, isTrue);
    expect(store.load(), isTrue);

    // Ya comprada, comprar no hace nada.
    play.calls.clear();
    await billing.buy();
    expect(play.calls, isNot(contains('buyNonConsumable')));
  });

  test('instalación nueva: se restaura al abrir (en silencio) y con «Restaurar compra»', () async {
    play
      ..owned = true
      ..acknowledged = true;
    final (silent, store) = await install();
    expect(silent.owned, isTrue);
    expect(silent.state.value.flow, PurchaseFlow.idle);
    expect(store.load(), isTrue);

    final second = RemoveAds(iap: play, store: InMemoryRemoveAdsStore());
    addTearDown(second.dispose);
    await second.restore();
    expect(second.owned, isTrue);
    expect(second.state.value.flow, PurchaseFlow.restored);
  });

  test('restaurar sin compra lo dice', () async {
    final (billing, _) = await install();
    await billing.restore();
    expect(billing.owned, isFalse);
    expect(billing.state.value.flow, PurchaseFlow.nothingToRestore);
  });

  test('revocación: si Play responde que la cuenta no la tiene, manda Play', () async {
    // Un estado copiado de otra cuenta (respaldo de Android) o una compra
    // reembolsada.
    final (billing, store) = await install(savedOwned: true);
    expect(billing.owned, isFalse);
    expect(store.load(), isFalse);

    play
      ..owned = true
      ..acknowledged = true;
    final (bought, boughtStore) = await install();
    expect(bought.owned, isTrue);
    play.refund();
    await bought.verifyWithStore();
    expect(bought.owned, isFalse);
    expect(boughtStore.load(), isFalse);
  });

  test('sin red o sin Play, quien compró sigue sin anuncios', () async {
    play
      ..available = false
      ..failRestore = true;
    final (billing, store) = await install(savedOwned: true);
    expect(billing.owned, isTrue);
    expect(store.load(), isTrue);

    await billing.restore();
    expect(billing.owned, isTrue);
    expect(billing.state.value.flow, PurchaseFlow.unavailable);

    // Play responde, pero la consulta de compras falla: tampoco se revoca.
    play.available = true;
    await billing.verifyWithStore();
    expect(billing.owned, isTrue);
  });

  test('sin Play Billing en el sistema no lanza y sigue con anuncios', () async {
    final billing = RemoveAds(iap: _BrokenInAppPurchase(), store: InMemoryRemoveAdsStore());
    addTearDown(billing.dispose);
    await billing.start();
    await billing.loadProduct();
    await billing.buy();
    expect(billing.owned, isFalse);
    expect(billing.state.value.flow, PurchaseFlow.unavailable);
    await billing.restore();
    expect(billing.state.value.flow, PurchaseFlow.unavailable);
  });

  test('compra pendiente: sigue con anuncios hasta que Play la confirma', () async {
    play.buyResult = FakeBuyResult.pending;
    final (billing, store) = await install();
    await billing.buy();
    await pumpEventQueue();
    expect(billing.state.value.flow, PurchaseFlow.pending);
    expect(billing.owned, isFalse);
    expect(play.completed, isEmpty);

    // Al reabrir la app, Play todavía la tiene pendiente.
    await billing.restore();
    expect(billing.owned, isFalse);
    expect(billing.state.value.flow, PurchaseFlow.pending);

    play.confirmPending();
    await pumpEventQueue();
    expect(billing.owned, isTrue);
    expect(billing.state.value.flow, PurchaseFlow.purchased);
    expect(play.completed, [removeAdsProductId]);
    expect(store.load(), isTrue);
  });

  test('pendiente confirmada con la app cerrada: se reconoce al abrir', () async {
    play
      ..owned = true
      ..acknowledged = false;
    final (billing, _) = await install();
    expect(billing.owned, isTrue);
    expect(play.acknowledged, isTrue);
  });

  test('cancelada o con error: nada cambia', () async {
    play.buyResult = FakeBuyResult.canceled;
    final (billing, store) = await install();
    await billing.buy();
    await pumpEventQueue();
    expect(billing.state.value.flow, PurchaseFlow.canceled);
    expect(billing.owned, isFalse);

    play.buyResult = FakeBuyResult.error;
    await billing.buy();
    await pumpEventQueue();
    expect(billing.state.value.flow, PurchaseFlow.error);
    expect(billing.owned, isFalse);
    expect(store.load(), isFalse);
  });

  test('la cuenta ya la tenía: Play no abre la hoja y se restaura', () async {
    final (billing, _) = await install();
    play.buyResult = FakeBuyResult.alreadyOwned;
    await billing.buy();
    expect(billing.owned, isTrue);
    expect(billing.state.value.flow, PurchaseFlow.restored);
  });

  test('producto inexistente en Play Console: no disponible, sin precio', () async {
    play.productExists = false;
    final (billing, _) = await install();
    await billing.loadProduct();
    expect(billing.state.value.price, isNull);
    await billing.buy();
    expect(billing.state.value.flow, PurchaseFlow.unavailable);
    expect(billing.owned, isFalse);
    expect(play.calls, isNot(contains('buyNonConsumable')));
  });

  test('sin conexión al comprar: no disponible', () async {
    final (billing, _) = await install();
    play.available = false;
    await billing.buy();
    expect(billing.state.value.flow, PurchaseFlow.unavailable);
    expect(billing.owned, isFalse);
  });

  test('un almacenamiento dañado cuenta como sin compra', () async {
    play.available = false;
    final billing = RemoveAds(iap: play, store: _BrokenStore());
    addTearDown(billing.dispose);
    expect(billing.owned, isFalse);
  });
}

/// Como `InAppPurchase.instance` sin el plugin de Android: todo lanza.
class _BrokenInAppPurchase extends FakeInAppPurchase {
  @override
  Stream<List<PurchaseDetails>> get purchaseStream => throw StateError('sin Play Billing');

  @override
  Future<bool> isAvailable() => throw StateError('sin Play Billing');
}

class _BrokenStore implements RemoveAdsStore {
  @override
  bool load() => throw const FormatException();

  @override
  Future<void> save(bool owned) => throw const FormatException();
}
