import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;


  Future<List<Map<String, dynamic>>> fetchSubjects() async {
    final data = await client.from('subject').select();
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> addSubject(String name, String desc) async {
    try {
      final data = await client
          .from('subject')
          .insert({
        'name': name,
        'description': desc,
      })
          .select();

      return Map<String, dynamic>.from(data.first);
    } catch (e) {
      throw Exception("Failed to add subject: $e");
    }
  }



  Future<void> addNote(String title, String content, {bool isAI = false}) async {
    try {
      await client.from('notes').insert({
        'title': title,
        'content': content,
        'is_ai_generated': isAI,
      });
    } catch (e) {
      throw Exception("Failed to add note: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchNotes() async {
    final data = await client
        .from('notes')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

 //Flashcard Add
  Future<void> addFlashcard({
    required int subjectId,
    required String front,
    required String back,
    bool isAI = false,
  }) async {
    try {
      await client.from('flashcards').insert({
        'subject_id': subjectId,
        'front': front,
        'back': back,
        'is_ai_generated': isAI,
      });
    } catch (e) {
      throw Exception("Failed to add flashcard: $e");
    }
  }

  //Flashcard Retrieve
  Future<List<Map<String, dynamic>>> fetchFlashcards({int? subjectId}) async {
    var query = client.from('flashcards').select();

    if (subjectId != null) {
      query = query.eq('subject_id', subjectId);
    }

    final data = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

//Flashcard Delete and Update

  Future<void> updateFlashcard(int id, String front, String back) async {
    try {
      await client.from('flashcards').update({
        'front': front,
        'back': back,
      }).eq('id', id);
    } catch (e) {
      throw Exception("Failed to update flashcard: $e");
    }
  }

  Future<void> deleteFlashcard(int id) async {
    try {
      await client.from('flashcards').delete().eq('id', id);
    } catch (e) {
      throw Exception("Failed to delete flashcard: $e");
    }
  }
}
