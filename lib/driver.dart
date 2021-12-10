import 'package:flutter/widgets.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Driver {
  final String id;
  final _channel = WebSocketChannel.connect(
    Uri.parse('wss://trackingsocketserver.herokuapp.com/'),
  );
  Driver({
    required this.id,
  });

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
