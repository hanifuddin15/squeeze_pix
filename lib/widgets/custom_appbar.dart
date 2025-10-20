import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final RxList? images;
  final VoidCallback? onClearAll;
  final bool isLeadingIcon;

  const CustomAppBar({
    super.key,
    required this.title,
    this.images,
    this.onClearAll,
    this.isLeadingIcon = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        leading: isLeadingIcon
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: Colors.white,
                ),
                onPressed: Get.back,
              )
            : const SizedBox.shrink(),
        elevation: 0,
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // ✅ Only use Obx when images list is passed
          if (images != null)
            Obx(
              () => (images!.isNotEmpty)
                  ? IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                      tooltip: 'Clear All',
                      onPressed: onClearAll,
                    )
                  : const SizedBox.shrink(),
            ),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Colors.white,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              Get.changeThemeMode(
                Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
              );
            },
          ),
        ],
      ),
    );
  }
}
