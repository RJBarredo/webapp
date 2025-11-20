import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants/supabase_keys.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const TuonApp());
}

class TuonApp extends StatelessWidget {
  const TuonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuon.',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
      ),

      home: const HomePage(),
    );
  }
}
