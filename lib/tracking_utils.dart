library tracking_utils;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:tracking_utils/provider/markers.dart';
import 'package:tracking_utils/provider/polylines.dart';
import 'package:tracking_utils/driver.dart';
import 'package:tracking_utils/services/consumer.dart';

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
  Driver driver = Driver(id: "qwerty");
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

      // double miny = (_minx <= _maxx) ? _minx : maxx;
      // double minx = (_miny <= _maxy) ? _minx : _maxx;
      // double maxy = (_minx <= _maxx) ? _maxx : _minx;
      // double maxx = (_miny <= _maxx) ? _maxy : _miny;

      animate(maxy, maxx, miny, minx); } 
      catch(e) {
        print(e);
      }
    }
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
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(right: 10.0, bottom: 10.0),
              child: ClipOval(
                child: Material(
                  color: Colors.orange.shade100, // button color
                  child: InkWell(
                    splashColor: Colors.orange, // inkwell color
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(Icons.my_location),
                    ),
                    onTap: () {
                      getCurrentLocation();
                    },
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
              child: ClipOval(
                child: Material(
                  color: Colors.orange.shade100, // button color
                  child: InkWell(
                    splashColor: Colors.orange, // inkwell color
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(Icons.add_box_rounded),
                    ),
                    onTap: () async {
                      List minVals =
                          await context.read<PolylinesProvider>().draw_markers(
                                33.6596,
                                118.8597,
                                34.6596,
                                117.8597,
                                // innitial: true,
                              );

                      var minx = minVals[0];
                      var miny = minVals[1];
                      var maxx = minVals[2];
                      var maxy = minVals[3];

                      animate(maxy, maxx, miny, minx);

                      // draw_markers();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
