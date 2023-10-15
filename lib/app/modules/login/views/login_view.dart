import 'package:chat/app/modules/login/views/register.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  final RxBool isRegistering = false.obs;

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => LoginController());
    return Scaffold(
      appBar: AppBar(
        title: Text(isRegistering.value ? 'Register' : 'Login'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: controller.emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: controller.passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              Obx(() {
                return controller.isLoading.value
                    ? CircularProgressIndicator()
                    : Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              final email =
                                  controller.emailController.text.trim();
                              final password =
                                  controller.passwordController.text.trim();
                              if (email.isNotEmpty && password.isNotEmpty) {
                                if (isRegistering.value) {
                                  controller.signUp(
                                      email, password, AutofillHints.username);
                                } else {
                                  controller.signIn(email, password);
                                }
                              } else {
                                Get.snackbar(
                                  'Validation Error',
                                  'Please fill in both email and password.',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                            child: Text('Login'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Toggle between login and registration modes
                              Get.to(RegistrationScreen());
                            },
                            child: Text(isRegistering.value
                                ? 'Already have an account? Log In'
                                : 'Don\'t have an account? Register'),
                          ),
                          SizedBox(height: 20), // Add spacing
                          // Google Sign-In Button
                          // ElevatedButton.icon(
                          //   onPressed: () {
                          //     // Call Google Sign-In method from the controller
                          //     controller.signInWithGoogle();
                          //   },
                          //   icon: Icon(Icons.g_mobiledata_outlined),
                          //   label: Text('Sign In with Google'),
                          // ),
                        ],
                      );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
