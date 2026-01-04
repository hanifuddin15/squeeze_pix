import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/iap_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/widgets/glassmorphic_button.dart';

class ProUpgradeScreen extends StatelessWidget {
  const ProUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final iapController = Get.find<IAPController>();

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
            const Text(
              "Choose Your Plan",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Unlock the full power of Squeeze Pix",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: PageView(
                controller: PageController(viewportFraction: 0.85),
                children: [
                  _buildPlanCard(
                    title: "Freemium",
                    price: "Free Forever",
                    features: [
                      "Basic Compression",
                      "Basic Editing",
                      "Contains Ads",
                      "No AI Tools",
                    ],
                    color: Colors.white.withValues(alpha: .1),
                    buttonText: "Current Plan",
                    onTap: () {},
                    isCurrent: true,
                  ),
                  _buildPlanCard(
                    title: "Gold",
                    price: "৳199 / Month",
                    features: [
                      "No Ads",
                      "Fast Batch Processing",
                      "Premium Editing Tools",
                      "No AI Tools",
                    ],
                    color: Colors.amber.withValues(alpha: .2),
                    borderColor: Colors.amber,
                    buttonText: "Upgrade to Gold",
                    onTap: () => iapController.buyPro(),
                  ),
                  _buildPlanCard(
                    title: "Platinum",
                    price: "৳299 / Month",
                    features: [
                      "All Gold Features",
                      "AI Tools Access",
                      "BG Remover",
                      "Priority Support",
                    ],
                    color: Colors.cyan.withValues(alpha: .2),
                    borderColor: Colors.cyanAccent,
                    buttonText: "Upgrade to Platinum",
                    onTap: () => iapController.buyUltra(),
                    isPopular: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required List<String> features,
    required Color color,
    required String buttonText,
    required VoidCallback onTap,
    Color? borderColor,
    bool isCurrent = false,
    bool isPopular = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: .2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "BEST VALUE",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: .9),
            ),
          ),
          const SizedBox(height: 24),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    feature.contains("No") ? Icons.close : Icons.check_circle,
                    color: feature.contains("No") ? Colors.redAccent : Colors.greenAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    feature,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (!isCurrent)
            GlassmorphicButton(
              onPressed: onTap,
              width: double.infinity,
              height: 50,
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (isCurrent)
             Center(
               child: Text(
                "Active Plan",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .5),
                  fontWeight: FontWeight.bold,
                ),
                           ),
             ),
        ],
      ),
    );
  }
}
