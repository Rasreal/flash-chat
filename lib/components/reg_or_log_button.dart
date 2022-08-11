import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

class RegOrLog extends StatelessWidget {
  RegOrLog(
      {required this.anim,
      required this.route_screen,
      required this.route_name,
      required this.btn_color});
  final Widget route_screen;
  final String route_name;
  final Color btn_color;
  final Animation? anim;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: anim?.value * 16),
      child: Material(
        color: btn_color,
        borderRadius: BorderRadius.circular(30),
        elevation: 5.0,
        child: MaterialButton(
          onPressed: () {
            Navigator.push(
                context,
                route_name == 'Sign Up'
                    ? CustomPageBottom(widget: route_screen)
                    : CustomPageTop(widget: route_screen));

            //Go to registration screen.
          },
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            route_name,
            style: tStyle,
          ),
        ),
      ),
    );
  }
}

class CustomPageBottom<T> extends PageRouteBuilder<T> {
  final Widget widget;

  CustomPageBottom({
    required this.widget,
  })  : assert(widget != null),
        super(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return widget;
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            final Widget transition;

            transition = SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(animation),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: Offset(0.0, -0.7),
                ).animate(secondaryAnimation),
                child: child,
              ),
            );

            return transition;
          },
        );
}

class CustomPageTop<T> extends PageRouteBuilder<T> {
  final Widget widget;

  CustomPageTop({
    required this.widget,
  })  : assert(widget != null),
        super(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return widget;
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            final Widget transition;

            transition = SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0.0, -1.0),
                end: Offset.zero,
              ).animate(animation),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: Offset(0.0, 0.7),
                ).animate(secondaryAnimation),
                child: child,
              ),
            );

            return transition;
          },
        );
}
