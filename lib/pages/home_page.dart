import 'package:flutter/material.dart';
import '../widgets/study_card.dart';
import '../widgets/responsive_grid.dart';
import '../widgets/section_title.dart';
import '../services/supabase_service.dart';
import 'create_note_page.dart';
import 'create_flashcard_page.dart';
import 'planner_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseService _supabase = SupabaseService();
  List<Map<String, dynamic>> subjects = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final data = await _supabase.fetchSubjects();
      setState(() {
        subjects = data;
        loading = false;
      });
    } catch (e) {
      debugPrint('Error loading subjects: $e');
      setState(() => loading = false);
    }
  }

  Future<void> _showAddSubjectDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Subject"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Subject Name"),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;

                try {
                  await _supabase.addSubject(
                    nameController.text.trim(),
                    descriptionController.text.trim(),
                  );

                  Navigator.pop(context);
                  _loadSubjects(); // refresh UI
                } catch (e) {
                  debugPrint("Error adding subject: $e");
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'tuon.',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 28,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        actions: const [
          Icon(Icons.person_outline, color: Colors.black),
          SizedBox(width: 12),
          Icon(Icons.menu, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 100 : 24,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search bar
            SizedBox(
              width: isWide ? 600 : double.infinity,
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 26),
                  hintText: 'Find study materials',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),
            const SectionTitle('Start Being a Model Student'),
            const SizedBox(height: 12),

            ResponsiveGrid(children: [
              StudyCard(
                'Create notes',
                'Manually or with the help of AI',
                icon: Icons.edit_note,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotesCreatorPage(),
                    ),
                  );
                },
              ),
              StudyCard(
                'Create flashcards',
                'Manually or with the help of AI',
                icon: Icons.style,
                onTap: () {
                  if (subjects.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please add a subject first.')),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FlashcardCreatorPage(
                        subjectId: subjects.first['id'],
                      ),
                    ),
                  );
                },
              ),
              StudyCard(
                'Plan your days ahead',
                'Schedule your subjects, study time, and exams',
                icon: Icons.calendar_month,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PlannerPage(),
                    ),
                  );
                },
              ),
              const StudyCard(
                'Focus study',
                'Avoid distractions with Pomodoro timer',
                icon: Icons.timer,
              ),
              const StudyCard(
                'Upload a file',
                'Get notes or flashcards automatically',
                icon: Icons.upload_file,
              ),
              const StudyCard(
                'Record lecture',
                'Turn your voice into notes or flashcards',
                icon: Icons.mic,
              ),
            ]),

            const SizedBox(height: 36),
            const SectionTitle('Subjects'),
            const SizedBox(height: 12),

            ResponsiveGrid(
              children: subjects.isEmpty
                  ? [const Center(child: Text('No subjects yet.'))]
                  : subjects
                  .map(
                    (s) => StudyCard(
                  s['name'],
                  s['description'] ?? '',
                  icon: Icons.book,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlashcardCreatorPage(
                          subjectId: s['id'],
                        ),
                      ),
                    );
                  },
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),

      // ➕ Add Subject Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSubjectDialog,
        label: const Text("Add Subject"),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
