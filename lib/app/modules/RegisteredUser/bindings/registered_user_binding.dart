import 'package:get/get.dart';

import '../controllers/registered_user_controller.dart';

class RegisteredUserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisteredUserController>(
      () => RegisteredUserController(),
    );
  }
}
