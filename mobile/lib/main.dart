import 'package:flutter/material.dart';
import 'package:mobile/ui/views/register/register_view.dart';
import 'ui/views/welcome/welcome_view.dart';
import 'ui/views/login/login_view.dart';
import 'ui/views/home/home_view.dart';

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
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/home': (context) => const HomeView(),
      },
    );
  }
}
