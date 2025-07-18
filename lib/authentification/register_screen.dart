import 'package:flutter/material.dart';
import 'package:pndtech_client/mainScreen/main_screen.dart';
import 'package:pndtech_client/splashScreen/splash_screen_2.dart';
import 'package:pndtech_client/theme/theme.dart';
import 'package:pndtech_client/global/global.dart';
import 'otp_verification_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';



class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController prenomTextEditingController = TextEditingController();
  final TextEditingController nomTextEditingController = TextEditingController();
  bool termsAccepted = false;

  void showSaveConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer"),
        content: const Text("Voulez-vous enregistrer ces informations maintenant ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Fermer et revenir
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fermer le dialog
              saveClientInfo();       // Sauvegarder les infos
            },
            child: const Text("Oui, enregistrer"),
          ),
        ],
      ),
    );
  }


  Future<void> saveClientInfo() async {
    // Vérifie tous les champs + conditions
    if (prenomTextEditingController.text.trim().isEmpty ||
        nomTextEditingController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    if (!termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez accepter les conditions d'utilisation.")),
      );
      return;
    }

    String phone = phoneController.text.trim();
    if (!phone.startsWith('+')) {
      phone = '+221$phone'; // Adapter au besoin
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Utilisateur non connecté.")),
      );
      return;
    }

    DatabaseReference clientRef = FirebaseDatabase.instance.ref()
        .child("clients")
        .child(user.uid); // ✅ Utilise user.uid directement

    try {
      await clientRef.set({
        "prenom": prenomTextEditingController.text.trim(),
        "nom": nomTextEditingController.text.trim(),
        "phone": phone,
        "infosCompletes": true,
        "dateInscription": DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Informations enregistrées avec succès.")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'enregistrement.")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Ñu Demm-Inscription"),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Image.asset(AppAssets.logo)
              ),
              const SizedBox(height: 4),
              const Text(
                "Bienvenue sur\n Ñu-Demm by PndTech",
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Veuillez entrer votre numéro de téléphone",
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: prenomTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: false,
                style: AppTextStyles.inputText,
                decoration: InputDecoration(
                  labelText: "Prenom",
                  hintText: "Ex:Papa ngorba",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: AppTextStyles.hint,
                  labelStyle: AppTextStyles.formLabel,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nomTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: false,
                style: AppTextStyles.inputText,
                decoration: InputDecoration(
                  labelText: "Nom",
                  hintText: "Ex:dia",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: AppTextStyles.hint,
                  labelStyle: AppTextStyles.formLabel,
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                obscureText: false,
                style: AppTextStyles.inputText,
                decoration: InputDecoration(
                  labelText: "Numero de telephone",
                  hintText: "Ex:772995725",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: AppTextStyles.hint,
                  labelStyle: AppTextStyles.formLabel,
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Checkbox(
                    value: termsAccepted,
                    onChanged: (value) {
                      setState(() {
                        termsAccepted = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Tu peux ouvrir une page ici pour afficher les conditions
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Conditions d'utilisation"),
                            content: const Text(
                              "Conditions à afficher ici...",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Fermer"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text.rich(
                        TextSpan(
                          text: "J'accepte les ",
                          style: AppTextStyles.subtitle,
                          children: [
                            TextSpan(
                              text: "conditions d'utilisation",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                //width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,

                  ),
                  onPressed: saveClientInfo,
                  child: const Text(
                    "S'inscrire",
                    style: AppTextStyles.buttonText,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "100% Sénégalais - Ñu Demm by PndTech",
                style: TextStyle(color:AppColors.primary),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
