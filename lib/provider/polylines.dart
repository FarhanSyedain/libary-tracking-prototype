import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracking_utils/provider/utils.dart';
import 'package:tracking_utils/services/consumer.dart';
import 'dart:ui' as ui;

class PolylinesProvider with ChangeNotifier {
  PolylinesProvider(this.apiKey, this.token, this.context) {
    //Class used to comunicate with backend
    _socketConnection = ConsumerMainConnection();
    //Inniaite sockets with backend
    _socketConnection.initConnection(token);
    //Listen to drivers location -- Since, map will only be rendered when driver is assigned.
    _socketConnection.getDriverLocation().listen(_socketEventHandler);

    setMarker();
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
  late BitmapDescriptor? customIcon;

  Future<void> setMarker() async {
    getBytesFromAsset('assets/schoolBus.png', 64).then((onValue) {
      customIcon = BitmapDescriptor.fromBytes(onValue);
    });
  }

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
    final correctedLocation = adjustLocation(
      [startLat, startLon],
      polylineCoordinates.map((e) {
        return [e.latitude, e.longitude];
      }).toList(),
    );

    Marker startMarker = Marker(
      markerId: MarkerId("start"),
      position: LatLng(destLat, destLon),
      icon: BitmapDescriptor.defaultMarker,
    );
    Marker actualMarker = Marker(
      markerId: MarkerId("actual"),
      position: LatLng(startLat, startLon),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    Marker endMarker = Marker(
      markerId: MarkerId("end"),
      position: LatLng(correctedLocation[0], correctedLocation[1]),
      // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    animate?.clear();
    animate?.addAll([startMarker, endMarker]);

    markers.clear();
    markers.addAll([startMarker, actualMarker, endMarker]);

    notifyListeners();

    if (polylineCoordinates.isEmpty) {
      createPolylines(startLat, startLon, destLat, destLon);
    } else {
      modifyPolyline();
    }

    double miny = (startLat <= destLat) ? startLat : destLat;
    double minx = (startLon <= destLon) ? startLon : destLon;
    double maxy = (startLat <= destLat) ? destLat : startLat;
    double maxx = (startLon <= destLon) ? destLon : startLon;

    return [minx, miny, maxx, maxy];
  }

  void modifyPolyline() {
    //Change polyline thingy
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Map<PolylineId, Polyline> get polylines => _polylines;
}
