import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'app/modules/Home/bindings/home_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/services/storage.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initGetServices();
  final fcmToken = await FirebaseMessaging.instance.getToken();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  _firebaseMessaging.subscribeToTopic('chat'); // Subscribe to a topic if needed

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle foreground messages here
    // You can display a notification or update your UI
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // Handle when the app is opened from a notification
    // You can navigate to a specific screen or handle the action
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  log("FCMToken $fcmToken");
  print("FCMToken $fcmToken");
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );

  return runApp(GestureDetector(
    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
    child: GetMaterialApp(
      // theme: AppTheme.light,
      // darkTheme: AppTheme.dark,
      defaultTransition: Transition.fade,
      smartManagement: SmartManagement.full,
      debugShowCheckedModeBanner: false,
      locale: const Locale('en', 'US'),
      initialRoute: AppPages.determineInitialRoute(),
      initialBinding: HomeBinding(),
      getPages: AppPages.routes,
    ),
  ));
}

Future<void> initGetServices() async {
  await Get.putAsync<GetStorageService>(() => GetStorageService().initState());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle the message here and show a notification

  showNotification(message.data);
}

void _handleMessage(RemoteMessage message) {
  // Handle the message here and show a notification if needed
  showNotification(message.data);
}

// Show a notification using FlutterLocalNotificationsPlugin
void showNotification(Map<String, dynamic> data) async {
  // Use a notification plugin like flutter_local_notifications to display a notification
  // Example usage: https://pub.dev/packages/flutter_local_notifications#example
}
