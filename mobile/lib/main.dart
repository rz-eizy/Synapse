import 'package:flutter/material.dart';
import 'ui/views/home/home_view.dart';
import 'ui/views/welcome/welcome_view.dart';

void main() {
  runApp(const AppoyoApp());
}

class AppoyoApp extends StatelessWidget {
  const AppoyoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Appoyo',

      initialRoute: '/',

      routes: {
        '/': (context) => const WelcomeView(),
        '/home': (context) => const HomeView(),
      },
    );
  }
}
