import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  // Subjects
  Future<List<Map<String, dynamic>>> fetchSubjects() async {
    final data = await client.from('subject').select();
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> addSubject(String name, String desc) async {
    await client.from('subject').insert({'name': name, 'description': desc});
  }

  // Notes
  Future<void> addNote(String title, String content, {bool isAI = false}) async {
    await client.from('notes').insert({
      'title': title,
      'content': content,
      'is_ai_generated': isAI,
    });
  }

  Future<List<Map<String, dynamic>>> fetchNotes() async {
    final data = await client
        .from('notes')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  // Flashcards
  Future<void> addFlashcard({
    required int subjectId,
    required String front,
    required String back,
    bool isAI = false,
  }) async {
    await client.from('flashcards').insert({
      'subject_id': subjectId,
      'front': front,
      'back': back,
      'is_ai_generated': isAI,
    });
  }

  Future<List<Map<String, dynamic>>> fetchFlashcards({int? subjectId}) async {
    var query = client.from('flashcards').select();
    if (subjectId != null) {
      query = query.eq('subject_id', subjectId);
    }
    final data = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }
}
