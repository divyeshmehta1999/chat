import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final String recipientUid;
  final String recipientUsername;
  final String? recipientFCM;
  final String? senderUsername;

  HomeScreen({
    required this.recipientUid,
    required this.recipientUsername,
    this.recipientFCM,
    this.senderUsername,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String serverKey =
      'AAAAS1bOKtE:APA91bFQhg7Emm524mx9-a_O8NgeIWpBEDrST2JWbSM3Nbbufa2AGpg8GOlf26lW9__z_btb4Dmqy_-pS0o0sccCA5c5CIW3iGgxCCZmnxNpU9qw-UbKI6czbyPdDGrSeeXrvJ5_WZVA';
  bool isSending = false; // Track whether a message is being sent
  //final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientUsername),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<QueryDocumentSnapshot>>(
              stream: mergeStreams([
                FirebaseFirestore.instance
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .where('senderUid',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .where('recipientUid', isEqualTo: widget.recipientUid)
                    .snapshots(),
                FirebaseFirestore.instance
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .where('senderUid', isEqualTo: widget.recipientUid)
                    .where('recipientUid',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
              ]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  reverse:
                      true, // Reverse the list to show new messages at the bottom
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final messageText = message['text'];
                    final messageSenderUid = message['senderUid'];
                    final isMe = messageSenderUid ==
                        FirebaseAuth.instance.currentUser!.uid;

                    return MessageWidget(
                      text: messageText,
                      isMe: isMe,
                      isSending: false, // Pass false for existing messages
                    );
                  },
                );
              },
            ),
          ), // Show the loading indicator when isSending is true

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration:
                        InputDecoration(labelText: 'Enter a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final messageText = messageController.text.trim();
                    sendNotification(messageText, widget.recipientUid);

                    if (messageText.isNotEmpty) {
                      sendMessage(messageText, widget.recipientUid);
                      messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sendMessage(String messageText, String recipientUid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('messages').add({
          'text': messageText,
          'senderUid': user.uid,
          'recipientUid': recipientUid,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Send a notification to the recipient
        await sendNotification(messageText, user.uid);
      } catch (e) {
        print('erorrrrrrrrrr $e');
      }
    }
  }

  Future<void> _getAndPrintFCMToken() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken != null) {
      print('FCM Token: $fcmToken');
    } else {
      print('Unable to retrieve FCM Token');
    }
  }

  Future<void> sendNotification(String messageText, String recipientUid) async {
    final message = {
      'notification': {
        'title': 'You have received A New Message',
        'body': messageText,
      },
      'data': {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'screen': '/home',
      },
      'to': widget.recipientFCM,
    };

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
      print('message data ${widget.recipientFCM}');
    } else {
      print('Failed to send notification: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    _getAndPrintFCMToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle the message when the app is in the foreground
      print("onMessage: $message");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle the message when the user taps the notification to open the app
      print("onMessageOpenedApp: $message");
      openChatScreen(message);
    });
  }

  void openChatScreen(RemoteMessage message) {
    final data = message.data; // Extract data from the message
    final recipientUid = data['recipientUid'];
    final recipientUsername = data['recipientUsername'];

    // Now you can open the chat screen with the extracted data
    Get.to(HomeScreen(
      recipientUid: recipientUid,
      recipientUsername: recipientUsername,
      recipientFCM: widget.recipientFCM,
    ));
  }

  Stream<List<QueryDocumentSnapshot>> mergeStreams(
      List<Stream<QuerySnapshot>> streams) {
    final controller = StreamController<List<QueryDocumentSnapshot>>();
    List<List<QueryDocumentSnapshot>> snapshots =
        List.filled(streams.length, []);

    for (int i = 0; i < streams.length; i++) {
      streams[i].listen((data) {
        snapshots[i] = data.docs;
        final mergedSnapshots = snapshots.expand((element) => element).toList();
        mergedSnapshots.sort((a, b) => (b['timestamp']?.toDate() ?? DateTime(0))
            .compareTo(a['timestamp']?.toDate() ?? DateTime(0)));

        controller.add(mergedSnapshots);
      });
    }
    return controller.stream;
  }
}

class MessageWidget extends StatelessWidget {
  final String text;
  final bool isMe;
  final bool isSending;

  MessageWidget({
    required this.text,
    required this.isMe,
    required this.isSending,
  });

  @override
  Widget build(BuildContext context) {
    var alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    var backgroundColor = isMe ? Colors.blue : Colors.green;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            children: [
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: backgroundColor,
                ),
                child: Text(text, style: TextStyle(color: Colors.white)),
              ),
              if (isSending)
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: isMe ? 8 : null,
                  left: !isMe ? 8 : null,
                  child: Icon(
                    Icons.access_time, // You can use a clock icon here
                    color: Colors.grey,
                    size: 16,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
