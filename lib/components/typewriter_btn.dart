import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/constants.dart';

class TypeWriter_button extends StatelessWidget {
  final String btn_name;
  TypeWriter_button({required this.btn_name});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.0,
      child: DefaultTextStyle(
        style: hint_style.copyWith(fontSize: 21),
        child: Center(
          child: AnimatedTextKit(
            pause: const Duration(seconds: 3),
            animatedTexts: [
              TypewriterAnimatedText(btn_name),
            ],
          ),
        ),
      ),
    );
  }
}
