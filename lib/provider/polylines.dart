import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracking_utils/services/consumer.dart';

class PolylinesProvider with ChangeNotifier {
  final Map<PolylineId, Polyline> _polylines = {};
  final String apiKey;
  late final ConsumerMainConnection _socketConnection;
  late Position destination;
  late PolylinePoints polylinePoints;
  late Marker startMarker;
  late Marker endMarker;
  Set markers = {};
  List<LatLng> polylineCoordinates = [];

  PolylinesProvider(this.apiKey) {
    _socketConnection = ConsumerMainConnection();
    _socketConnection.initConnection();
    _socketConnection.getDriverLocation().listen(_socketEventHandler);
  }

  void _socketEventHandler(event) {
    //Listen to events here
    //
    //

    //
  }

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
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      apiKey, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.driving,
    );

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
