import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../RegisteredUser/views/registered_user_view.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    //user.bindStream(_auth.authStateChanges());
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Use Google email as UID
      final String? googleEmail = userCredential.user!.email;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(googleEmail)
          .set({
        'uid': userCredential.user?.uid,
        'username':
            googleEmail, // You can use the email as the default username
      });

      isLoading.value = false;
      Get.off(RegisteredUserView());
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Google Sign-In Error',
        'Failed to sign in with Google: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<User?> signUp(String email, String password, String username) async {
    try {
      isLoading.value = true;
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Use Google email as UID
      final String? googleEmail = userCredential.user!.email;
      final String? fcmToken = await FirebaseMessaging.instance.getToken();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(googleEmail)
          .set({
        'uid': userCredential.user?.uid,
        'username': username,
        'fcmToken': fcmToken,
      });

      isLoading.value = false;
      Get.off(RegisteredUserView());
      return userCredential.user;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Registration Error',
        'Failed to register: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      isLoading.value = false;

      // Get the user's UID
      final String uid = userCredential.user!.uid;

      Get.off(RegisteredUserView());
      return userCredential.user;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Login Error',
        'Failed to log in: $e',
        snackPosition: SnackPosition.BOTTOM,
      );

      return null;
    }
  }
}
