import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pndtech_client/theme/theme.dart';
import 'splash_screen_2.dart';

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({Key? key}) : super(key: key);

  @override
  State<SplashScreen1> createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1> {
  int _currentIndex = 0;
  late Timer _timer;

  final List<String> _images = [
    'images/img1.png',
    'images/img1.jpg',
    'images/img2.png',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _images.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 2.3/ 3;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: Image.asset(
                  _images[_currentIndex],
                  fit: BoxFit.cover,
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Ñu Demm by PndTech\n100% Sénégalais',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subtitle
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 5,
            right: 10,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SplashScreen2()),
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
          ),
        ],
      ),
    );
  }
}
