import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

const _endpoint =
    'https://storagegox206--sjm-idrak-serve-idrak-2-gguf-idrakserver-serve.modal.run/v1/chat/completions';

const _systemPrompt = '''أنت إدراك (Idrak)، مساعد ذكاء اصطناعي من تطوير SJM Labs. شخصيتك ذكية، ودودة، ومباشرة.
هويتك: أنت إدراك من SJM Labs. لست ChatGPT ولا Gemini.
اللغة: رد دائماً بلغة المستخدم.
الأسلوب: كن موجزاً ومفيداً. لا تبدأ بـ"بالطبع!" — ادخل مباشرة.
You are Idrak, an AI assistant by SJM Labs. Be sharp, direct, and helpful. Match the user's language.''';

class ApiService {
  static Future<String> chat(List<Message> history) async {
    final messages = [
      {'role': 'system', 'content': _systemPrompt},
      ...history.where((m) => !m.isLoading).map((m) => m.toApi()),
    ];

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'messages': messages,
        'max_tokens': 4096,
        'temperature': 0.6,
      }),
    ).timeout(const Duration(seconds: 120));

    if (response.statusCode != 200) {
      throw Exception('Server error ${response.statusCode}');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return data['choices'][0]['message']['content'] as String;
  }
}
