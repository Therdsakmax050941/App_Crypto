import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final WebSocketChannel channel;
  WebSocketService(String url) : channel = WebSocketChannel.connect(Uri.parse(url));

  Stream get stream => channel.stream;

  void sendMessage(String message) {
    channel.sink.add(message);
  }

  void closeConnection() {
    channel.sink.close();
  }
}