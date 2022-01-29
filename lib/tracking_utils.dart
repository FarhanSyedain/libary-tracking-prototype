library tracking_utils;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'mapViewBody.dart';

class MapView extends StatefulWidget {
  final String API_KEY;
  List<double> initialLocation;
  MapView({
    Key? key,
    required String this.API_KEY,
    List<double> this.initialLocation = const [0.0, 0.0],
  });

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final TextEditingController _controller = TextEditingController();

  late final CameraPosition _initialLocation = CameraPosition(
    target: LatLng(
      widget.initialLocation[0],
      widget.initialLocation[1],
    ),
  );

  late GoogleMapController mapController;
  late Position _currentPosition;

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition().then(
      (Position position) async {
        setState(
          () {
            // Store the position in the variable
            // For moving the camera to current location
            _currentPosition = position;
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 16.0,
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _animateCamera(maxy, maxx, miny, minx) {
    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(maxy, maxx),
          southwest: LatLng(miny, minx),
        ),
        100.0,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // driver.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        MapBody(
          initMapController: initMapController,
          initialLocation: _initialLocation,
          getCurrentLocation: _getCurrentLocation,
          animate: _animateCamera,
        ),
      ]),
    );
  }

  void initMapController(controller) {
    mapController = controller;
  }
}

