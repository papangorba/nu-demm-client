import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pndtech_client/splashScreen/splash_screen_2.dart';
import 'package:pndtech_client/theme/theme.dart';
import 'otp_verification_page.dart';

class ConnexionPage extends StatefulWidget {
const ConnexionPage({super.key});

@override
State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
final TextEditingController phoneController = TextEditingController();
bool termsAccepted = false;

@override
void dispose() {
phoneController.dispose();
super.dispose();
}

void showOtpChoiceDialog(String phoneNumber) {
showDialog(
context: context,
builder: (context) => AlertDialog(
title: const Text("Choisir la méthode de réception",
  style: TextStyle(color: AppColors.primary,fontSize: 23,fontWeight: FontWeight.bold),
),
content: const Text("Comment souhaitez-vous recevoir le code OTP ?",
  style: TextStyle(color: AppColors.secondary,fontSize: 18,)

),
actions: [
TextButton(
onPressed: () {
Navigator.pop(context);
goToOtpPage(phoneNumber, "SMS");
},
child: const Text("Par SMS"),
),
TextButton(
onPressed: () {
Navigator.pop(context);
goToOtpPage(phoneNumber, "WhatsApp");
},
child: const Text("Par WhatsApp"),
),
],
),
);
}

Future<void> goToOtpPage(String phoneNumber, String method) async {
  await FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    timeout: const Duration(seconds: 60),
    verificationCompleted: (PhoneAuthCredential credential) async {
      // Optionnel : connexion automatique
    },
    verificationFailed: (FirebaseAuthException e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de vérification : ${e.message}")),
      );
    },
    codeSent: (String verificationId, int? resendToken) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(
            phoneNumber: phoneNumber,
            verificationId: verificationId, // ✅ réel
            receptionMethod: method, // SMS ou WhatsApp
          ),
        ),
      );
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      // Optionnel : gérer expiration
    },
  );

}

void validatePhoneNumber() {
String phone = phoneController.text.trim();
if (!phone.startsWith('+')) {
phone = '+221$phone';
}

if (phone.length < 12 || !RegExp(r'^\+221\d{9}$').hasMatch(phone)) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text("Numéro invalide. Format attendu : 77XXXXXXX")),
);
} else if (!termsAccepted) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text("Veuillez accepter les conditions d'utilisation.")),
);
} else {
showOtpChoiceDialog(phone);
}
}


@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.background,
appBar: AppBar(
title: const Text("Ñu Demm - Connexion",
  style: TextStyle(color: AppColors.white),
),
backgroundColor: AppColors.primary,
  automaticallyImplyLeading: false,
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
child: Image.asset(AppAssets.logo),
),
const Text(
"Bienvenue ",
style:TextStyle(color:AppColors.primary,fontSize: 64, fontWeight: FontWeight.bold) ,
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
controller: phoneController,
keyboardType: TextInputType.phone,
style: AppTextStyles.inputText,

decoration: InputDecoration(
labelText: "Numéro de téléphone",
hintText: "Ex: 7*********",
  hintStyle: TextStyle(
    color: AppColors.secondary,
    fontSize: 16,
  ),
border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
filled: true,
fillColor: Colors.grey[100],
labelStyle: AppTextStyles.formLabel,
prefixText: "+221 ",
prefixStyle: AppTextStyles.inputText,
),
),
const SizedBox(height: 20),
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
showDialog(
context: context,
builder: (context) => AlertDialog(
title: const Text("Conditions d'utilisation"),
content: const Text("Conditions à afficher ici..."),
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
width: double.infinity,
child: ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.primary,
),
  onPressed: () {
    FocusScope.of(context).unfocus();
    validatePhoneNumber();
  },
child: const Text(
"Recevoir le code",
style: TextStyle(color: AppColors.white,fontSize: 22,fontWeight: FontWeight.bold),
),
),
),
const SizedBox(height: 30),
const Text(
"100% Sénégalais - Ñu Demm by PndTech",
style: TextStyle(color: AppColors.primary),
),
const SizedBox(height: 20),
],
),
),
),
);
}
}
