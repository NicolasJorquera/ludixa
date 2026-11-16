import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

/// Producto no consumible «Sin anuncios» en Play Console.
const removeAdsProductId = 'ludixa_remove_ads';

/// Qué está pasando con la compra (lo muestra la tarjeta de Ajustes).
enum PurchaseFlow {
  idle,

  /// Consultando a Play o abriendo la hoja de compra.
  busy,

  /// Play la dejó pendiente (pago en efectivo, aprobación familiar…): los
  /// anuncios siguen hasta que Play la confirme.
  pending,

  /// Comprada o restaurada en esta sesión.
  purchased,
  restored,

  /// «Restaurar compra»: esta cuenta de Play no la tiene.
  nothingToRestore,
  canceled,
  error,

  /// Sin Play Store, sin red o el producto no existe en Play Console.
  unavailable,
}

@immutable
final class RemoveAdsState {
  const RemoveAdsState({this.owned = false, this.flow = PurchaseFlow.idle, this.price});

  /// La persona compró «Sin anuncios» (guardado en el teléfono y
  /// reverificado con Play al abrir la app).
  final bool owned;
  final PurchaseFlow flow;

  /// Precio localizado que informa Play; null si no se pudo consultar. Nunca
  /// hay un precio fijo en la app.
  final String? price;

  RemoveAdsState copyWith({bool? owned, PurchaseFlow? flow, String? price}) =>
      RemoveAdsState(owned: owned ?? this.owned, flow: flow ?? this.flow, price: price ?? this.price);

  @override
  bool operator ==(Object other) =>
      other is RemoveAdsState && other.owned == owned && other.flow == flow && other.price == price;

  @override
  int get hashCode => Object.hash(owned, flow, price);

  @override
  String toString() => 'RemoveAdsState(owned: $owned, ${flow.name}, $price)';
}

/// Dónde se guarda si la compra está hecha (preferencias del dispositivo; no
/// se exporta con el progreso).
abstract interface class RemoveAdsStore {
  bool load();
  Future<void> save(bool owned);
}

final class InMemoryRemoveAdsStore implements RemoveAdsStore {
  InMemoryRemoveAdsStore([this._owned = false]);

  bool _owned;

  @override
  bool load() => _owned;

  @override
  Future<void> save(bool owned) async => _owned = owned;
}

/// Compra única «Sin anuncios» con Google Play Billing, sin servidor.
///
/// * El estado se guarda en el teléfono ([RemoveAdsStore]) y se lee al crear
///   el objeto: sin red, quien compró sigue sin anuncios.
/// * [start] escucha las compras y reverifica en silencio
///   ([verifyWithStore]): si Play responde, su respuesta manda (también
///   revoca una compra reembolsada o un estado copiado de otra cuenta).
///   Sin servidor propio, la validación es en el teléfono.
/// * Las compras se reconocen ([InAppPurchase.completePurchase]) para que
///   Play no las reembolse a los 3 días.
/// * Nada de esto lanza: sin Play Billing la app sigue con anuncios.
final class RemoveAds {
  RemoveAds({required InAppPurchase iap, required RemoveAdsStore store}) : _iap = iap, _store = store {
    var owned = false;
    try {
      owned = store.load();
    } on Object {
      // Un valor dañado cuenta como sin compra; Play lo corrige al abrir.
    }
    _state.value = RemoveAdsState(owned: owned);
  }

  final InAppPurchase _iap;
  final RemoveAdsStore _store;
  final _state = ValueNotifier(const RemoveAdsState());
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _product;

  /// Compras restauradas que llegan mientras se espera a [restorePurchases].
  List<PurchaseDetails>? _restoreBatch;
  Future<void>? _restoring;
  bool _disposed = false;

  ValueListenable<RemoveAdsState> get state => _state;

  bool get owned => _state.value.owned;

  /// Escucha las compras (las que Play confirma con la app cerrada llegan
  /// aquí) y reverifica con Play.
  Future<void> start() async {
    if (_listen()) await verifyWithStore();
  }

  /// false si no hay Play Billing (otro sistema, pruebas): la app sigue con
  /// anuncios.
  bool _listen() {
    try {
      _sub ??= _iap.purchaseStream.listen((p) => unawaited(_onPurchases(p)), onError: (Object _) {});
      return true;
    } on Object {
      return false;
    }
  }

  void dispose() {
    _disposed = true;
    unawaited(_sub?.cancel());
    _state.dispose();
  }

  /// Consulta el precio para mostrarlo.
  Future<void> loadProduct() async {
    final product = await _queryProduct();
    if (product != null) _set(_state.value.copyWith(price: product.price));
  }

  /// Abre la hoja de compra de Play. El resultado llega por
  /// [InAppPurchase.purchaseStream].
  Future<void> buy() async {
    if (owned || _state.value.flow == PurchaseFlow.busy) return;
    _setFlow(PurchaseFlow.busy);
    try {
      final product = await _queryProduct();
      if (product == null) {
        _setFlow(PurchaseFlow.unavailable);
        return;
      }
      _set(_state.value.copyWith(price: product.price));
      final launched = await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
      // Play no abre la hoja si la cuenta ya la tiene: se restaura.
      if (!launched) return await _restoreOrFail();
      // La hoja de Play quedó abierta encima de la app; el resultado llega
      // por el stream. Si nunca llegara, los botones no quedan bloqueados.
      if (_state.value.flow == PurchaseFlow.busy) _setFlow(PurchaseFlow.idle);
    } on Object catch (e) {
      if (_isAlreadyOwned(e)) {
        await _restoreOrFail();
      } else {
        _setFlow(PurchaseFlow.error);
      }
    }
  }

  /// «Restaurar compra»: consulta las compras de la cuenta de Play.
  Future<void> restore() => _restore(userInitiated: true);

  /// Al abrir la app: reverifica en silencio.
  Future<void> verifyWithStore() => _restore(userInitiated: false);

  Future<void> _restoreOrFail() async {
    await _restore(userInitiated: false);
    _setFlow(owned ? PurchaseFlow.restored : PurchaseFlow.error);
  }

  Future<void> _restore({required bool userInitiated}) async {
    // Si ya hay una consulta en curso, se espera; la de la persona se hace
    // igual después, para darle una respuesta.
    while (_restoring != null) {
      await _restoring;
      if (!userInitiated) return;
    }
    final done = Completer<void>();
    _restoring = done.future;
    if (userInitiated) _setFlow(PurchaseFlow.busy);
    _restoreBatch = [];
    try {
      if (!_listen() || !await _iap.isAvailable()) {
        if (userInitiated) _setFlow(PurchaseFlow.unavailable);
        return;
      }
      await _iap.restorePurchases();
      // El lote llega por el stream junto con el final de la llamada.
      await Future<void>.delayed(Duration.zero);
      final batch = _restoreBatch ?? const <PurchaseDetails>[];
      final isOwned = batch.any((p) => !_isPending(p));
      final pending = batch.any(_isPending);
      for (final p in batch) {
        if (!_isPending(p)) await _complete(p);
      }
      // Play respondió: su respuesta manda, también para revocar.
      await _saveOwned(isOwned);
      if (userInitiated) {
        _setFlow(
          isOwned
              ? PurchaseFlow.restored
              : pending
              ? PurchaseFlow.pending
              : PurchaseFlow.nothingToRestore,
        );
      }
    } on Object catch (e) {
      // Sin red o sin Play: se mantiene lo guardado.
      if (kDebugMode) debugPrint('[compra] restaurar: $e');
      if (userInitiated) _setFlow(PurchaseFlow.unavailable);
    } finally {
      _restoreBatch = null;
      _restoring = null;
      done.complete();
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    final mine = purchases.where((p) => p.productID == removeAdsProductId).toList();
    // Primero, sin esperar, lo que pertenece a una restauración en curso.
    final batch = _restoreBatch;
    if (batch != null) batch.addAll(mine.where((p) => p.status == PurchaseStatus.restored));
    for (final p in mine) {
      if (batch != null && p.status == PurchaseStatus.restored) continue;
      switch (p.status) {
        case PurchaseStatus.pending:
          _setFlow(PurchaseFlow.pending);
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (_isPending(p)) {
            _setFlow(PurchaseFlow.pending);
            continue;
          }
          await _saveOwned(true);
          _setFlow(p.status == PurchaseStatus.purchased ? PurchaseFlow.purchased : PurchaseFlow.restored);
        case PurchaseStatus.canceled:
          _setFlow(PurchaseFlow.canceled);
        case PurchaseStatus.error:
          if (_isAlreadyOwned(p.error)) {
            await _complete(p);
            await _restoreOrFail();
            continue;
          }
          _setFlow(PurchaseFlow.error);
      }
      await _complete(p);
    }
  }

  Future<ProductDetails?> _queryProduct() async {
    if (_product case final p?) return p;
    try {
      if (!await _iap.isAvailable()) return null;
      final response = await _iap.queryProductDetails({removeAdsProductId});
      return _product = response.productDetails.where((p) => p.id == removeAdsProductId).firstOrNull;
    } on Object {
      return null;
    }
  }

  Future<void> _complete(PurchaseDetails p) async {
    if (!p.pendingCompletePurchase) return;
    try {
      await _iap.completePurchase(p);
    } on Object {
      // Se reintenta en la próxima reverificación.
    }
  }

  Future<void> _saveOwned(bool value) async {
    _set(_state.value.copyWith(owned: value));
    try {
      await _store.save(value);
    } on Object {
      // Queda en memoria; se vuelve a guardar en la próxima reverificación.
    }
  }

  void _setFlow(PurchaseFlow flow) => _set(_state.value.copyWith(flow: flow));

  void _set(RemoveAdsState value) {
    if (_disposed) return;
    _state.value = value;
  }

  /// En Android, `restorePurchases` marca como restauradas también las
  /// compras pendientes: hay que mirar el estado de Play.
  static bool _isPending(PurchaseDetails p) =>
      p.status == PurchaseStatus.pending ||
      (p is GooglePlayPurchaseDetails && p.billingClientPurchase.purchaseState == PurchaseStateWrapper.pending);

  static bool _isAlreadyOwned(Object? e) =>
      e.toString().contains('itemAlreadyOwned') || e.toString().contains('ITEM_ALREADY_OWNED');
}
