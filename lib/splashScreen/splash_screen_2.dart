import 'package:flutter/material.dart';
import 'package:pndtech_client/authentification/connexion_page.dart';
import 'package:pndtech_client/pages/home_page.dart';
import 'package:pndtech_client/authentification//register_screen.dart';
import 'package:pndtech_client/theme/theme.dart';
import 'splash_screen1.dart';

class SplashScreen2 extends StatelessWidget {
  const SplashScreen2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Image bien proportionnée
          SizedBox(
            width: screenWidth,
            height: screenHeight * 0.6,
            child: Image.asset(
              'images/image1.png',
              fit: BoxFit.fill,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Commander votre moyen de transport selon votre besoin",
                  style: AppTextStyles.subtitle,
                ),
                SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    text: "Les chauffeurs de ",
                    style: AppTextStyles.subtitle,
                    children: [
                      TextSpan(
                        text: "PndTech",
                        style: AppTextStyles.title,
                      ),
                      TextSpan(
                        text:
                        " sont vos nouveaux amis au volant. Roulez en toute sécurité.",
                        style:AppTextStyles.subtitle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Boutons en bas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text(
                      "Précédent",
                    style: AppTextStyles.buttonText,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: AppColors.secondary
                  ),
                ),
                const SizedBox(width: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ConnexionPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.secondary,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Évite de trop étirer le bouton
                    children: const [
                      Text(
                        "Suivant",
                        style: AppTextStyles.buttonText,
                      ),
                      SizedBox(width: 2), // Espace entre le texte et l’icône
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),




              ],
            ),
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
