import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class RegistrationScreen extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: controller.usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              SizedBox(height: 20),
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
                    : ElevatedButton(
                        onPressed: () {
                          final email = controller.emailController.text.trim();
                          final password =
                              controller.passwordController.text.trim();
                          final username =
                              controller.usernameController.text.trim();
                          if (email.isNotEmpty &&
                              password.isNotEmpty &&
                              username.isNotEmpty) {
                            controller.signUp(email, password, username);
                          } else {
                            Get.snackbar(
                              'Validation Error',
                              'Please fill in all fields.',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                        child: Text('Register'),
                      );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
