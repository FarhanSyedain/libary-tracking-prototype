import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracking_utils/provider/utils.dart';
import 'package:tracking_utils/services/consumer.dart';
import 'package:http/http.dart' as http;

class PolylinesProvider with ChangeNotifier {
  final Map<PolylineId, Polyline> _polylines = {};
  final String apiKey;
  late final ConsumerMainConnection _socketConnection;
  final String token;
  late Position destination;
  late PolylinePoints polylinePoints;
  late Marker startMarker;
  late Marker endMarker;
  List? animate = [];
  List<List> afterPolyLinePoints = [];
  Set<Marker> markers = {};
  List<LatLng> polylineCoordinates = [];

  PolylinesProvider(this.apiKey, this.token) {
    _socketConnection = ConsumerMainConnection();
    _socketConnection.initConnection(token);
    _socketConnection.getDriverLocation().listen(_socketEventHandler);
  }

  void _socketEventHandler(LatLng? event) {
    print(event);
    draw_markers_parent(33.6971, 75.2844, event!.latitude, event.longitude);
    // draw_markers_parent(33.6971, 75.2844, 33.808, 75.085);
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
      // PointLatLng(destinationLatitude, destinationLongitude),
      PointLatLng(33.808, 75.085),
      travelMode: TravelMode.driving,
    );
    polylineCoordinates.clear();

    if (result.points.isNotEmpty) {
      for (PointLatLng point in result.points) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }
    }

    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    _polylines.clear();
    _polylines[id] = polyline;
    if (afterPolyLinePoints.isNotEmpty) {
      draw_markers(
        afterPolyLinePoints[1][0],
        afterPolyLinePoints[1][1],
        afterPolyLinePoints[0][0],
        afterPolyLinePoints[0][1],
      );
    } else {
      print(
          'fdlkfjasdlkfjdsalkfjadslkfjalkds;fjldsakfjldsakfjasdlk;jfklasdjfklads');
    }
    notifyListeners();
  }

  void draw_innital_markers(restrauntLocation) {
    // double restrauntLat = restrauntLocation.latitude;
    // double restruntLong = restrauntLocation.longitude;
    // double consumerLat = destination.latitude;
    // double consumerLong = destination.longitude;

    // draw_markers(
    //   restrauntLat,
    //   restruntLong,
    //   consumerLat,
    //   consumerLong,
    //   innitial: true,
    // );
  }

  Future<List?> draw_markers_parent(
      startLat, startLon, destLat, destLon) async {
    if (polylineCoordinates.isEmpty) {
      print('dasfdsafasdfdasfsd');
      afterPolyLinePoints.addAll([
        [destLat, destLon],
        [startLat, startLon]
      ]);
      createPolylines(startLat, startLon, destLat, destLon);
      return null;
    } else {
      print('dasfdsafasdffsdfdsafdsdasfsd');

      return await draw_markers(startLat, startLon, destLat, destLon);
    }
  }

  Future<List> draw_markers(startLat, startLon, destLat, destLon,
      {innitial = true}) async {
    final correctedLocation = adjustLocation(
      [destLat, destLon],
      polylineCoordinates.map((e) {
        return [e.latitude, e.longitude];
      }).toList(),
    );

    Marker startMarker = Marker(
      markerId: MarkerId("start"),
      position: LatLng(startLat, startLon),
      icon: BitmapDescriptor.defaultMarker,
    );
    Marker actualMarker = Marker(
        markerId: MarkerId("actual"),
        position: LatLng(destLat, destLon),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure));
    Marker endMarker = Marker(
        markerId: MarkerId("end"),
        position: LatLng(correctedLocation[0], correctedLocation[1]),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen));
    animate = [];
    animate?.clear();
    animate?.add(startMarker);
    animate?.add(endMarker);
    markers.clear();
    markers.add(startMarker);
    markers.add(actualMarker);
    markers.add(endMarker);

    notifyListeners();

    double miny = (startLat <= destLat) ? startLat : destLat;
    double minx = (startLon <= destLon) ? startLon : destLon;
    double maxy = (startLat <= destLat) ? destLat : startLat;
    double maxx = (startLon <= destLon) ? destLon : startLon;

    if (polylineCoordinates.isEmpty) {
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

  // sendDFDASFASDFSD(data) {
  //   final dfjlkdasjflkadsj = jsonEncode(data);

  //   Clipboard.setData(ClipboardData(text: dfjlkdasjflkadsj));
  // }

  Map<PolylineId, Polyline> get polylines => _polylines;
}
