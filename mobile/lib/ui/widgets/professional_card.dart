import 'package:flutter/material.dart';

class ProfessionalCard extends StatelessWidget {
  final String name;
  final String profession;
  final String imageUrl;

  const ProfessionalCard({
    super.key,
    required this.name,
    required this.profession,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, // Ancho de cada tarjeta profesional
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          //foto de perfil
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey[800],
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(height: 8),
          // Nombre
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Profesion
          Text(
            profession,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
