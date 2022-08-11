import 'package:flash_chat/components/firebase.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/screens/profile.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat/components/firebase.dart';

final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
User? logged_user;

class ChatScreen extends StatefulWidget {
  static String id = 'chat';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final msgController = TextEditingController();
  String user_name = '';
  String user_surname = '';
  String msg = '';
  void getCurrentUser() {
    setState(() {
      try {
        final user = _auth.currentUser;
        logged_user = user!;
        print(logged_user?.email!);
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    getuserData();
  }

  Future<void> getuserData() async {
    final name1 = await FirebaseFirestore.instance
        .collection('users')
        .doc(user_uid)
        .get()
        .then((value) {
      return value.data()!['Name']; // Access your after your get the data
    });
    final surname1 = await FirebaseFirestore.instance
        .collection('users')
        .doc(user_uid)
        .get()
        .then((value) {
      return value.data()!['Surname']; // Access your after your get the data
    });
    user_name = await name1;
    user_surname = await surname1;
  }

  void messageStream() async {
    await for (var snapshot in _fireStore.collection('messages').snapshots()) {
      for (var messages in snapshot.docs) {
        print(messages.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                messageStream();
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text(
          '⚡️Chat',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      drawer: Drawer(
        child: GestureDetector(
          onTap: () {
            setState(() {
              user_name;
            });
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.man),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      user_name != '' ? user_name : 'Hey',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, Profile.id);
                },
                child: ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Profile'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, LoginScreen.id);
                },
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: msgController,
                      onChanged: (value) {
                        msg = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      msgController.clear();
                      _fireStore.collection('messages').add({
                        'Text': msg,
                        'Sender': logged_user?.email,
                        'Time': Timestamp.now(),
                      });
                      messageStream();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore
            .collection('messages')
            .orderBy('Time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.grey,
            ));
          }
          List<MessageBubble> messageBubbles = [];
          final QuerySnapshot messages = snapshot.data!;
          for (var doc in snapshot.data!.docs) {
            final currentUser = logged_user?.email;

            messageBubbles.add(MessageBubble(
              doc: doc,
              isMe: doc['Sender'] == currentUser,
              time: doc['Time'],
            ));
          }
          return Expanded(
            child: ListView(
                reverse: true,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                children: messageBubbles),
          );
        });
  }
}

class MessageBubble extends StatelessWidget {
  // final String text;
  // final String sender;
  final dynamic doc;
  final bool isMe;
  final Timestamp time;
  MessageBubble({required this.doc, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '${doc['Sender']}',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(
            height: 3,
          ),
          Material(
            elevation: 5.0,
            shape: isMe
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0)))
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                        topRight: Radius.circular(20.0))),
            color: isMe ? Colors.blueAccent : Colors.pinkAccent,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
              child: Text(
                "${doc['Text']}",
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
