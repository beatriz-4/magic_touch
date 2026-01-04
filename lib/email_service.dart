import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  static Future<void> sendEmail({
    required String recipient,
    required String subject,
    required String message,
  }) async {
    final url = Uri.parse(
      'https://us-central1-magic-touch-a71be.cloudfunctions.net/sendNotificationEmail',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'recipient': recipient,
        'subject': subject,
        'message': message,
      }),
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}
