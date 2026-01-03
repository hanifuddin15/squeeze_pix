// lib/controllers/iap_controller.dart
import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class IAPController extends GetxController {
  final RxBool isPro = false.obs;
  final RxBool isUltra = false.obs;
  final RxBool storeAvailable = false.obs;
  final RxBool isLoading = true.obs;
  final RxList<ProductDetails> products = <ProductDetails>[].obs;

  // Token System
  final RxInt dailyTokensUsed = 0.obs;
  static const int maxDailyTokens = 20;
  final _box = GetStorage();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;

  static const String _proId = 'pro_monthly';
  static const String _ultraId = 'ultra_monthly';
  final Set<String> _productIds = {_proId, _ultraId};

  bool get isProUser => isPro.value || isUltra.value; // Gold or Platinum
  bool get isUltraUser => isUltra.value; // Platinum only

  @override
  void onInit() {
    super.onInit();
    _loadPersistence();
    _checkTokenReset();
    
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

  void _loadPersistence() {
    isPro.value = _box.read('isPro') ?? false;
    isUltra.value = _box.read('isUltra') ?? false;
    dailyTokensUsed.value = _box.read('dailyTokensUsed') ?? 0;
  }

  void _savePersistence() {
    _box.write('isPro', isPro.value);
    _box.write('isUltra', isUltra.value);
  }

  void _checkTokenReset() {
    final lastResetStr = _box.read<String>('lastTokenReset');
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";

    if (lastResetStr != todayStr) {
      dailyTokensUsed.value = 0;
      _box.write('dailyTokensUsed', 0);
      _box.write('lastTokenReset', todayStr);
    }
  }

  bool hasTokens() {
    if (!isUltraUser) return false;
    _checkTokenReset(); // Ensure we are on the correct day
    return dailyTokensUsed.value < maxDailyTokens;
  }

  bool useToken() {
    if (hasTokens()) {
      dailyTokensUsed.value++;
      _box.write('dailyTokensUsed', dailyTokensUsed.value);
      return true;
    }
    return false;
  }

  int get remainingTokens => isUltraUser ? (maxDailyTokens - dailyTokensUsed.value) : 0;

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
        _savePersistence();
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
