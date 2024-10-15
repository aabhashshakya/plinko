

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plinko/src/game_app.dart';
import 'package:plinko/src/widgets/welcome_screen.dart';

class AppRoutes {
  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case WelcomeScreen.routeName:
        return WelcomeScreen.getRoute(settings);
      case GameApp.routeName:
        return GameApp.getRoute(settings);

      default:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(
                  body: Center(
                    child: Text(
                      'Error. Destination not found.',
                      style: TextStyle(fontSize: 40),
                    ),
                  ),
                ));
    }
  }
}
