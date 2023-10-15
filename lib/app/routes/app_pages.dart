import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../modules/Home/bindings/home_binding.dart';
import '../modules/Home/views/home_view.dart';
import '../modules/RegisteredUser/bindings/registered_user_binding.dart';
import '../modules/RegisteredUser/views/registered_user_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;
  static String determineInitialRoute() {
    final User? user = FirebaseAuth.instance.currentUser;
    return user != null ? _Paths.REGISTERED_USER : _Paths.LOGIN;
  }

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeScreen(
        recipientUid: '',
        recipientUsername: '',
      ),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTERED_USER,
      page: () => RegisteredUserView(),
      binding: RegisteredUserBinding(),
    ),
  ];
}
