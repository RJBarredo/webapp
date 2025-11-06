import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class FlashcardCreatorPage extends StatefulWidget {
  final int subjectId; // Required to link flashcard to a subject

  const FlashcardCreatorPage({super.key, required this.subjectId});

  @override
  State<FlashcardCreatorPage> createState() => _FlashcardCreatorPageState();
}

class _FlashcardCreatorPageState extends State<FlashcardCreatorPage> {
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();
  final SupabaseService _supabase = SupabaseService();
  bool loading = false;

  void saveFlashcard() async {
    final front = _frontController.text.trim();
    final back = _backController.text.trim();

    if (front.isEmpty || back.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await _supabase.addFlashcard(
        subjectId: widget.subjectId,
        front: front,
        back: back,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flashcard saved!')),
      );

      _frontController.clear();
      _backController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving flashcard: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Flashcard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _frontController,
              decoration: const InputDecoration(labelText: 'Front (Question)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _backController,
              decoration: const InputDecoration(labelText: 'Back (Answer)'),
            ),
            const SizedBox(height: 24),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: saveFlashcard,
              child: const Text('Save Flashcard'),
            ),
          ],
        ),
      ),
    );
  }
}
