import 'package:chat/app/modules/Home/views/home_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/registered_user_controller.dart';

class RegisteredUserView extends GetView<RegisteredUserController> {
  const RegisteredUserView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => RegisteredUserController());
    return Scaffold(
        appBar: AppBar(title: Text('User List'), actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                controller.logout();
              })
        ]),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final users = snapshot.data!.docs;
            final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
            print('Current User UID: $currentUserUid');

            // Filter out the current user from the list
            final otherUsers = users
                .where(
                  (user) => user['uid'] != currentUserUid,
                )
                .toList();

            return ListView.builder(
              itemCount: otherUsers.length,
              itemBuilder: (context, index) {
                final user = otherUsers[index];
                final username = user['username'] as String;
                final uid = user['uid'] as String;
                final fcm = user['fcmToken'] as String;
                print('User UID: $uid');
                print('User fcm: $fcm');

                return ListTile(
                  title: Text(username),
                  onTap: () {
                    Get.to(
                      HomeScreen(
                        recipientUid: uid,
                        recipientUsername: username,
                        recipientFCM: fcm,
                      ),
                    );
                  },
                );
              },
            );
          },
        ));
  }
}
