import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompressorController>(() => CompressorController());
  }
}
