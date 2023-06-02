import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:patient/data_firebase.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GoogleMapController? _mapController;
  LocationData? _locationData;
  LatLng _currentLocation = const LatLng(0, 0);
  final double _zoom = 16.0;
  final Set<Circle> _circles = {}; // Set to store circles on the map
  double speed = 0.0;
  var getData = DataFirebase();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionStatus;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _currentLocation = const LatLng(0, 0);
        });
        return;
      }
    }

    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        setState(() {
          _currentLocation = const LatLng(0, 0);
        });
        return;
      }
    }

    try {
      _locationData = await location.getLocation();

      setState(() {
        _currentLocation =
            LatLng(_locationData!.latitude!, _locationData!.longitude!);
        speed = _locationData!.speed!;

        getData.savePatientLocation(
            _locationData!.latitude!, _locationData!.longitude!);
        getData.savePatirntSpeed(speed);
      });

      location.onLocationChanged.listen((LocationData currentLocation) {
        getData.savePatientLocation(
            currentLocation.latitude!, currentLocation.longitude!);
        getData.savePatirntSpeed(speed);
      });

      if (_mapController != null) {}
    } catch (e) {
      print('Error getting current location: $e');
      setState(() {
        _currentLocation = const LatLng(0, 0);
      });
    }
    _mapController!.animateCamera(
      CameraUpdate.newLatLng(_currentLocation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient'),
        centerTitle: true,
      ),
      body: GoogleMap(
        myLocationEnabled: true,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: _zoom,
        ),
        markers: {
          Marker(
              markerId: const MarkerId('currentLocation'),
              position: _currentLocation),
        },
        circles: _circles,
      ),
    );
  }
}
