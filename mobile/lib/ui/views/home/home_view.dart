import 'package:flutter/material.dart';
import '../../widgets/professional_card.dart';
import '../../widgets/post_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // logo y boton de hamburguesa (enlace de páginas)
      appBar: AppBar(
        title: const Text(
          'Synapse',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: FlutterLogo(),
        ),
        actions: [IconButton(icon: const Icon(Icons.menu), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // -------- Sección horizontal de tarjetas profesionales ----------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Profesionales destacados",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 130, // Altura fija para la fila horizontal
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: const [
                  ProfessionalCard(
                    name: "Dr. Eloy Prado",
                    profession: "Psicopedagogo",
                    imageUrl: "https://picsum.photos/seed/eloy/200",
                  ),
                  ProfessionalCard(
                    name: "Dr. Joaquin Sobarzo",
                    profession: "Terapeuta Ocupacional",
                    imageUrl: "https://picsum.photos/seedjoaquin/200",
                  ),
                  ProfessionalCard(
                    name: "Dr. Alessandro Duarte",
                    profession: "Psicólogo",
                    imageUrl: "https://picsum.photos/seed/ale/200",
                  ),
                ],
              ),
            ),

            const Divider(), //separación
            // -------- publicaciones -------------
            const PostCard(
              userName: "Eloy Prado Mora",
              profession: "Psicólogo",
              userImageUrl: "https://picsum.photos/seed/eloy/200",
              postImageUrl: "https://picsum.photos/seed/post1/600/400",
              description:
                  "hola buenas esto es una prueba para ver como se visualiza el pie de foto de las publicaciones de synapseeeeeeeeeeeeeeeeeeeeeee",
            ),

            const PostCard(
              userName: "Alessandro Duarte",
              profession: "Psicoterapeuta",
              userImageUrl: "https://picsum.photos/seed/ale/200",
              postImageUrl: "https://picsum.photos/seed/post1/600/400",
              description:
                  "hola buenas esto es una prueba para ver como se visualiza el pie de foto de las publicaciones de synapseeeeeeeeeeeeeeeeeeeeeee",
            ),

            const PostCard(
              userName: "Martina Martínez",
              profession: "Psicóloga",
              userImageUrl: "https://picsum.photos/seed/martina/200",
              postImageUrl: "https://picsum.photos/seed/post1/600/400",
              description:
                  "hola buenas esto es una prueba para ver como se visualiza el pie de foto de las publicaciones de synapseeeeeeeeeeeeeeeeeeeeeee",
            ),
          ],
        ),
      ),
    );
  }
}
