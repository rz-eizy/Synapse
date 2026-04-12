import 'package:flutter/material.dart';
import 'ui/views/home/home_view.dart';
import 'core/theme/app_colors.dart';

void main() {
  runApp(const SynapseApp());
}

class SynapseApp extends StatelessWidget {
  const SynapseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Synapse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.appBarColor,
          elevation: 0,
        ),
      ),
      home: const HomeView(),
    );
  }
}
