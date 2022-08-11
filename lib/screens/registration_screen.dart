// ignore_for_file: non_constant_identifier_names
import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:flash_chat/components/typewriter_btn.dart';
import 'package:flash_chat/components/firebase.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final _auth = FirebaseAuth.instance;
  Animation? anim;
  Animation? anim2;
  Animation? color_anim;
  String email = '';
  String password = '';
  bool showSpinner = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller = AnimationController(
        vsync: this, duration: Duration(seconds: 2), lowerBound: 0.1);

    anim = CurvedAnimation(parent: controller, curve: Curves.easeInOutExpo);
    anim2 = CurvedAnimation(parent: controller, curve: Curves.easeInExpo);
    color_anim = ColorTween(
            begin: Colors.lightBlue.shade100, end: Colors.purple.shade200)
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

  bool isValidEmail(String email) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  void checklog(String title1, String desc1, AlertType type1) {
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
      contentPadding:
          EdgeInsets.symmetric(vertical: anim2?.value * 3.0, horizontal: 10),
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
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: anim2?.value * 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onTap: () {
                  setState(() {});
                },
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
                decoration: decor_btn('Enter your email'),
              ),
              SizedBox(
                height: anim?.value * 10.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
                decoration: decor_btn('Enter your password'),
              ),
              SizedBox(
                height: anim2?.value * 24.0,
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
                      if (email == '' || password == '') {
                        showSpinner = false;
                        checklog('Missing Data', 'Fill all textfields',
                            AlertType.warning);
                      } else if (password.length < 6) {
                        showSpinner = false;
                        checklog(
                            'Wrong format',
                            'Wrong password format, it should be at least 6 character',
                            AlertType.warning);
                      } else if (isValidEmail(email) == false) {
                        showSpinner = false;
                        checklog(
                            'Wrong format',
                            'Wrong email format, it should include @ . com and etc',
                            AlertType.warning);
                      } else {
                        try {
                          // final newUser =
                          //     await _auth.createUserWithEmailAndPassword(
                          //         email: email, password: password);
                          Firebase_all().registerUser(email, password);

                          Navigator.pushNamed(context, ChatScreen.id);

                          setState(() {
                            showSpinner = false;
                          });
                        } catch (e) {
                          checklog('Wrong input', 'Couldn\'t create a new user',
                              AlertType.error);

                          print(e);
                        }
                      }
                    },
                    minWidth: 150.0,
                    height: 42.0,
                    child: TypeWriter_button(
                      btn_name: 'Register',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum Gender { male, female }
