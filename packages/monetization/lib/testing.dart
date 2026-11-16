/// Google Play Billing falso para las pruebas del paquete y de la app.
library;

import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart'
    show InAppPurchasePlatformAddition;

import 'src/remove_ads.dart';

/// Qué responde Play al comprar.
enum FakeBuyResult { purchased, pending, canceled, error, alreadyOwned }

/// Google Play Billing de prueba, sin canal nativo. [owned] es lo que la
/// cuenta tiene en Play: sobrevive a una «instalación nueva» (otro
/// almacenamiento y otro [RemoveAds]).
class FakeInAppPurchase implements InAppPurchase {
  FakeInAppPurchase({
    this.available = true,
    this.productExists = true,
    this.buyResult = FakeBuyResult.purchased,
    this.owned = false,
    this.failRestore = false,
    this.price = r'US$2.99',
  });

  /// Play Billing responde (false: sin Play Store o sin conexión).
  bool available;

  /// El producto existe en Play Console.
  bool productExists;
  FakeBuyResult buyResult;
  bool owned;

  /// La consulta de compras falla (sin red).
  bool failRestore;
  String price;

  /// La compra quedó pendiente en Play (se confirma con [confirmPending]).
  bool pendingInStore = false;

  /// La app ya reconoció la compra; si no, Play la reembolsa a los 3 días.
  bool acknowledged = false;

  final calls = <String>[];

  /// Productos reconocidos con [completePurchase].
  final completed = <String>[];
  final _updates = StreamController<List<PurchaseDetails>>.broadcast();

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _updates.stream;

  @override
  Future<bool> isAvailable() async {
    calls.add('isAvailable');
    return available;
  }

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) async {
    calls.add('queryProductDetails');
    final exists = productExists && identifiers.contains(removeAdsProductId);
    return ProductDetailsResponse(
      productDetails: [
        if (exists)
          ProductDetails(
            id: removeAdsProductId,
            title: 'Sin anuncios',
            description: '',
            price: price,
            rawPrice: 2.99,
            currencyCode: 'USD',
          ),
      ],
      notFoundIDs: exists ? const [] : identifiers.toList(),
    );
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    calls.add('buyNonConsumable');
    if (buyResult == FakeBuyResult.alreadyOwned) {
      // Play no abre la hoja: la cuenta ya la tiene.
      owned = true;
      return false;
    }
    scheduleMicrotask(() {
      switch (buyResult) {
        case FakeBuyResult.purchased:
          owned = true;
          _emit(PurchaseStatus.purchased);
        case FakeBuyResult.pending:
          pendingInStore = true;
          _emit(PurchaseStatus.pending, complete: false);
        case FakeBuyResult.canceled:
          _emit(PurchaseStatus.canceled, complete: false);
        case FakeBuyResult.error:
          _emit(PurchaseStatus.error, complete: false);
        case FakeBuyResult.alreadyOwned:
      }
    });
    return true;
  }

  /// Play confirma la compra pendiente (llega por el stream, también con la
  /// app abierta en otra pantalla).
  void confirmPending() {
    pendingInStore = false;
    owned = true;
    _emit(PurchaseStatus.purchased);
  }

  /// Play reembolsa la compra: deja de estar en la cuenta.
  void refund() {
    owned = false;
    acknowledged = false;
  }

  void _emit(PurchaseStatus status, {bool complete = true}) =>
      _updates.add([_details(status)..pendingCompletePurchase = complete]);

  static PurchaseDetails _details(PurchaseStatus status) => PurchaseDetails(
    purchaseID: 'GPA.0000-0000-0000-00000',
    productID: removeAdsProductId,
    verificationData: PurchaseVerificationData(localVerificationData: '', serverVerificationData: '', source: 'fake'),
    transactionDate: '0',
    status: status,
  );

  /// Como en Android: las compras de la cuenta llegan como restauradas,
  /// también las pendientes (su estado real va en `billingClientPurchase`).
  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    calls.add('restorePurchases');
    if (failRestore) throw InAppPurchaseException(source: 'fake', code: 'restore_failed', message: 'sin red');
    _updates.add([
      if (owned || pendingInStore)
        for (final details in GooglePlayPurchaseDetails.fromPurchase(
          PurchaseWrapper(
            orderId: 'GPA.0000-0000-0000-00000',
            packageName: 'com.gonisoma.ludixa',
            purchaseTime: 0,
            purchaseToken: 'token',
            signature: '',
            products: const [removeAdsProductId],
            isAutoRenewing: false,
            originalJson: '{}',
            isAcknowledged: acknowledged,
            purchaseState: owned ? PurchaseStateWrapper.purchased : PurchaseStateWrapper.pending,
          ),
        ))
          details
            ..status = PurchaseStatus.restored
            ..pendingCompletePurchase = owned && !acknowledged,
    ]);
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    calls.add('completePurchase');
    completed.add(purchase.productID);
    if (owned) acknowledged = true;
  }

  @override
  Future<bool> buyConsumable({required PurchaseParam purchaseParam, bool autoConsume = true}) =>
      throw UnimplementedError('Ludixa no vende consumibles');

  @override
  Future<String> countryCode() async => 'CL';

  @override
  T getPlatformAddition<T extends InAppPurchasePlatformAddition?>() => throw UnimplementedError();

  Future<void> close() => _updates.close();
}
