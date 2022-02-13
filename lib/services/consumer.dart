import 'dart:async';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracking_utils/constants.dart';
import 'package:web_socket_channel/io.dart';

class ConsumerMainConnection {
  late IOWebSocketChannel _channel;
  late IOWebSocketChannel _tempDriverChannel;
  late LatLng _currentDriverPosition;
  final StreamController _streamController = StreamController();
  final Uri _url = Uri.parse('ws://$backendURL/ws/customer/');

  void initConnection(token) async {
    //Innitilise connection with backend
    IOWebSocketChannel _channel = IOWebSocketChannel.connect(
      _url,
      headers: {
        'WS-AUTHORIZATION': 'Bearer $token',
      },
    );
    //?Listen to backend
    _channel.stream.listen(
      (event) {
        final eventDeoced = jsonDecode(event);
        onNewLocation(eventDeoced);
      },
    );
  }

  void onNewLocation(decodedData) {
    final latitude = double.parse(decodedData['lat'].toString());
    final longitude = double.parse(decodedData['lon'].toString());
    double endlatitude;
    double endlongitude;
    LatLng? _endLoc;

    // endlatitude = double.parse(decodedData['endlat'].toString());
    // endlongitude = double.parse(decodedData['endlon'].toString());
    endlatitude = 33.702;
    endlongitude = 75.26;
    _endLoc = LatLng(endlatitude, endlongitude);

    _currentDriverPosition = LatLng(latitude, longitude);
    _streamController.add([_currentDriverPosition, _endLoc]);
  }

  Stream getDriverLocation() {
    final stream = _streamController.stream;
    return stream;
  }

  void onPendingStatus(decodedData) {}

  void onDriverAssigned(decodedData) {}

  void onOrderComplete(decodedData) {
    //Only close if all orders are deliverd

    // _channel.sink.close();
  }

  LatLng get currentDriverPosition => _currentDriverPosition;
}
