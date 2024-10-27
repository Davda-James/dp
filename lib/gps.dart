import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GPSPage extends StatefulWidget {
  @override
  _GPSPageState createState() => _GPSPageState();
}

class _GPSPageState extends State<GPSPage> {
  late GoogleMapController _mapController;
  final databaseRef =
      FirebaseDatabase.instance.ref().child('busLocations/busA');
  Marker? _busMarker;

  @override
  void initState() {
    super.initState();
    _listenToLocationUpdates();
    _sendLocationToFirebase(); // Start sending the driver's location
  }

  void _listenToLocationUpdates() {
    databaseRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final lat = data['latitude'];
        final lng = data['longitude'];
        _updateMarkerPosition(lat, lng);
      }
    });
  }

  void _updateMarkerPosition(double latitude, double longitude) {
    final newPosition = LatLng(latitude, longitude);
    setState(() {
      _busMarker = Marker(
        markerId: MarkerId('busA'),
        position: newPosition,
        infoWindow: InfoWindow(title: 'Bus A'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    });
    _mapController.animateCamera(CameraUpdate.newLatLng(newPosition));
  }

  Future<void> _sendLocationToFirebase() async {
    // Request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print("Location permission denied.");
        return;
      }
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Send location to Firebase
    await databaseRef.set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Real-Time Bus Tracking')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target:
              LatLng(0.0, 0.0), // Default position; updated upon location fetch
          zoom: 15,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        markers: _busMarker != null ? {_busMarker!} : {},
      ),
    );
  }
}
