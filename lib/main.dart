import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'screens/welcome.dart';
import 'providers/bookmark_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");

  // Launch the app and inject BookmarkProvider into the widget tree
  // allowing any widget in the app to access and react to bookmark state changes.
  runApp(
    ChangeNotifierProvider(
      create: (_) => BookmarkProvider(), 
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      debugShowCheckedModeBanner: false,
      home: const Welcome(),
    );
  }
}