import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                color: AppColors.bgMedium,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.all_inclusive, size: 100, color: AppColors.darkGray),
            ),
            const SizedBox(height: 80),
            // boton para ingresar a la aplicación
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGray,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pushNamed(context, '/login'), //redirección al preionarlo
                child: const Text("Ingresar", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}