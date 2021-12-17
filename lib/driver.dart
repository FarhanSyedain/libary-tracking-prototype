import 'package:flutter/widgets.dart';
import 'package:web_socket_channel/io.dart';

class Driver {
  final String id;
  final _channel = IOWebSocketChannel.connect(
    Uri.parse('ws://192.168.43.155:8765'),
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

  getLocation(context) {
    return StreamBuilder(
        stream: _channel.stream,
        builder: (context, snapshot) {
          // if (snapshot.hasData) {
          //   print("Data: ");
          //   print(snapshot.data);

          //   return Text('${snapshot.data}');
          // } else {
          //   print("noData");
          //   return Text('');
          // }
          return Text(snapshot.hasData ? '${snapshot.data}' : '');
        });
  }

// Add it in the main code
  void dispose() {
    _channel.sink.close();
  }
}
