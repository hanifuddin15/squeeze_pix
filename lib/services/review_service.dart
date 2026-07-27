import 'package:in_app_review/in_app_review.dart';
import 'package:get_storage/get_storage.dart';

class ReviewService {
  static final InAppReview _inAppReview = InAppReview.instance;
  static final GetStorage _box = GetStorage();

  static const String _compressionCountKey = 'successful_compressions_count';
  static const String _hasReviewedKey = 'has_prompted_review';

  /// Call this whenever a successful compression finishes.
  /// Prompts in-app rating after 3 successful compressions.
  static Future<void> checkAndPromptReview() async {
    bool hasPrompted = _box.read<bool>(_hasReviewedKey) ?? false;
    if (hasPrompted) return;

    int currentCount = (_box.read<int>(_compressionCountKey) ?? 0) + 1;
    await _box.write(_compressionCountKey, currentCount);

    if (currentCount >= 3) {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        await _box.write(_hasReviewedKey, true);
      }
    }
  }

  /// Open app store page directly (useful in Settings / About)
  static Future<void> openStoreListing() async {
    await _inAppReview.openStoreListing(
      appStoreId: 'com.hanif.squeezepix',
    );
  }
}
