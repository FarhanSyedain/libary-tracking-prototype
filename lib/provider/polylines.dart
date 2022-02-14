import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracking_utils/provider/icon.dart';
import 'package:tracking_utils/provider/utils.dart';
import 'package:tracking_utils/services/consumer.dart';
import 'dart:ui' as ui;
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class PolylinesProvider with ChangeNotifier {
  PolylinesProvider(this.apiKey, this.token, this.context, this.customIcon) {
    //Class used to comunicate with backend
    _socketConnection = ConsumerMainConnection();
    //Inniaite sockets with backend
    _socketConnection.initConnection(token);
    //Listen to drivers location -- Since, map will only be rendered when driver is assigned.
    _socketConnection.getDriverLocation().listen(_socketEventHandler);
  }

  //This will be used by google maps to draw polylines.
  final Map<PolylineId, Polyline> _polylines = {};
  //Google maps api key
  final String apiKey;
  //Backend class;
  late final ConsumerMainConnection _socketConnection;
  //Access token of signed in user
  final String token;
  //The place where product (children or risiti) is to be delivered
  late Position destination;
  //Class for fetching polylines
  late PolylinePoints polylinePoints;
  // The marker for [destination]
  late Marker startMarker;
  //The marker for [driver]
  late Marker endMarker;
  //will be used in build functin for animating map
  List? animate = [];
  //Marker points to be drawn. Add marker here instead of map when polyline  has not been fetched.
  List<List> afterPolyLinePoints = [];
  Set<Marker> markers = {};
  List<LatLng> polylineCoordinates = [];
  final BuildContext context;
  final BitmapDescriptor customIcon;

  void _socketEventHandler(event) {
    final LatLng point = event[0];
    final LatLng destination = event[1];
    draw_markers_parent(
      point.latitude,
      point.longitude,
      destination.latitude,
      destination.longitude,
    );
  }

  void initDestination(position) {
    destination = position;
    notifyListeners();
  }

  static Future<bool> handlePermission() async {
    final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
    bool serviceEnabled;

    LocationPermission permission;
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return false;
        }
      }
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.

      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    return true;
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
      PointLatLng(destinationLatitude, destinationLongitude),
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
    notifyListeners();

    if (afterPolyLinePoints.isNotEmpty) {
      draw_markers(
        afterPolyLinePoints[1][0],
        afterPolyLinePoints[1][1],
        afterPolyLinePoints[0][0],
        afterPolyLinePoints[0][1],
      );
    }
  }

  Future<List?> draw_markers_parent(
      startLat, startLon, destLat, destLon) async {
    if (polylineCoordinates.isEmpty) {
      afterPolyLinePoints.addAll([
        [destLat, destLon],
        [startLat, startLon]
      ]);
      createPolylines(startLat, startLon, destLat, destLon);
      return null;
    } else {
      return await draw_markers(startLat, startLon, destLat, destLon);
    }
  }

  Future<List> draw_markers(startLat, startLon, destLat, destLon,
      {innitial = true}) async {
    final result = adjustLocation(
      [startLat, startLon],
      polylineCoordinates.map((e) {
        return [e.latitude, e.longitude];
      }).toList(),
    );

    final correctedLocation = result[1];
    final min_idx = result[0];

    Marker startMarker = Marker(
      markerId: MarkerId("start"),
      position: LatLng(destLat, destLon),
      icon: BitmapDescriptor.defaultMarker,
    );

    Marker endMarker = Marker(
      markerId: MarkerId("end"),
      position: LatLng(correctedLocation[0], correctedLocation[1]),
      // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      // icon: BitmapDescriptor.fromBytes(byteData)
      icon: customIcon,
    );
    animate?.clear();
    animate?.addAll([startMarker, endMarker]);

    markers.clear();
    markers.addAll([startMarker, endMarker]);

    notifyListeners();

    if (polylineCoordinates.isEmpty) {
      createPolylines(startLat, startLon, destLat, destLon);
    } else {
      modifyPolyline(min_idx);
    }

    double miny = (startLat <= destLat) ? startLat : destLat;
    double minx = (startLon <= destLon) ? startLon : destLon;
    double maxy = (startLat <= destLat) ? destLat : startLat;
    double maxx = (startLon <= destLon) ? destLon : startLon;

    return [minx, miny, maxx, maxy];
  }

  void modifyPolyline(int min_idx) {
    final slicedPolyLine = polylineCoordinates.sublist(min_idx);

    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: slicedPolyLine,
      width: 3,
    );
    _polylines.clear();
    _polylines[id] = polyline;
    notifyListeners();
  }

  Map<PolylineId, Polyline> get polylines => _polylines;
}
