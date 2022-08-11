import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/components/reg_or_log_button.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  Animation? anim;
  Animation? color_anim;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller = AnimationController(
        vsync: this, duration: Duration(seconds: 2), lowerBound: 0.3);
    anim = CurvedAnimation(parent: controller, curve: Curves.easeInOutExpo);
    color_anim =
        ColorTween(begin: Colors.blue.shade700, end: Colors.lightBlue.shade200)
            .animate(controller);
    //controller.repeat(reverse: true); //yoyo animation effect

    controller.forward();

    controller.addListener(() {
      setState(() {});
      //print(anim?.value);
    });
  }

  Expanded FlashChat_anim() {
    const colorizeColors = [
      Colors.orangeAccent,
      Colors.redAccent,
      Colors.purpleAccent,
    ];

    const colorizeTextStyle = TextStyle(
      fontSize: 45.0,
      fontFamily: 'Lemonada',
    );

    return Expanded(
      child: SizedBox(
        width: 300.0,
        child: AnimatedTextKit(
          animatedTexts: [
            ColorizeAnimatedText(
              'Best',
              textStyle: colorizeTextStyle,
              colors: colorizeColors,
            ),
            ColorizeAnimatedText(
              'Fast',
              textStyle: colorizeTextStyle,
              colors: colorizeColors,
            ),
            ColorizeAnimatedText(
              'Flash Chat',
              textStyle: colorizeTextStyle,
              colors: colorizeColors,
            ),
          ],
          isRepeatingAnimation: true,
          onTap: () {
            print("Tap Event");
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color_anim?.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: anim?.value * 58,
                  ),
                ),
                /*GradientText('Flash Chat',
                    style: TextStyle(
                        fontSize: 45.0,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Lemonada'),
                    colors: [
                      Colors.orange.shade300,
                      Colors.redAccent,
                      Colors.purple.shade300,
                    ]),*/
                FlashChat_anim(),
              ],
            ),
            SizedBox(
              height: anim?.value * 48.0,
            ),
            RegOrLog(
              anim: anim,
              route_screen: LoginScreen(),
              route_name: 'Log In',
              btn_color: Colors.blue.shade500,
            ),
            RegOrLog(
              anim: anim,
              route_screen: RegistrationScreen(),
              route_name: 'Sign Up',
              btn_color: Colors.blueAccent.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
