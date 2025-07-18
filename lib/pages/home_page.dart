import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../mainScreen/main_screen.dart';
import '../theme/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? currentPosition;
  String? userFullName;
  String? userPhoneNumber;
  String? userAddress;

  final List<Map<String, dynamic>> services = [
    {'title': 'Cargo', 'image': 'images/CARGO-03-03.png'},
    {'title': 'Courses', 'image': 'images/V02-02.png'},
    {'title': 'Livraison', 'image': 'images/liv-04.png'},
    {'title': 'Repas', 'image': 'images/repass-05.png'},
    {'title': 'Navigation', 'image': 'images/localisation-06.png'},
  ];
  final List<Map<String, dynamic>> servicesinterurbain = [
    {'title': 'Bus', 'image': 'images/bus.png'},
    {'title': 'Allo Dakar', 'image': 'images/allodakar.png'},
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadUserMenuInfos();
  }


  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks.first;

    setState(() {
      currentPosition = position;
      userAddress = "${place.street}, ${place.locality}";
    });
  }

  void _loadUserMenuInfos() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final phone = user.phoneNumber ?? 'Numéro inconnu';

      final userRef = FirebaseDatabase.instance.ref().child('clients').child(user.uid);
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final nom = snapshot.child('nom').value?.toString() ?? '';
        final prenom = snapshot.child('prenom').value?.toString() ?? '';

        setState(() {
          userFullName = '$prenom $nom';
          userPhoneNumber = phone;
        });
      }
    }
  }

  void _navigateToMain(String selectedService) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MainScreen(
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
    backgroundColor: AppColors.primary,
    elevation: 1,
    automaticallyImplyLeading: false,
    title: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Row(
    children: [
    CircleAvatar(
    backgroundImage: AssetImage('images/avatar.png'),
    radius: 18,
    ),
    SizedBox(width: 10),
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    userFullName ?? "Chargement...",
    style: TextStyle(
    color: AppColors.white,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  ),
  ),
  Text(
  userPhoneNumber ?? "",
  style: TextStyle(
  color: AppColors.secondary,
  fontSize: 12,
  ),
  ),
  ],
  ),
  ],
  ),
  Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
  Text(
  "Ñu Demm",
  style: TextStyle(
  fontSize: 20,
  color: AppColors.white,
  fontWeight: FontWeight.bold,
  ),
  ),
  Text(
  "by PndTech",
  style: TextStyle(
  fontSize: 12,
  color: AppColors.secondary,
  ),
  ),
  ],
  ),
  ],
  ),
  bottom: PreferredSize(
  preferredSize: Size.fromHeight(30),
  child: Padding(
  padding: const EdgeInsets.only(bottom: 8.0),
  child: Text(
  userAddress ?? "Adresse actuelle...",
  style: TextStyle(
  color: AppColors.white,
  fontSize: 14,
  fontWeight: FontWeight.w500,
  ),
  ),
  ),
  ),
  ),

      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: AppColors.white,
              child: TabBar(
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.secondary,
                tabs: const [
                  Tab(icon: Icon(Icons.directions_bus), text: "Urbaines"),
                  Tab(icon: Icon(Icons.train), text: "Interurbaines"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTabContent(services, "urbains"),
                  _buildTabContent(servicesinterurbain, "interurbains"),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service,
      {double height = 140}) {
    return GestureDetector(
      onTap: () => _navigateToMain(service['title']),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.grey[100],
          boxShadow: [
            BoxShadow(
              color: AppColors.primary,
              blurRadius: 4,
              spreadRadius: 1,
            )
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Image.asset(service['image'], fit: BoxFit.contain)),
            SizedBox(height: 8),
            Text(
              service['title'],
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
  ///////////////////////////////////////////////////////////////////
  Widget _buildTabContent(List<Map<String, dynamic>> serviceList, String type) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //les  Services
          Text(
            "Services ${type == "urbains" ? "Urbains" : "Interurbains"}",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              if (serviceList.length > 0)
                Expanded(child: _buildServiceCard(serviceList[0], height: 160)),
              SizedBox(width: 12),
              if (serviceList.length > 1)
                Expanded(child: _buildServiceCard(serviceList[1], height: 160)),
            ],
          ),
          SizedBox(height: 12),

// Ligne 2 : 3 cartes
          Row(
            children: [
              if (serviceList.length > 2)
                Expanded(child: _buildServiceCard(serviceList[2], height: 130)),
              SizedBox(width: 8),
              if (serviceList.length > 3)
                Expanded(child: _buildServiceCard(serviceList[3], height: 130)),
              SizedBox(width: 8),
              if (serviceList.length > 4)
                Expanded(child: _buildServiceCard(serviceList[4], height: 130)),
            ],
          ),
          SizedBox(height: 20),

          // Champ destination
          Text(
            "Où allons-nous ?",
            style: TextStyle(fontSize: 16,color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MainScreen(autoFocusDestination: true)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.background,
              elevation: 1,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.primary),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.place, color: AppColors.primary),
                SizedBox(width: 10),
                Text(
                  "Où allons-nous ?",
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Historique
          Text(
            "Historique",
            style: TextStyle(fontSize: 16,color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(3, (index) {
                return Container(
                  width: 140,
                  margin: EdgeInsets.only(right: 12),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.local_taxi, size: 32, color: AppColors.primary),
                      SizedBox(height: 8),
                      Text("Service ${index + 1}",
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      Text("Date: 12/08",
                          style: TextStyle( color: AppColors.secondary)
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          SizedBox(height: 20),
          // Test commit du 18 juillet
// Test commit du 18 juillet
// Test commit du 18 juillet
// Test commit du 18 juillet
// Test commit du 18 juillet
// Test commit du 18 juillet


          // Publicités
          Text(
            "Publicité",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: AppColors.primary),
          ),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset("images/pub1.png", fit: BoxFit.cover, height: 150, width: double.infinity),
          ),
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset("images/pub2.png", fit: BoxFit.cover, height: 150, width: double.infinity),
          ),
          const SizedBox(height: 30),
          const Text(
            "100% Sénégalais - Ñu Demm by PndTech",
            style: TextStyle(color:AppColors.primary),
          ),
        ],
      ),
    );
  }

}
