import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PostCard extends StatelessWidget {
  final String userName;
  final String profession;
  final String userImageUrl;
  final String postImageUrl;
  final String description;

  const PostCard({
    super.key,
    required this.userName,
    required this.profession,
    required this.userImageUrl,
    required this.postImageUrl,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -------------- encabezado de la publicacion ----------
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(userImageUrl),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    profession,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ----------- imagen publicación -----------
        Image.network(postImageUrl, width: double.infinity, height: 520, fit: BoxFit.cover),

        // ------------ botones de redirección ---------
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {},
            ),
          ],
        ),

        // ----------- pie de foto -------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white, fontSize: 14),
              children: [
                TextSpan(
                  text: '$userName ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: description),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20), // espacio entre publicaciones
      ],
    );
  }
}
