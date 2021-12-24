import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web_socket_channel/io.dart';

class ConsumerMainConnection{
  //App start . Get order,
  //? When to innitilise connection
  //* When either of the conditions are satisfied ig
  //* Order is in the state of : Pending or Assigned

  //! Things to note :
  /*
  When app starts, fetch basic info from the backend.
  Order Details which will include status of order, if availible.
  In case of no order, don't establish a socket. Otherwise do extablish one
  To get changaes in status of order and driver location
  */

  late IOWebSocketChannel _channel;
  late IOWebSocketChannel _tempDriverChannel;
  late LatLng _currentDriverPosition;
  final StreamController<LatLng?> _streamController = StreamController();
  // final Uri _url = Uri.parse('wss://trackingsocketserver.herokuapp.com');
  final Uri _url = Uri.parse('ws://192.168.209.61:8000');

  void intiConnection() {
    //Innitilise connection with backend
    IOWebSocketChannel _channel = IOWebSocketChannel.connect(_url);

    //? Send basic info to backend so that it can indentify us
    //Todo : Replace id with token. Implement authentication later
    _channel.sink.add(
      '{"id": "murtaza", "name": "Murtaza Nazir", "designation": "customer", "opp_id": "garbage"}',
    );

    // Listen to differnt events
    _channel.stream.listen(
      (event) {
        final eventDeoced = jsonDecode(event);
        final status = eventDeoced['orderStatus'];

        if (status == 'PENDING') {
          onPendingStatus(eventDeoced);
        } else if (status == 'ASSIGNED') {
          onDriverAssigned(eventDeoced);
        } else if (status == 'DELIVERED') {
          onOrderComplete(eventDeoced);
        } else if (status == 'DELIVERING') {
          onNewLocation(eventDeoced);
        }
      },
    );
  }

  void initDriverChannel() async {
    _tempDriverChannel = IOWebSocketChannel.connect(_url);
    _tempDriverChannel.sink.add({
      '{"id": "murtaza", "name": "Murtaza Nazir", "designation": "driver", "opp_id": "murtaza"}',
    });
    while (true) {
      await Future.delayed(Duration(milliseconds: 500));
      final latitude = 33.44;
      final longitue = 55.5;
      final provider = sendLocation(LatLng(latitude, longitue));
    }
  }

  void sendLocation(loc) {
    _tempDriverChannel.sink.add(loc);
    print(loc);
  }

  void onNewLocation(decodedData) {
    final latitude = double.parse(decodedData['latitude']);
    final longitude = double.parse(decodedData['longitude']);

    _currentDriverPosition = LatLng(latitude, longitude);
    _streamController.add(_currentDriverPosition);
  }

  Stream<LatLng?> getDriverLocation() {
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
