import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/iap_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/widgets/glass_card.dart';

class ProUpgradeScreen extends StatefulWidget {
  final int initialPlanIndex;
  const ProUpgradeScreen({super.key, this.initialPlanIndex = 1});

  @override
  State<ProUpgradeScreen> createState() => _ProUpgradeScreenState();
}

class _ProUpgradeScreenState extends State<ProUpgradeScreen> {
  final iapController = Get.find<IAPController>();

  // 0: Freemium, 1: Gold, 2: Platinum
  final RxInt selectedPlanIndex = 1.obs;

  final List<PlanModel> plans = [
    PlanModel(
      title: "Free",
      basePrice: "Free Forever",
      productId: null,
      features: [
        "Basic Batch Compression",
        "Standard Editor Tools",
        "Contains Ads",
        "No AI Tools Access",
      ],
      color: Colors.white70,
      buttonText: "Current Active Plan",
    ),
    PlanModel(
      title: "Gold Pro",
      basePrice: "\$1.99 / mo",
      productId: 'pro_monthly',
      features: [
        "Ad-Free Squeeze Experience",
        "Fast Batch Processing",
        "Premium Photo Editing Suite",
        "No Compression Limits",
      ],
      color: Colors.amber,
      buttonText: "Upgrade to Gold Pro",
      isPopular: false,
    ),
    PlanModel(
      title: "Platinum Ultra",
      basePrice: "\$2.99 / mo",
      productId: 'ultra_monthly',
      features: [
        "Everything in Gold Pro",
        "Full AI Studio Access",
        "1-Tap Background Remover",
        "HD AI Image Upscaler",
        "AI Headshot Generator",
        "Priority Customer Support",
      ],
      color: Colors.cyanAccent,
      buttonText: "Upgrade to Platinum Ultra",
      isPopular: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Use the initialPlanIndex if provided, otherwise use the user's current plan
    if (widget.initialPlanIndex != 1) {
      selectedPlanIndex.value = widget.initialPlanIndex;
    } else if (iapController.isUltraUser) {
      selectedPlanIndex.value = 2;
    } else if (iapController.isProUser) {
      selectedPlanIndex.value = 1;
    } else {
      selectedPlanIndex.value = widget.initialPlanIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: () => iapController.restorePurchases(),
            child: const Text(
              "Restore",
              style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      _buildDynamicFeatures(),
                      const SizedBox(height: 24),
                      _buildPlanSelectionList(),
                      const SizedBox(height: 24),
                      _buildSubscribeButton(),
                      const SizedBox(height: 16),
                      _buildLegalFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.heroCardGradient,
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.workspace_premium_rounded, size: 36, color: Colors.white),
        ),
        const SizedBox(height: 12),
        const Text(
          "Unlock Premium Power",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Remove ads, enable AI cutouts & unlimited batch processing",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
        ),
      ],
    );
  }

  Widget _buildDynamicFeatures() {
    return Obx(() {
      final plan = plans[selectedPlanIndex.value];
      return GlassCard(
        padding: const EdgeInsets.all(20),
        borderColor: plan.color.withValues(alpha: 0.4),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: plan.color, size: 20),
                const SizedBox(width: 8),
                Text(
                  "${plan.title} Plan Highlights",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: plan.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...plan.features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(
                      feature.startsWith("No ") && !feature.contains("Ads") && !feature.contains("Limits")
                          ? Icons.remove_circle_outline
                          : Icons.check_circle_rounded,
                      color: feature.startsWith("No ") && !feature.contains("Ads") && !feature.contains("Limits")
                          ? Colors.redAccent
                          : plan.color,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPlanSelectionList() {
    return Obx(
      () => Column(
        children: List.generate(plans.length, (index) {
          final plan = plans[index];
          final isSelected = selectedPlanIndex.value == index;

          String displayPrice;
          if (plan.productId == null) {
            displayPrice = plan.basePrice ?? 'Free';
          } else {
            // Use native currency from the store (locale-aware price)
            final product = iapController.products.firstWhereOrNull(
              (p) => p.id == plan.productId,
            );
            if (product != null) {
              // product.price from IAP is already in the user's local currency
              displayPrice = '${product.price} / mo';
            } else {
              // Products not loaded yet (offline or store unavailable)
              displayPrice = iapController.isLoading.value ? 'Loading...' : (plan.basePrice ?? '–');
            }
          }

          return GestureDetector(
            onTap: () => selectedPlanIndex.value = index,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? plan.color.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? plan.color : Colors.white.withValues(alpha: 0.1),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? plan.color : Colors.white38,
                        width: 2,
                      ),
                      color: isSelected ? plan.color : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.black)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? plan.color : Colors.white,
                            ),
                          ),
                          if (plan.isPopular) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.pinkAccent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "BEST VALUE",
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    displayPrice,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return Obx(() {
      final plan = plans[selectedPlanIndex.value];

      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () {
            if (plan.productId == 'pro_monthly') {
              iapController.buyPro();
            } else if (plan.productId == 'ultra_monthly') {
              iapController.buyUltra();
            } else {
              if (Get.isSnackbarOpen) Get.closeAllSnackbars();
              Get.snackbar(
                "Current Plan",
                "You are currently using the free tier.",
                colorText: Colors.white,
                backgroundColor: Colors.black87,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: plan.color,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            plan.buttonText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLegalFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => iapController.restorePurchases(),
          child: Text(
            "Restore Purchases",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
          ),
        ),
        Text("•", style: TextStyle(color: Colors.white.withValues(alpha: 0.3))),
        TextButton(
          onPressed: () {},
          child: Text(
            "Privacy Policy",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
          ),
        ),
        Text("•", style: TextStyle(color: Colors.white.withValues(alpha: 0.3))),
        TextButton(
          onPressed: () {},
          child: Text(
            "Terms of Service",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class PlanModel {
  final String title;
  final String? basePrice;
  final String? productId;
  final List<String> features;
  final Color color;
  final String buttonText;
  final bool isPopular;

  PlanModel({
    required this.title,
    required this.basePrice,
    this.productId,
    required this.features,
    required this.color,
    required this.buttonText,
    this.isPopular = false,
  });
}
