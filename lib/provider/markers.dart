// import 'package:flutter/cupertino.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class MapProvider with ChangeNotifier {
//   //?When will be the map showen
//   //* First when the user orders something, Draw maybe polyline between restraunt and user.
//   //* When driver is assigned and order is picked phir to pata hi hai

//   final Position restrauntLocation;
//   final Position destination;

//   MapProvider({
//     required this.restrauntLocation,
//     required this.destination,
//   });

//   late Marker startMarker;
//   late Marker endMarker;
//   Set markers = {};

//   draw_innital_markers() {
//     double restrauntLat = restrauntLocation.latitude;
//     double restruntLong = restrauntLocation.longitude;
//     double consumerLat = destination.latitude;
//     double consumerLong = destination.longitude;

//     draw_markers(
//       restrauntLat,
//       restruntLong,
//       consumerLat,
//       consumerLong,
//       innitial: true,
//     );
//   }

//   draw_markers(startLat, startLon, destLat, destLon, {innitial = false}) {
//     Marker startMarker = Marker(
//       markerId: MarkerId("sfdgh"),
//       position: LatLng(startLat, startLon),
//       icon: BitmapDescriptor.defaultMarker,
//     );

//     Marker endMarker = Marker(
//       markerId: MarkerId("sfgh"),
//       position: LatLng(destLat, destLon),
//       icon: BitmapDescriptor.defaultMarker,
//     );

//     markers.add(startMarker);
//     markers.add(endMarker);

//     notifyListeners();

//     double miny = (startLat <= destLat) ? startLat : destLat;
//     double minx = (startLon <= destLon) ? startLon : destLon;
//     double maxy = (startLat <= destLat) ? destLat : startLat;
//     double maxx = (startLon <= destLon) ? destLon : startLon;

//     mapController.animateCamera(
//       CameraUpdate.newLatLngBounds(
//         LatLngBounds(
//           northeast: LatLng(maxy, maxx),
//           southwest: LatLng(miny, minx),
//         ),
//         100.0,
//       ),
//     );

//       Provider.of<PolylinesProvider>(
//         context,
//         listen: false,
//       ).createPolylines(startLat, startLon, destLat, destLon);
//     }
//   }
// }
