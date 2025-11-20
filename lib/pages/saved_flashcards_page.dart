import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class SavedFlashcardsPage extends StatefulWidget {
  const SavedFlashcardsPage({super.key});

  @override
  State<SavedFlashcardsPage> createState() => _SavedFlashcardsPageState();
}

class _SavedFlashcardsPageState extends State<SavedFlashcardsPage> {
  final SupabaseService _supabase = SupabaseService();

  List<Map<String, dynamic>> flashcards = [];
  List<Map<String, dynamic>> subjects = [];

  bool loading = true;
  int? selectedSubjectId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final sub = await _supabase.fetchSubjects();
      subjects = sub;

      await _loadFlashcards();
    } catch (e) {
      debugPrint("Error loading: $e");
    }
  }

  Future<void> _loadFlashcards() async {
    setState(() => loading = true);

    try {
      final data = await _supabase.fetchFlashcards(
        subjectId: selectedSubjectId,
      );

      setState(() {
        flashcards = data;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error loading flashcards: $e");
      setState(() => loading = false);
    }
  }

  // =========================
  // Flashcard Flip Widget
  // =========================
  Widget buildFlippableCard(Map<String, dynamic> card) {
    return GestureDetector(
      onTap: () {
        setState(() {
          card['flipped'] = !(card['flipped'] ?? false);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (card['flipped'] ?? false) ? card['back'] : card['front'],
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => editFlashcardDialog(card),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteFlashcard(card['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // Delete Flashcard
  // =========================
  void deleteFlashcard(int id) async {
    await _supabase.deleteFlashcard(id);
    _loadFlashcards();
  }

  // =========================
  // Edit Flashcard Dialog
  // =========================
  void editFlashcardDialog(Map<String, dynamic> card) {
    final frontCtrl = TextEditingController(text: card['front']);
    final backCtrl = TextEditingController(text: card['back']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Flashcard"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: frontCtrl, decoration: const InputDecoration(labelText: "Front")),
            TextField(controller: backCtrl, decoration: const InputDecoration(labelText: "Back")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _supabase.updateFlashcard(
                card['id'],
                frontCtrl.text.trim(),
                backCtrl.text.trim(),
              );
              Navigator.pop(context);
              _loadFlashcards();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // =========================
  // BUILD UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Flashcards"),
        actions: [
          // SUBJECT FILTER DROPDOWN
          DropdownButton<int?>(
            value: selectedSubjectId,
            dropdownColor: Colors.white,
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text("All Subjects"),
              ),
              ...subjects.map((s) {
                return DropdownMenuItem(
                  value: s['id'],
                  child: Text(s['name']),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                selectedSubjectId = value;
              });
              _loadFlashcards();
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : flashcards.isEmpty
          ? const Center(child: Text("No flashcards found."))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: flashcards.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => buildFlippableCard(flashcards[i]),
      ),
    );
  }
}
