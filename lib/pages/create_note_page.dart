import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/openai_service.dart';

class NotesCreatorPage extends StatefulWidget {
  const NotesCreatorPage({super.key});

  @override
  State<NotesCreatorPage> createState() => _NotesCreatorPageState();
}

class _NotesCreatorPageState extends State<NotesCreatorPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final OpenAIService _openAI = OpenAIService();
  bool loadingAI = false;

  // ✅ Generate content using OpenAI
  Future<void> generateAIContent() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a title first')),
      );
      return;
    }

    setState(() => loadingAI = true);

    try {
      final text = await _openAI.generateNoteContent(
        "Write detailed notes about: $title",
      );
      _contentController.text = text;

      // ✅ Automatically save AI-generated notes to Supabase
      final supabase = Supabase.instance.client;
      await supabase.from('notes').insert({
        'title': title,
        'content': text,
        'is_ai_generated': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI-generated note "$title" saved!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI generation failed: $e')),
      );
    } finally {
      setState(() => loadingAI = false);
    }
  }

  // ✅ Save manually created note to Supabase
  Future<void> saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields')),
      );
      return;
    }

    try {
      final supabase = Supabase.instance.client;

      await supabase.from('notes').insert({
        'title': title,
        'content': content,
        'is_ai_generated': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note "$title" saved to Supabase!')),
      );

      _titleController.clear();
      _contentController.clear();
    } catch (e) {
      print("Supabase error: $e");  // <--- This will print the full error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving note: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Note"),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: saveNote),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
            ),
            const SizedBox(height: 16),
            loadingAI
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
              onPressed: generateAIContent,
              icon: const Icon(Icons.smart_toy),
              label: const Text('Generate with AI'),
            ),
          ],
        ),
      ),
    );
  }
}
