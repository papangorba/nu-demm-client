import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pndtech_client/authentification/connexion_page.dart';
import 'package:http/http.dart' as http;

import '../authentification/register_screen.dart';
import '../global/global.dart';
import '../splashScreen/splash_screen.dart';
import '../theme/theme.dart';
import 'package:intl/intl.dart';


class MainScreen extends StatefulWidget {
  final bool autoFocusDestination;

  MainScreen({this.autoFocusDestination = false});


  @override
  State<MainScreen> createState() => _MainScreenState();


}

class _MainScreenState extends State<MainScreen> {
  final FocusNode destinationFocusNode = FocusNode();


  ///////////////////////////////////////////////////////////////
  final List<Map<String, dynamic>> _vtcList = [
    {
      "logo": "images/logo.png",
      "nom": "Papa n dia",
      "type": "ECO",
      "prix": 1700,
      "temps": "6 min",
      "distance": "3.5 km",
      "lat": 14.7000,
      "lng": -17.4500,
      "service": "Livraison",
    },
    {
      "logo": "images/yango.png",
      "nom": "Papa n dia",
      "type": "ECO",
      "prix": 1500,
      "temps": "5 min",
      "distance": "3.2 km",
      "lat": 14.7000,
      "lng": -17.4500,
      "service": "Livraison",
    },
    {
      "logo": "images/yassir.png",
      "nom": "Papa n dia",
      "type": "Berline",
      "prix": 2000,
      "temps": "7 min",
      "distance": "3.8 km",
      "lat": 14.7000,
      "lng": -17.4500,
      "service": "Livraison",
    },
    {
      "logo": "images/bkg.png",
      "nom": "Papa n dia",
      "type": "ECO",
      "prix": 1700,
      "temps": "6 min",
      "distance": "3.5 km",
      "lat": 14.7000,
      "lng": -17.4500,
      "service": "Livraison",
    },
  ];
  //////////////////////////////////////////////////////////////
  final Completer<GoogleMapController> _mapController = Completer();
  GoogleMapController? newGoogleMapController;
  LatLng? _currentPosition;
  final TextEditingController destinationController = TextEditingController();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Set<Circle> _circles = {};
  bool showTripDetails = false;
  double _sheetSize = 0.4;

  Timer? _reminderTimer;
  bool _dialogShown = false;

  String? userFullName;
  String? userPhoneNumber;
  String? selectedServiceType;
  User? currentFirebaseUser;
  @override
  void initState() {
    super.initState();
    currentFirebaseUser = FirebaseAuth.instance.currentUser;
    _requestPermissionAndLocate();
    _checkUserInfoCompletion();
    _loadUserMenuInfos();
    if (widget.autoFocusDestination) {
      Future.microtask(() => destinationFocusNode.requestFocus());
    }
  }

  Future<void> _requestPermissionAndLocate() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _markers.add(
          Marker(
            markerId: MarkerId("currentLocation"),
            position: _currentPosition!,
            infoWindow: InfoWindow(title: "Vous êtes ici"),
          ),
        );
      });
    }
  }
  Future<void> _checkUserInfoCompletion() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userRef = FirebaseDatabase.instance.ref().child('clients').child(user.uid);
    final snapshot = await userRef.get();
    if (!snapshot.exists || snapshot.child('infosCompletes').value != true) {
      _startReminderTimer(userRef);
    }
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
  void _startReminderTimer(DatabaseReference userRef) {
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      final snapshot = await userRef.get();
      if (snapshot.exists && snapshot.child('infosCompletes').value == true) {
        timer.cancel();
        return;
      }
      if (!_dialogShown && mounted) {
        _dialogShown = true;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Compléter vos informations"),
            content: Text("Souhaitez-vous compléter votre nom et prénom maintenant ?"),
            actions: [
              TextButton(onPressed: () {
                _dialogShown = false;
                Navigator.pop(context);
              }, child: Text("Plus tard")),
              TextButton(onPressed: () {
                _dialogShown = false;
                timer.cancel();
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage()));
              }, child: Text("Oui, maintenant")),
            ],
          ),
        );
      }
    });
  }
  void _simulateTripData() {
    _polylines.clear();

    // Création de la polyline (itinéraire fictif)
    _polylines.add(Polyline(
      polylineId: PolylineId("route"),
      color: Colors.blue,
      width: 4,
      points: [
        _currentPosition!,
        LatLng(
          _currentPosition!.latitude - 0.01,
          _currentPosition!.longitude + 0.01,
        ),
      ],
    ));

    // Ajout d'un cercle de 3 km autour de la position actuelle
    _circles.clear(); // si tu veux supprimer les anciens cercles
    _circles.add(Circle(
      circleId: CircleId("zoneDeRayon"),
      center: _currentPosition!,
      radius: 1000, // 3 km en mètres
      fillColor: Colors.blue.withOpacity(0.2),
      strokeColor: Colors.blueAccent,
      strokeWidth: 2,
    ));

    setState(() {
      showTripDetails = true;
    });
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => ConnexionPage()),
          (route) => false,
    );
  }
  Future<void> _getDirections(LatLng origin, LatLng destination) async {
    final apiKey = 'AIzaSyBD-qgcrVESVbRxRT69mM1pFrLKO0zoKKA';

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final points = data['routes'][0]['overview_polyline']['points'];

      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(points);

      List<LatLng> polylineCoordinates = decodedPoints
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      setState(() {
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: PolylineId("route"),
          color: Colors.red,
          width: 5,
          points: polylineCoordinates,
        ));
      });
    } else {
      print("Erreur Directions API : ${response.body}");
    }
  }
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    final apiKey = 'AIzaSyBD-qgcrVESVbRxRT69mM1pFrLKO0zoKKA';
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final location = data['results'][0]['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      } else {
        print("Adresse non trouvée : ${data['status']}");
        return null;
      }
    } else {
      print("Erreur API : ${response.statusCode}");
      return null;
    }
  }
  Future<void> enregistrerCommande() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Fluttertoast.showToast(msg: "Utilisateur non connecté !");
      return;
    }

    final userId = user.uid;
    // 🔹 Récupérer les infos du client depuis Firebase Database
    final clientSnapshot = await FirebaseDatabase.instance
        .ref()
        .child('clients')
        .child(userId)
        .get();

    if (!clientSnapshot.exists) {
      Fluttertoast.showToast(msg: "Informations client introuvables !");
      return;
    }

    final prenom = clientSnapshot.child("prenom").value?.toString() ?? "";
    final nom = clientSnapshot.child("nom").value?.toString() ?? "";
    final telephone = clientSnapshot.child("phone").value?.toString() ?? "";
    final fullName = "$prenom $nom";

    final destination = destinationController.text.trim().isNotEmpty
        ? destinationController.text.trim()
        : "Destination inconnue"; // ⚠️ ici tu peux rendre dynamique

    final typeService = selectedServiceType ?? "Courses";
    final vtc = "VTC standard"; // ⚠️ tu peux aussi rendre ça dynamique
    final prix = 3500;          // idem
    final km = 5.2;
    final tempsAttente = "8 min";
    final now = DateTime.now();

    final dateCommande = DateFormat('yyyy-MM-dd').format(now);
    final heureCommande = DateFormat('HH:mm:ss').format(now);

    DatabaseReference commandeRef =
    FirebaseDatabase.instance.ref().child("commandes").push();

    Map<String, dynamic> commandeData = {
      "idClient": userId,
      "nomClient": fullName,
      "telephoneduclient":telephone,
      "typeService": typeService,
      "destination": destination,
      "vtc": vtc,
      "prix": prix,
      "kilometres": km,
      "tempsAttente": tempsAttente,
      "dateCommande": dateCommande,
      "heureCommande": heureCommande,
    };

    await commandeRef.set(commandeData);

    Fluttertoast.showToast(msg: "Commande enregistrée avec succès !");

    setState(() {
      showTripDetails = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
        onWillPop: () async => false,
      child: Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('images/avatar.png'),
              ),
              accountName: Text(
                userFullName ?? 'Nom non défini',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(
                userPhoneNumber ?? '',
                style: TextStyle(color: AppColors.secondary),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person,color: AppColors.primary,),
              title: Text('Modifier les informations personels',
                style: TextStyle(color: AppColors.secondary),

              ),
             // onTap: _signOut,
            ),
            ListTile(
              leading: Icon(Icons.description,color: AppColors.primary),
              title: Text('Condition et terme d utilisation',
                style: TextStyle(color: AppColors.secondary)
              ),
            //  onTap: _signOut,
            ),
            ListTile(
              leading: Icon(Icons.support_agent,color: AppColors.primary),
              title: Text('Support client',
                style: TextStyle(color: AppColors.secondary)),
            //  onTap: _signOut,
            ),
            ListTile(
              leading: Icon(Icons.attach_money,color: AppColors.primary),
              title: Text('Infos tarifs',
                style: TextStyle(color: AppColors.secondary)),
            //  onTap: _signOut,
            ),
            ListTile(
              leading: Icon(Icons.logout,color: AppColors.primary),
              title: Text('Déconnexion',
                style: TextStyle(color: AppColors.secondary)),
              onTap: _signOut,
            ),
            ListTile(
              leading: Icon(Icons.delete_forever,color: AppColors.primary),
              title: Text('Supprimer le compte',
                style: TextStyle(color: AppColors.secondary)),
              //  onTap: _signOut,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Ñu Demm",
            style: TextStyle(color:AppColors.primary ),
        ),
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition!,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController.complete(controller);
              newGoogleMapController = controller;
            },
            markers: _markers,
            polylines: _polylines,
            circles: _circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            top: 20,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: AppColors.primary, blurRadius: 6)],
                  ),
                  child: TextField(
                    enabled: false, // Non modifiable
                    controller: TextEditingController(
                      text: _currentPosition != null
                          ? "Position actuelle : ${_currentPosition!.latitude.toStringAsFixed(5)}, ${_currentPosition!.longitude.toStringAsFixed(5)}"
                          : "Chargement de la position...",
                    ),
                    style: TextStyle( // 🔹 Couleur du texte principal
                      color: AppColors.secondary,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(

                      border: InputBorder.none,
                      icon: Icon(Icons.my_location, color: AppColors.primary),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: AppColors.primary, blurRadius: 6)],
                  ),
                  child: TextField(
                    controller: destinationController,
                    focusNode: destinationFocusNode,
                    autofocus: widget.autoFocusDestination,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: "Entrez votre destination",
                      hintStyle: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      icon: Icon(Icons.place, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          _simulateTripData();
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.arrow_back, color: AppColors.primary),
                    ),
                  ),
                ),

              ],
            ),
          ),
          if (showTripDetails)
            Positioned(
              right: 16,
              bottom: screenHeight * _sheetSize + 4,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: AppColors.error,
                elevation: 4,
                onPressed: () {
                  setState(() {
                    showTripDetails = false;
                  });
                },
                child: const Icon(Icons.close, color: AppColors.white,),
              ),
            ),

          if (showTripDetails)
            NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                setState(() {
                  _sheetSize = notification.extent;
                });
                return true;
              },
              child:DraggableScrollableSheet(
                initialChildSize: 0.4,
                minChildSize: 0.25,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [BoxShadow(blurRadius: 8, color: AppColors.primary)],
                    ),
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: 70,
                            height: 10,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),

                        const Text(
                          "Chauffeurs disponibles ",
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold ,color:AppColors.primary),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: _vtcList.length,
                            itemBuilder: (context, index) {
                              final vtc = _vtcList[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary,
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Row(

                                  children: [

                                    const SizedBox(height: 8),
                                    CircleAvatar(
                                      backgroundImage: AssetImage("images/avatar.png"),
                                      radius: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${vtc['nom']}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "${vtc['type']} • ${vtc['service']}",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.access_time, size: 14, color: Colors.grey),
                                              SizedBox(width: 4),
                                              Text(vtc['temps'], style: TextStyle(fontSize: 12)),
                                              SizedBox(width: 10),
                                              Icon(Icons.map, size: 14, color: Colors.grey),
                                              SizedBox(width: 4),
                                              Text(vtc['distance'], style: TextStyle(fontSize: 12)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Image.asset(vtc['logo'], width: 60, height: 24),
                                        const SizedBox(height: 6),
                                        Text(
                                          "${vtc['prix']} FCFA",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.red,
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.secondary,
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          onPressed: (){
                                            // Logique de sélection ici
                                          },
                                          child: const Text("Choisir",
                                            style: TextStyle(
                                              color: AppColors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),

                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await enregistrerCommande();
                            LatLng destination = LatLng(
                             _currentPosition!.latitude - 0.01,
                             _currentPosition!.longitude + 0.01,
                            );
                           // _getDirections(_currentPosition!, destination);
                          },
                          icon: Icon(Icons.check_circle_outline,color: AppColors.white,),
                          label: const Text("Commander ce trajet",
                            style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                          ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),





        ],
      ),
    )
    );
  }
}
