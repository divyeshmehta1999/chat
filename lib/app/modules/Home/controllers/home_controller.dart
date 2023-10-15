import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  final recipientUid = ''.obs;
  final recipientUsername = ''.obs;

  RxList<QueryDocumentSnapshot<Map<String, dynamic>>> messages =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize recipientUid and recipientUsername
    recipientUid.value = Get.arguments['recipientUid'];
    recipientUsername.value = Get.arguments['recipientUsername'];

    // Listen to changes in messages collection
    getMessages().listen((snapshot) {
      messages.value = snapshot.docs;
    });
  }

  @override
  void onClose() {
    super.onClose();
    messageController.dispose();
    scrollController.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages() {
    return FirebaseFirestore.instance
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .where('senderUid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('recipientUid', isEqualTo: recipientUid.value)
        .snapshots();
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
