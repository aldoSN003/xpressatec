import 'package:get/get.dart';
import 'package:xpressatec/core/config/routes.dart';
import 'package:xpressatec/data/datasources/local/mock_chat_data.dart';
import 'package:xpressatec/presentation/features/auth/controllers/auth_controller.dart';
import 'package:xpressatec/presentation/features/home/controllers/navigation_controller.dart';

class ChatMessage {
  final String id;
  final String text;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.text,
    required this.userId,
    required this.userName,
    required this.timestamp,
    required this.isMe,
  });
}

class ChatController extends GetxController {
  // Observable state
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentUserId = ''.obs;
  final RxString currentUserName = ''.obs;
  final RxString otherUserName = ''.obs;

  late final AuthController _authController;

  @override
  void onInit() {
    super.onInit();
    _authController = Get.find<AuthController>();

    if (!_authController.canAccessChat) {
      Future.delayed(Duration.zero, () {
        Get.snackbar(
          'Acceso restringido',
          'El chat no está disponible para tu rol actual.',
          snackPosition: SnackPosition.BOTTOM,
        );

        if (Get.currentRoute == Routes.home) {
          if (Get.isRegistered<NavigationController>()) {
            Get.find<NavigationController>().changePage(0);
          }
        } else {
          if (Get.key.currentState?.canPop() ?? false) {
            Get.back();
          } else {
            Get.offAllNamed(Routes.home);
          }
        }
      });
      return;
    }

    _initializeChat();
  }

  /// Initialize chat with mock data
  void _initializeChat() {
    try {
      isLoading.value = true;

      // Get current user from AuthController
      final user = _authController.currentUser.value;

      if (user == null) {
        print('❌ No user found');
        return;
      }

      currentUserId.value = user.uuid;
      currentUserName.value = user.nombre;

      // Get partner info
      final partnerInfo = MockChatData.getPartnerInfo(user.uuid);
      otherUserName.value = partnerInfo['name']!;

      // Load mock messages
      _loadMessages();
    } catch (e) {
      print('❌ Error initializing chat: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load messages from mock data
  void _loadMessages() {
    final mockMessages = MockChatData.getAllMessages();

    messages.value = mockMessages.map((msgData) {
      final isMe = msgData['userId'] == currentUserId.value;

      return ChatMessage(
        id: msgData['id'],
        text: msgData['text'],
        userId: msgData['userId'],
        userName: msgData['userName'],
        timestamp: DateTime.parse(msgData['timestamp']),
        isMe: isMe,
      );
    }).toList();

    // Sort by date (oldest first)
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    print('✅ Loaded ${messages.length} messages');
  }

  /// Send a new message
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      userId: currentUserId.value,
      userName: currentUserName.value,
      timestamp: DateTime.now(),
      isMe: true,
    );

    // Add to mock data
    MockChatData.addMessage({
      "id": newMessage.id,
      "text": newMessage.text,
      "userId": newMessage.userId,
      "userName": newMessage.userName,
      "timestamp": newMessage.timestamp.toIso8601String(),
    });

    // Add to UI
    messages.add(newMessage);

    print('📤 Message sent: ${newMessage.text}');

    // Simulate therapist auto-reply (for demo)
    if (currentUserId.value == MockChatData.patientId) {
      _simulateTherapistReply();
    }
  }

  /// Simulate therapist auto-reply
  void _simulateTherapistReply() {
    Future.delayed(const Duration(seconds: 2), () {
      final replies = [
        "Gracias por tu mensaje. Te responderé pronto.",
        "Entendido. Sigue practicando.",
        "¡Muy bien! Continúa así.",
        "Excelente progreso.",
        "Me alegra saber de ti.",
      ];

      final randomReply = replies[DateTime.now().second % replies.length];
      final partnerInfo = MockChatData.getPartnerInfo(currentUserId.value);

      final autoMessage = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: randomReply,
        userId: partnerInfo['id']!,
        userName: partnerInfo['name']!,
        timestamp: DateTime.now(),
        isMe: false,
      );

      MockChatData.addMessage({
        "id": autoMessage.id,
        "text": autoMessage.text,
        "userId": autoMessage.userId,
        "userName": autoMessage.userName,
        "timestamp": autoMessage.timestamp.toIso8601String(),
      });

      messages.add(autoMessage);
    });
  }
}