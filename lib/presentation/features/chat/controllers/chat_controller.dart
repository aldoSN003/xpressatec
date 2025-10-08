
import 'package:get/get.dart';
class ChatController extends GetxController {
  final messages = <dynamic>[].obs;
  final isConnected = false.obs;

  void connectWebSocket() {
    // TODO: Implementar conexión WebSocket con Flask
  }

  void sendMessage(String message) {
    // TODO: Enviar mensaje por WebSocket
  }
}