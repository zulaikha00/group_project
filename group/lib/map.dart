import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'api_service.dart';
import 'package:geocoding/geocoding.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController _mapController;
  LatLng _currentPosition =
      LatLng(2.9531, 101.7666); // Fallback position (Broga, Malaysia)
  bool _loading = true; // For loading state
  String _currentLocationName = ''; // Store the current location's name
  double _currentLatitude = 0.0; // Store the latitude
  double _currentLongitude = 0.0; // Store the longitude

  // List of clinic and hospital locations with names
  final List<Map<String, dynamic>> _clinicLocations = [
    {
      'name': 'Klinik Desa Rincing Tengah',
      'location': LatLng(
          2.9303, 101.8521), // Real coordinates for Klinik Desa Rincing Tengah
    },
    {
      'name': 'Klinik Desa Broga',
      'location':
          LatLng(2.9512, 101.7994), // Real coordinates for Klinik Desa Broga
    },
    {
      'name': 'Klinik Kesihatan Kajang',
      'location': LatLng(
          2.9932, 101.7918), // Real coordinates for Klinik Kesihatan Kajang
    },
    {
      'name': 'Hospital Kajang',
      'location':
          LatLng(2.9928, 101.7911), // Real coordinates for Hospital Kajang
    },
    {
      'name': 'Klinik Kesihatan Bandar Teknologi',
      'location': LatLng(2.9971,
          101.7897), // Real coordinates for Klinik Kesihatan Bandar Teknologi
    },
    {
      'name': 'Klinik Kesihatan Semenyih',
      'location': LatLng(
          2.9497, 101.7894), // Real coordinates for Klinik Kesihatan Semenyih
    },
    {
      'name': 'Klinik Kesihatan Bandar Rinching',
      'location': LatLng(2.9398,
          101.7634), // Real coordinates for Klinik Kesihatan Bandar Rinching
    },
    {
      'name': 'Klinik Kesihatan Broga',
      'location': LatLng(
          2.9483, 101.7589), // Real coordinates for Klinik Kesihatan Broga
    },
    {
      'name': 'Klinik Pergigian Semenyih',
      'location': LatLng(
          2.9475, 101.7649), // Real coordinates for Klinik Pergigian Semenyih
    },
    {
      'name': 'Klinik Pergigian Broga',
      'location': LatLng(
          2.9487, 101.7582), // Real coordinates for Klinik Pergigian Broga
    },
    {
      'name': 'Klinik Pakar Semenyih',
      'location': LatLng(
          2.9458, 101.7653), // Real coordinates for Klinik Pakar Semenyih
    },
    {
      'name': 'Klinik Pakar Broga',
      'location':
          LatLng(2.9462, 101.7583), // Real coordinates for Klinik Pakar Broga
    },
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getUserLocation();
  }

  // Get the current user location and reverse geocode to get the name
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled');
      setState(() {
        _loading = false;
      });
      return;
    }

    // Check for location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print('Location permission denied');
        setState(() {
          _loading = false;
        });
        return;
      }
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Get the address of the current location
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    String address = placemarks.isNotEmpty
        ? '${placemarks[0].locality}, ${placemarks[0].country}' // Customize this to your needs
        : 'Unknown Location';

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _currentLatitude = position.latitude; // Store latitude
      _currentLongitude = position.longitude; // Store longitude
      _loading = false;
      _currentLocationName = address; // Set the address
    });

    // Zoom into the user's location
    _mapController.move(_currentPosition, 14.0); // Adjust zoom level as needed
  }

  // Send location to the API
  Future<void> _sendLocationToApi(double latitude, double longitude) async {
    ApiService apiService = ApiService();

    // Call the API to save the location
    Map<String, dynamic> response = await apiService.sendLocationToApi(
      latitude,
      longitude,
    );

    print('API Response: $response');

    // Check if the response contains an error
    if (response.containsKey('error')) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response['error']}')),
      );
    } else {
      // Show success message if the response contains a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location successfully saved!')),
      );
    }
  }

  // Refresh map and zoom in
  void _refreshMap() {
    _getUserLocation(); // Fetch new location
  }

  // Zoom in
  void _zoomIn() {
    double newZoom = _mapController.camera.zoom + 1;
    _mapController.move(_currentPosition, newZoom);
  }

  // Zoom out
  void _zoomOut() {
    double newZoom = _mapController.camera.zoom - 1;
    _mapController.move(_currentPosition, newZoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Clinics and Hospitals'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Column(
              children: [
                // Display the user's current latitude and longitude
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Location: $_currentLocationName',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text('Latitude: $_currentLatitude'),
                      Text('Longitude: $_currentLongitude'),
                    ],
                  ),
                ),
                // FlutterMap widget to show the map
                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentPosition,
                      initialZoom: 14.0,
                      onTap: (_, __) {},
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          // User's current location marker
                          Marker(
                            width: 50.0,
                            height: 50.0,
                            point: _currentPosition,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text('Your Current Location'),
                                    content: Text(_currentLocationName),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(),
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.location_on,
                                color: Colors.blue,
                                size: 50.0,
                              ),
                            ),
                          ),
                          // Nearby clinic and hospital markers
                          ..._clinicLocations.map((clinic) {
                            return Marker(
                              width: 50.0,
                              height: 50.0,
                              point: clinic['location'],
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(clinic['name']),
                                      content: Text(
                                          'Location: ${clinic['location'].latitude}, ${clinic['location'].longitude}'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(),
                                          child: Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.local_hospital,
                                  color: Colors.red,
                                  size: 50.0,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
                // Buttons to save, refresh, and zoom
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () => _sendLocationToApi(
                            _currentLatitude, _currentLongitude),
                        child: Icon(Icons.save,
                            size: 30.0), // Icon for saving location
                      ),
                      ElevatedButton(
                        onPressed: _refreshMap,
                        child: Icon(Icons.refresh,
                            size: 30.0), // Icon for refreshing map
                      ),
                      ElevatedButton(
                        onPressed: _zoomIn,
                        child: Icon(Icons.zoom_in,
                            size: 30.0), // Icon for zooming in
                      ),
                      ElevatedButton(
                        onPressed: _zoomOut,
                        child: Icon(Icons.zoom_out,
                            size: 30.0), // Icon for zooming out
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
