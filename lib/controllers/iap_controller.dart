// lib/controllers/iap_controller.dart
import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class IAPController extends GetxController {
  final RxBool isPro = false.obs;
  final RxBool isUltra = false.obs;
  final RxBool storeAvailable = false.obs;
  final RxBool isLoading = true.obs;
  final RxList<ProductDetails> products = <ProductDetails>[].obs;

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;

  static const String _proId = 'pro_monthly';
  static const String _ultraId = 'ultra_monthly';
  final Set<String> _productIds = {_proId, _ultraId};

  @override
  void onInit() {
    super.onInit();
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _purchaseSubscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdates(purchaseDetailsList);
      },
      onDone: () {
        _purchaseSubscription.cancel();
      },
      onError: (error) {
        log("Purchase Stream Error: $error");
      },
    );
    _initializeIAP();
  }

  @override
  void onClose() {
    _purchaseSubscription.cancel();
    super.onClose();
  }

  Future<void> _initializeIAP() async {
    storeAvailable.value = await _iap.isAvailable();
    if (storeAvailable.value) {
      await _loadProducts();
      await _iap.restorePurchases();
    }
    isLoading.value = false;
  }

  Future<void> _loadProducts() async {
    ProductDetailsResponse response = await _iap.queryProductDetails(
      _productIds,
    );
    if (response.error != null) {
      log("Error loading products: ${response.error!.message}");
    }
    if (response.notFoundIDs.isNotEmpty) {
      log("Products not found: ${response.notFoundIDs}");
    }
    products.assignAll(response.productDetails);
  }

  void _listenToPurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.error) {
        log("Purchase Error: ${purchaseDetails.error}");
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        if (purchaseDetails.productID == _proId) isPro.value = true;
        if (purchaseDetails.productID == _ultraId) isUltra.value = true;
      }
      if (purchaseDetails.pendingCompletePurchase) {
        _iap.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> buyPro() async {
    final ProductDetails? proDetails = products.firstWhereOrNull(
      (p) => p.id == _proId,
    );
    if (proDetails != null) {
      final param = PurchaseParam(productDetails: proDetails);
      await _iap.buyNonConsumable(purchaseParam: param);
    }
  }

  Future<void> buyUltra() async {
    final ProductDetails? ultraDetails = products.firstWhereOrNull(
      (p) => p.id == _ultraId,
    );
    if (ultraDetails != null) {
      final param = PurchaseParam(productDetails: ultraDetails);
      await _iap.buyNonConsumable(purchaseParam: param);
    }
  }
}
