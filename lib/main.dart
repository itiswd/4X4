import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/models/auth_state_model.dart';
import 'presentation/screens/auth_gate_screen.dart';

const supaBaseUrl = 'https://nopmggwpncgezhbiahhi.supabase.co';
const supaBaseUrlAnon =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5vcG1nZ3dwbmNnZXpoYmlhaGhpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE0OTY2MDUsImV4cCI6MjA3NzA3MjYwNX0.z2qgdfilN_Aj18Lyi4h4o-GDhySVQ2RfdnsVnrW-gsc';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supaBaseUrl, anonKey: supaBaseUrlAnon);

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthStateModel(),
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Educational App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AuthGateScreen(),
    );
  }
}
