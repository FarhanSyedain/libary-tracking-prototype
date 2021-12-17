library tracking_utils;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:tracking_utils/provider/polylines.dart';
import 'package:tracking_utils/driver.dart';

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
  Set markers = {};

  draw_markers() {
    double startLat = _currentPosition.latitude;
    double startLon = _currentPosition.longitude;
    double destLat = startLat + 0.03;
    double destLon = startLon + 0.09;

    Marker startMarker = Marker(
      markerId: MarkerId("sfdgh"),
      position: LatLng(startLat, startLon),
      icon: BitmapDescriptor.defaultMarker,
    );

    Marker endMarker = Marker(
      markerId: MarkerId("sfgh"),
      position: LatLng(destLat, destLon),
      // infoWindow: InfoWindow(
      //   title: 'Start $startCoordinatesString',
      // ),
      icon: BitmapDescriptor.defaultMarker,
    );
    setState(() {
      markers.add(startMarker);
      markers.add(endMarker);
    });

    double miny = (startLat <= destLat) ? startLat : destLat;
    double minx = (startLon <= destLon) ? startLon : destLon;
    double maxy = (startLat <= destLat) ? destLat : startLat;
    double maxx = (startLon <= destLon) ? destLon : startLon;

    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(maxy, maxx),
          southwest: LatLng(miny, minx),
        ),
        100.0,
      ),
    );

    Provider.of<PolylinesProvider>(
      context,
      listen: false,
    ).createPolylines(startLat, startLon, destLat, destLon);
  }

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition().then((Position position) async {
      setState(() {
        // Store the position in the variable
        _currentPosition = position;

        // For moving the camera to current location
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 16.0,
            ),
          ),
        );
      });
    });
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
          markers: markers,
          initMapController: initMapController,
          initialLocation: _initialLocation,
          getCurrentLocation: _getCurrentLocation,
          draw_markers: draw_markers,
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Form(
            child: TextFormField(
              controller: _controller,
              decoration:
                  const InputDecoration(labelText: 'Echo Websocket test'),
            ),
          ),
        ),
        Container(
          child: test_socket(driver, context),
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: const Icon(Icons.send),
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      driver.sendLocation(_controller.text);
    }
  }

  void initMapController(controller) {
    mapController = controller;
  }
}

class MapBody extends StatelessWidget {
  final Set<dynamic> markers;
  final CameraPosition initialLocation;
  final Function initMapController;
  final Function getCurrentLocation;
  final Function draw_markers;

  MapBody({
    required this.markers,
    required this.initialLocation,
    required this.getCurrentLocation,
    required this.draw_markers,
    required this.initMapController,
  });

  @override
  Widget build(BuildContext context) {
    // Determining the screen width & height
    final polylineProvider = Provider.of<PolylinesProvider>(context);

    var height = MediaQuery.of(context).size.height / 2;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      child: Stack(
        children: <Widget>[
          GoogleMap(
            markers: Set<Marker>.from(markers),
            polylines: Set<Polyline>.of(polylineProvider.polylines.values),
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
                    onTap: () {
                      draw_markers();
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

Widget test_socket(Driver driver, BuildContext context) {
  return driver.getLocation(context);
}
