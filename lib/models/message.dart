enum Role { user, assistant }

class Message {
  final Role role;
  final String content;
  final String? imageBase64;
  final bool isLoading;

  const Message({
    required this.role,
    required this.content,
    this.imageBase64,
    this.isLoading = false,
  });

  Map<String, dynamic> toApi() {
    if (imageBase64 != null) {
      return {
        'role': role.name,
        'content': [
          {'type': 'image_url', 'image_url': {'url': 'data:image/jpeg;base64,$imageBase64'}},
          {'type': 'text', 'text': content},
        ],
      };
    }
    return {'role': role.name, 'content': content};
  }
}
