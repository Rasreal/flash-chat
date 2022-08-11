import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/components/typewriter_btn.dart';
import 'package:flash_chat/components/firebase.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flash_chat/components/globals.dart' as globals;

class Profile extends StatefulWidget {
  static final String id = 'profile';

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final _auth = FirebaseAuth.instance;
  Animation? anim;
  Animation? anim2;
  Animation? color_anim;
  String user_name = '';
  String user_surname = '';
  bool showSpinner = false;

  var image_path = null;
  var fileName = null;

  final FirebaseFirestore fb_store = FirebaseFirestore.instance;

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      logged_user = user!;
      print(logged_user?.email);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    controller = AnimationController(
        vsync: this, duration: Duration(seconds: 2), lowerBound: 0.1);

    anim = CurvedAnimation(parent: controller, curve: Curves.easeInOutExpo);
    anim2 = CurvedAnimation(parent: controller, curve: Curves.easeInExpo);
    color_anim =
        ColorTween(begin: Colors.lightBlue.shade100, end: Colors.red.shade200)
            .animate(controller);
    //controller.repeat(reverse: true); //yoyo animation effect

    controller.forward();

    controller.addListener(() {
      setState(() {});
      //print(anim?.value);
    });
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void succes_anim() {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.success,
      text: "Your data was successfully saved",
    );
  }

  void alert(String title1, String desc1, AlertType type1) {
    Alert(
      context: context,
      type: type1,
      title: title1,
      desc: desc1,
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  InputDecoration decor_btn(String enter_what) {
    return InputDecoration(
      hintText: enter_what,
      hintStyle: hint_style,
      contentPadding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(32.0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.lightBlue.shade600, width: 1.65),
        borderRadius: BorderRadius.all(Radius.circular(32.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.65),
        borderRadius: BorderRadius.all(Radius.circular(32.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color_anim?.value,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Profile'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.redAccent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder(
                      future: globals.url_image,
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return CircleAvatar(
                              radius: 40,
                              child: Image.network(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              ));
                        } else if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            !snapshot.hasData) {
                          return CircularProgressIndicator();
                        } else {
                          return CircleAvatar(
                              child: FaIcon(FontAwesomeIcons.redditAlien));
                        }
                      }),
                  Text(
                    'My profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    user_name != '' ? user_name : 'My name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Messages'),
            ),
            GestureDetector(
              onTap: () {
                Firebase_all().signOut();
                Navigator.pushNamed(context, WelcomeScreen.id);
              },
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Exit'),
              ),
            ),
          ],
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontFamily: 'Gulzar',
                      fontSize: 35.0,
                      color: Colors.lightBlue.shade800,
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        WavyAnimatedText('Hello ${logged_user?.email}'),
                        WavyAnimatedText('Tap Avatar to change it'),
                      ],
                      isRepeatingAnimation: false,
                      onTap: () {
                        print("Tap Event");
                      },
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final image_ = await FilePicker.platform.pickFiles(
                        allowMultiple: false,
                        type: FileType.custom,
                        allowedExtensions: ['png', 'jpg', 'jpeg', 'gif']);
                    if (image_ == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Np image uploaded'),
                        ),
                      );
                      return null;
                    }
                    setState(() {
                      image_path = image_.files.single.path!;
                    });
                    fileName = image_.files.single.name;

                    print(image_path);
                    print(fileName);
                  },
                  child: CircleAvatar(
                      radius: anim2?.value * 50,
                      backgroundColor:
                          image_path == null ? Colors.blue : Colors.white60,
                      child: image_path == null
                          ? FaIcon(
                              FontAwesomeIcons.redditAlien,
                              size: 50,
                            )
                          : FaIcon(
                              FontAwesomeIcons.check,
                              color: Colors.lightGreenAccent,
                              size: 60,
                            )),
                ),
                SizedBox(
                  height: anim?.value * 50,
                ),
                TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    user_name = value;
                  },
                  decoration: decor_btn(
                      user_name != '' ? user_name : 'Enter your Name'),
                ),
                SizedBox(
                  height: anim?.value * 20,
                ),
                TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    user_surname = value;
                  },
                  decoration: decor_btn(
                      user_surname != '' ? user_surname : 'Enter your Surname'),
                ),
                SizedBox(
                  height: anim?.value * 10,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Material(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    elevation: 8.0,
                    child: MaterialButton(
                      onPressed: () async {
                        setState(() {
                          showSpinner = true;
                        });
                        if (user_name == '' || user_surname == '') {
                          showSpinner = false;
                          alert('Missing Data', 'Fill all textfields',
                              AlertType.warning);
                        } else if (user_surname.length < 2 ||
                            user_name.length < 2) {
                          showSpinner = false;
                          alert(
                              'Wrong format',
                              'Wrong Sur/Name format, it should be at least 2 characters',
                              AlertType.warning);
                        } else {
                          try {
                            Firebase_all().createUser(user_name, user_surname);
                            if (fileName != null && image_path != null) {
                              Firebase_all()
                                  .uploadFile(image_path, fileName)
                                  .then((value) => print('File is uploaded'));

                              globals.url_image =
                                  Firebase_all().downloadUrl(fileName);
                            }

                            print('Saved');
                            succes_anim();

                            setState(() {
                              showSpinner = false;
                            });
                          } catch (e) {
                            alert('Wrong input', 'Couldn\'t create a new user',
                                AlertType.error);

                            print(e);
                          }
                        }
                      },
                      minWidth: 150.0,
                      height: 42.0,
                      child: TypeWriter_button(btn_name: 'Save'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
