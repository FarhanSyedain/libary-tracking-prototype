import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolylinesProvider with ChangeNotifier {
  final Map<PolylineId, Polyline> _polylines = {};
  final String apiKey;

  late Position destination;

  PolylinesProvider(
    this.apiKey,
  );

  late PolylinePoints polylinePoints;
  late Marker startMarker;
  late Marker endMarker;
  Set markers = {};
  List<LatLng> polylineCoordinates = [];

  void initDestination(position) {
    destination = position;
    notifyListeners();
  }

  

  createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    print('1');
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      apiKey, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.driving,
    );
    print(2);

    if (result.points.isNotEmpty) {
      for (PointLatLng point in result.points) {
        print(point);
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }
    }

    print(result);

    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    print('Polyline created');
    print('Polyline created');
    print('Polyline created');
    print('Polyline created');

    _polylines[id] = polyline;
    notifyListeners();
  }

  void draw_innital_markers(restrauntLocation) {
    double restrauntLat = restrauntLocation.latitude;
    double restruntLong = restrauntLocation.longitude;
    double consumerLat = destination.latitude;
    double consumerLong = destination.longitude;

    draw_markers(
      restrauntLat,
      restruntLong,
      consumerLat,
      consumerLong,
      innitial: true,
    );
  }

  List draw_markers(startLat, startLon, destLat, destLon, {innitial = false}) {
    Marker startMarker = Marker(
      markerId: MarkerId("sfdgh"),
      position: LatLng(startLat, startLon),
      icon: BitmapDescriptor.defaultMarker,
    );

    Marker endMarker = Marker(
      markerId: MarkerId("sfgh"),
      position: LatLng(destLat, destLon),
      icon: BitmapDescriptor.defaultMarker,
    );

    markers.add(startMarker);
    markers.add(endMarker);

    notifyListeners();

    double miny = (startLat <= destLat) ? startLat : destLat;
    double minx = (startLon <= destLon) ? startLon : destLon;
    double maxy = (startLat <= destLat) ? destLat : startLat;
    double maxx = (startLon <= destLon) ? destLon : startLon;

    // mapController.animateCamera(
    //   CameraUpdate.newLatLngBounds(
    //     LatLngBounds(
    //       northeast: LatLng(maxy, maxx),
    //       southwest: LatLng(miny, minx),
    //     ),
    //     100.0,
    //   ),
    // );

    if (innitial) {
      createPolylines(startLat, startLon, destLat, destLon);
    } else {
      // createPolylines(startLat, startLon, destLat, destLon);

      modifyPolyline();
    }

    return [minx, miny, maxx, maxy];
  }

  void modifyPolyline() {
    //Change polyline thingy
  }

  Map<PolylineId, Polyline> get polylines => _polylines;
}
