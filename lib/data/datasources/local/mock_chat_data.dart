class MockChatData {
  static const String therapistId = "Y9XZSOCevLX7X2BODA6NphLGjv42"; // Aldo Terapeuta
  static const String patientId = "s9NJS1RFUEN87HSrRtK4ZquoNSO2"; // Jose Aldo

  /// Static list of messages for demo
  static final List<Map<String, dynamic>> _messages = [
    {
      "id": "msg_001",
      "text": "¡Hola! ¿Cómo estás hoy?",
      "userId": therapistId,
      "userName": "Aldo Terapeuta",
      "timestamp": "2025-01-27T09:00:00.000Z",
    },
    {
      "id": "msg_002",
      "text": "¡Hola! Estoy bien, gracias 😊",
      "userId": patientId,
      "userName": "Jose Aldo",
      "timestamp": "2025-01-27T09:02:00.000Z",
    },
    {
      "id": "msg_003",
      "text": "Vi que practicaste mucho ayer. ¡Excelente trabajo!",
      "userId": therapistId,
      "userName": "Aldo Terapeuta",
      "timestamp": "2025-01-27T09:03:00.000Z",
    },
    {
      "id": "msg_004",
      "text": "Gracias! Me gustó mucho usar los pictogramas 🎨",
      "userId": patientId,
      "userName": "Jose Aldo",
      "timestamp": "2025-01-27T09:05:00.000Z",
    },
    {
      "id": "msg_005",
      "text": "¿Tienes alguna duda sobre los ejercicios?",
      "userId": therapistId,
      "userName": "Aldo Terapeuta",
      "timestamp": "2025-01-27T09:06:00.000Z",
    },
    {
      "id": "msg_006",
      "text": "Sí, ¿cómo puedo agregar más palabras?",
      "userId": patientId,
      "userName": "Jose Aldo",
      "timestamp": "2025-01-27T09:08:00.000Z",
    },
    {
      "id": "msg_007",
      "text": "Puedes ir a la sección de personalización y agregar tus propias imágenes. Te mostraré en la próxima sesión.",
      "userId": therapistId,
      "userName": "Aldo Terapeuta",
      "timestamp": "2025-01-27T09:10:00.000Z",
    },
    {
      "id": "msg_008",
      "text": "¡Perfecto! Muchas gracias 🙌",
      "userId": patientId,
      "userName": "Jose Aldo",
      "timestamp": "2025-01-27T09:12:00.000Z",
    },
    {
      "id": "msg_009",
      "text": "Quiero practicar más frases",
      "userId": patientId,
      "userName": "Jose Aldo",
      "timestamp": "2025-01-27T14:30:00.000Z",
    },
    {
      "id": "msg_010",
      "text": "¡Excelente! Intenta combinar palabras de diferentes categorías.",
      "userId": therapistId,
      "userName": "Aldo Terapeuta",
      "timestamp": "2025-01-27T14:35:00.000Z",
    },
    {
      "id": "msg_011",
      "text": "Ya lo intenté! Generé esta frase: 'Quiero jugar con mi hermano'",
      "userId": patientId,
      "userName": "Jose Aldo",
      "timestamp": "2025-01-27T15:00:00.000Z",
    },
    {
      "id": "msg_012",
      "text": "¡Muy bien! 🎉 Eso es exactamente lo que esperaba.",
      "userId": therapistId,
      "userName": "Aldo Terapeuta",
      "timestamp": "2025-01-27T15:05:00.000Z",
    },
    {
      "id": "msg_013",
      "text": "Nos vemos mañana en la sesión. ¡Hasta luego!",
      "userId": therapistId,
      "userName": "Aldo Terapeuta",
      "timestamp": "2025-01-27T18:00:00.000Z",
    },
    {
      "id": "msg_014",
      "text": "¡Hasta mañana! 👋",
      "userId": patientId,
      "userName": "Jose Aldo",
      "timestamp": "2025-01-27T18:02:00.000Z",
    },
  ];

  /// Get all messages
  static List<Map<String, dynamic>> getAllMessages() {
    return List.from(_messages);
  }

  /// Add a new message (in-memory only for demo)
  static void addMessage(Map<String, dynamic> message) {
    _messages.add(message);
  }

  /// Get partner info based on current user
  static Map<String, String> getPartnerInfo(String currentUserId) {
    if (currentUserId == patientId) {
      return {
        "id": therapistId,
        "name": "Aldo Terapeuta",
        "role": "Terapeuta",
      };
    } else {
      return {
        "id": patientId,
        "name": "Jose Aldo",
        "role": "Paciente",
      };
    }
  }
}