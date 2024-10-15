import 'package:flutter/material.dart';
import 'package:plinko/src/utils/routes.dart';
import 'package:plinko/src/widgets/welcome_screen.dart';

void main() {
  runApp(const MaterialApp(
    home: WelcomeScreen(),
    onGenerateRoute: AppRoutes.onGenerateRoute,
  ));
}
