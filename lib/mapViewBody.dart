import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracking_utils/provider/polylines.dart';

class MapBody extends StatelessWidget {
  final CameraPosition initialLocation;
  final Function initMapController;
  final Function getCurrentLocation;
  final Function animate;

  MapBody({
    required this.initialLocation,
    required this.getCurrentLocation,
    required this.initMapController,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    // Determining the screen width & height
    final mapProvider = Provider.of<PolylinesProvider>(context);
    var height = MediaQuery.of(context).size.height - 100;
    var width = MediaQuery.of(context).size.width;
    if (mapProvider.polylineCoordinates.isNotEmpty) {
      try {
        var startLat = mapProvider.animate![0].position.latitude;
        var startLon = mapProvider.animate![0].position.longitude;
        var destLat = mapProvider.animate![1].position.latitude;
        var destLon = mapProvider.animate![1].position.longitude;

        double miny = (startLat <= destLat) ? startLat : destLat;
        double minx = (startLon <= destLon) ? startLon : destLon;
        double maxy = (startLat <= destLat) ? destLat : startLat;
        double maxx = (startLon <= destLon) ? destLon : startLon;

        animate(maxy, maxx, miny, minx);
      } catch (e) {
        print(e);
      }
    }

    return Body(
      height: height,
      width: width,
      mapProvider: mapProvider,
      initialLocation: initialLocation,
      initMapController: initMapController,
      getCurrentLocation: getCurrentLocation,
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    Key? key,
    required this.height,
    required this.width,
    required this.mapProvider,
    required this.initialLocation,
    required this.initMapController,
    required this.getCurrentLocation,
  }) : super(key: key);

  final double height;
  final double width;
  final PolylinesProvider mapProvider;
  final CameraPosition initialLocation;
  final Function initMapController;
  final Function getCurrentLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: Stack(
        children: <Widget>[
          GoogleMap(
            markers: Set<Marker>.from(mapProvider.markers),
            polylines: Set<Polyline>.of(mapProvider.polylines.values),
            initialCameraPosition: initialLocation,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              // mapController = controller;
              initMapController(controller);
              getCurrentLocation();
            },
          ),
        ],
      ),
    );
  }
}
