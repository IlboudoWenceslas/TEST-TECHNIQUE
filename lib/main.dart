import 'package:flutter/material.dart';
import 'screen/event_list_screen.dart';
import 'screen/event_detail_screen.dart';
import 'screen/auth_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Événements',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const EventListScreen(),
        '/auth': (context) => const AuthScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/events') {
          final id = settings.arguments as int;
          return MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: id));
        }
        return null;
      },
    );
  }
}