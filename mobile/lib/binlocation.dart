import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapScreen extends StatefulWidget {
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  LatLng _currentLocation = LatLng(
    6.9271,
    79.8612,
  ); // Default location (Colombo)
  BitmapDescriptor? binIcon;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchBinsData();
  }

  // Fetch Bin Data from Firebase Firestore
  Future<void> _fetchBinsData() async {
    FirebaseFirestore.instance
        .collection('bins')
        .get()
        .then((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            setState(() {
              _markers.addAll(
                snapshot.docs.map((doc) {
                  var data = doc.data();
                  return Marker(
                    markerId: MarkerId(data['id']),
                    position: LatLng(data['lat'], data['lng']),
                    icon:
                        data['status'] == 'Full'
                            ? BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed,
                            )
                            : BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueGreen,
                            ),
                    infoWindow: InfoWindow(
                      title: data['location'],
                      snippet:
                          "Status: ${data['status']} \nWaste Level: ${data['wasteLevel']}",
                    ),
                  );
                }).toSet(),
              );
            });
          }
        })
        .catchError((error) {
          print("Error fetching bins: $error");
        });
  }

  // Get User's Current Location
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print("Location permission denied");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _markers.add(
        Marker(
          markerId: MarkerId("user_location"),
          position: _currentLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: "You are here"),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Smart Waste Bins")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 13,
        ),
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
