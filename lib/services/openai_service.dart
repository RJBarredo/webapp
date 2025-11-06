class OpenAIService {
  OpenAIService();

  // Placeholder for future AI integration.
  // Currently, it just returns a fixed message.
  Future<String> generateNoteContent(String prompt) async {
    // Simulate generating content without using OpenAI.
    await Future.delayed(const Duration(seconds: 1));
    return "AI content generation is currently disabled. You entered: $prompt";
  }
}
