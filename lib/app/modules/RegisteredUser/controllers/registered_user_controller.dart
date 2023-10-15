import 'package:chat/app/modules/login/views/login_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class RegisteredUserController extends GetxController {
  //TODO: Implement RegisteredUserController

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // You can also navigate the user to a login screen or another appropriate screen after logging out.
      // For example:
      Get.offAll(LoginView());
    } catch (e) {
      // Handle any errors that occur during logout
      print('Error logging out: $e');
    }
  }

  void deleteMessages(String userUid) async {
    try {
      final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

      // Delete messages where senderUid is the current user and recipientUid is the selected user
      await FirebaseFirestore.instance
          .collection('messages')
          .where('senderUid', isEqualTo: currentUserUid)
          .where('recipientUid', isEqualTo: userUid)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      // Delete messages where senderUid is the selected user and recipientUid is the current user
      await FirebaseFirestore.instance
          .collection('messages')
          .where('senderUid', isEqualTo: userUid)
          .where('recipientUid', isEqualTo: currentUserUid)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      // You can also show a confirmation message here if needed
      print('Messages deleted successfully.');
    } catch (e) {
      // Handle any errors that occur during deletion
      print('Error deleting messages: $e');
    }
  }
}
