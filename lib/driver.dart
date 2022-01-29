import 'package:flutter/widgets.dart';
import 'package:web_socket_channel/io.dart';

class Driver {
  final String id;
  final _channel = IOWebSocketChannel.connect(
    Uri.parse('wss://trackingsocketserver.herokuapp.com'),
  );
  Driver({
    required this.id,
  }) {
    _channel.sink.add(
        '{"id": "murtaza", "name": "Murtaza Nazir", "designation": "customer", "opp_id": "garbage"}');
  }

  sendLocation(loc) {
    _channel.sink.add(loc);
  }


// Add it in the main code
  void dispose() {
    _channel.sink.close();
  }
}
