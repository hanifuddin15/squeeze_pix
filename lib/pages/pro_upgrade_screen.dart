import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/iap_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/widgets/glassmorphic_button.dart';

class ProUpgradeScreen extends StatefulWidget {
  const ProUpgradeScreen({super.key});

  @override
  State<ProUpgradeScreen> createState() => _ProUpgradeScreenState();
}

class _ProUpgradeScreenState extends State<ProUpgradeScreen> {
  final iapController = Get.find<IAPController>();

  // 0: Freemium, 1: Gold, 2: Platinum
  final RxInt selectedPlanIndex = 1.obs;

  final List<PlanModel> plans = [
    PlanModel(
      title: "Freemium",
      basePrice: "Free Forever",
      productId: null,
      features: [
        "Basic Compression",
        "Basic Editing",
        "Contains Ads",
        "No AI Tools",
      ],
      color: Colors.white,
      buttonText: "Current Plan",
    ),
    PlanModel(
      title: "Gold",
      basePrice: "৳199 / Month",
      productId: 'pro_monthly',
      features: [
        "No Ads",
        "Fast Batch Processing",
        "Premium Editing Tools",
        "No AI Tools",
      ],
      color: Colors.amber,
      buttonText: "Upgrade to Gold",
    ),
    PlanModel(
      title: "Platinum",
      basePrice: "৳299 / Month",
      productId: 'ultra_monthly',
      features: [
        "All Gold Features",
        "AI Tools Access",
        "BG Remover",
        "Priority Support",
      ],
      color: Colors.cyanAccent,
      buttonText: "Upgrade to Platinum",
      isPopular: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Default to Gold or current plan if active
    if (iapController.isUltraUser) {
      selectedPlanIndex.value = 2;
    } else if (iapController.isProUser) {
      selectedPlanIndex.value = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: Column(
          children: [
            const SizedBox(height: 80),
            _buildHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    _buildDynamicFeatures(),
                    const SizedBox(height: 30),
                    _buildPlanSelectionList(),
                    const SizedBox(height: 30),
                    _buildSubscribeButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: const [
        Text(
          "Choose Your Plan",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Unlock the full power of Squeeze Pix",
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildDynamicFeatures() {
    return Obx(() {
      final plan = plans[selectedPlanIndex.value];
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: plan.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: plan.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              "${plan.title} Features",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: plan.color,
              ),
            ),
            const SizedBox(height: 20),
            ...plan.features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Centered features
                  children: [
                    Icon(
                      feature.contains("No") && !feature.contains("Ads")
                          ? Icons.close
                          : Icons.check_circle,
                      color: feature.contains("No") && !feature.contains("Ads")
                          ? Colors.redAccent.withValues(alpha: 0.8)
                          : plan.color,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      feature,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(
        () => Column(
          children: List.generate(plans.length, (index) {
            final plan = plans[index];
            final isSelected = selectedPlanIndex.value == index;

            // Get price from IAP controller if available
            String displayPrice = plan.basePrice;
            if (plan.productId != null) {
              final product = iapController.products.firstWhereOrNull(
                (p) => p.id == plan.productId,
              );
              if (product != null) {
                displayPrice = "${product.price} / Month"; // Localized price
              }
            }

            return GestureDetector(
              onTap: () => selectedPlanIndex.value = index,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? plan.color.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? plan.color
                        : Colors.white.withValues(alpha: 0.1),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Customizable Checkbox
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? plan.color : Colors.white38,
                          width: 2,
                        ),
                        color: isSelected ? plan.color : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.black,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? plan.color : Colors.white,
                          ),
                        ),
                        if (plan.isPopular)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.pinkAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "Best Value",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      displayPrice,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return Obx(() {
      final plan = plans[selectedPlanIndex.value];

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GlassmorphicButton(
          onPressed: () {
            if (plan.productId == 'pro_monthly') {
              iapController.buyPro();
            } else if (plan.productId == 'ultra_monthly') {
              iapController.buyUltra();
            } else {
              // Action for Freemium/Current Plan (maybe nothing or info toast)
              if (Get.isSnackbarOpen) Get.closeAllSnackbars();
              Get.snackbar(
                "Current Plan",
                "You are on the free plan.",
                colorText: Colors.white,
                backgroundColor: Colors.black54,
              );
            }
          },
          width: double.infinity,
          height: 56,
          borderRadius: 16,
          color: plan.color.withValues(alpha: 0.2),
          borderColor: plan.color.withValues(alpha: 0.5),
          child: Text(
            plan.buttonText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    });
  }
}

class PlanModel {
  final String title;
  final String basePrice;
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
