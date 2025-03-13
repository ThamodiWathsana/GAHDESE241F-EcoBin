import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class BinLocationMapPage extends StatefulWidget {
  const BinLocationMapPage({Key? key}) : super(key: key);

  @override
  _BinLocationMapPageState createState() => _BinLocationMapPageState();
}

class _BinLocationMapPageState extends State<BinLocationMapPage> {
  Completer<GoogleMapController> _mapControllerCompleter = Completer();
  GoogleMapController? _mapController;
  bool _isLoading = true;
  final Set<Marker> _markers = {};
  
  // Colors for green theme
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color lightGreen = const Color(0xFFE8F5E9);
  final Color darkGreen = const Color(0xFF2E7D32);

  // Initial camera position centered on Sri Lanka
  static const CameraPosition _sriLankaPosition = CameraPosition(
    target: LatLng(7.8731, 80.7718), // Centered on Sri Lanka
    zoom: 8.0,
  );

  @override
  void initState() {
    super.initState();
    _loadBinLocations();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // Sample data - replace with your actual API call or data source
  void _loadBinLocations() async {
    // Simulating loading data from API
    await Future.delayed(const Duration(seconds: 1));
    
    // Sample bin locations across Sri Lanka
    final List<Map<String, dynamic>> bins = [
      {
        'id': '1',
        'name': 'Colombo Central Bin',
        'lat': 6.9271,
        'lng': 79.8612,
        'status': 'Available',
        'fillLevel': 30,
      },
      {
        'id': '2',
        'name': 'Kandy City Bin',
        'lat': 7.2906,
        'lng': 80.6337,
        'status': 'Almost Full',
        'fillLevel': 85,
      },
      {
        'id': '3',
        'name': 'Galle Fort Bin',
        'lat': 6.0328,
        'lng': 80.2170,
        'status': 'Available',
        'fillLevel': 45,
      },
      {
        'id': '4',
        'name': 'Jaffna Central Bin',
        'lat': 9.6612,
        'lng': 80.0255,
        'status': 'Full',
        'fillLevel': 95,
      },
      {
        'id': '5',
        'name': 'Negombo Beach Bin',
        'lat': 7.2080,
        'lng': 79.8330,
        'status': 'Available',
        'fillLevel': 20,
      },
      {
        'id': '6',
        'name': 'Anuradhapura Bin',
        'lat': 8.3114,
        'lng': 80.4037,
        'status': 'Maintenance',
        'fillLevel': 0,
      },
    ];

    // Create markers for each bin
    for (var bin in bins) {
      final BitmapDescriptor markerIcon = await _getMarkerIcon(bin['fillLevel']);
      
      _markers.add(
        Marker(
          markerId: MarkerId(bin['id']),
          position: LatLng(bin['lat'], bin['lng']),
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: bin['name'],
            snippet: '${bin['status']} - ${bin['fillLevel']}% filled',
          ),
          onTap: () {
            _showBinDetails(bin);
          },
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Get custom marker icon based on fill level
  Future<BitmapDescriptor> _getMarkerIcon(int fillLevel) async {
    if (fillLevel >= 90) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    } else if (fillLevel >= 70) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    } else if (fillLevel >= 30) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    } else {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  void _showBinDetails(Map<String, dynamic> bin) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bin['name'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: primaryGreen,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Location: ${bin['lat'].toStringAsFixed(4)}, ${bin['lng'].toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: primaryGreen,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${bin['status']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text('Fill Level: ${bin['fillLevel']}%'),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: bin['fillLevel'] / 100,
                  minHeight: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    bin['fillLevel'] >= 90
                        ? Colors.red
                        : bin['fillLevel'] >= 70
                            ? Colors.orange
                            : bin['fillLevel'] >= 30
                                ? Colors.yellow
                                : primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.directions),
                      label: const Text('Directions'),
                      onPressed: () {
                        // Add navigation functionality here
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.rate_review),
                      label: const Text('Review'),
                      onPressed: () {
                        // Navigate to review page
                        Navigator.pop(context);
                        // Add navigation to review page here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text('Bin Locations'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
              _showFilterOptions();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _sriLankaPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _mapControllerCompleter.complete(controller);
              // Apply custom map style if needed
              // _setMapStyle(controller);
            },
          ),
          
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.7),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                ),
              ),
            ),
            
          // Search bar at the top
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for bins nearby...',
                  prefixIcon: Icon(Icons.search, color: primaryGreen),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
              ),
            ),
          ),
          
          // Legend
          Positioned(
            right: 16,
            bottom: 90,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bin Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('Available'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.yellow,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('Filling Up'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('Almost Full'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('Full'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'location',
            backgroundColor: Colors.white,
            foregroundColor: primaryGreen,
            mini: true,
            onPressed: () async {
              // Get current location and move camera
              final GoogleMapController controller = await _mapControllerCompleter.future;
              controller.animateCamera(
                CameraUpdate.newCameraPosition(_sriLankaPosition),
              );
            },
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'add',
            backgroundColor: darkGreen,
            onPressed: () {
              // Add new bin functionality
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  // Optional - set custom map style
  // Future<void> _setMapStyle(GoogleMapController controller) async {
  //   String style = await DefaultAssetBundle.of(context).loadString('assets/map_style.json');
  //   controller.setMapStyle(style);
  // }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Bins',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                value: true,
                onChanged: (value) {},
                title: const Text('Available Bins'),
                activeColor: primaryGreen,
              ),
              CheckboxListTile(
                value: true,
                onChanged: (value) {},
                title: const Text('Almost Full Bins'),
                activeColor: primaryGreen,
              ),
              CheckboxListTile(
                value: true,
                onChanged: (value) {},
                title: const Text('Full Bins'),
                activeColor: primaryGreen,
              ),
              CheckboxListTile(
                value: false,
                onChanged: (value) {},
                title: const Text('Maintenance Bins'),
                activeColor: primaryGreen,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}