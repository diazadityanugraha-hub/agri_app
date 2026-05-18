import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'screens/home_page.dart';
import 'screens/login_page.dart';

// --- DATA GLOBAL ---
Map<String, dynamic>? dataPantauanAdmin;
String userLogin = "";
String? savedName;
String? savedLahan;

void main() async {
  // Pastikan ini ada dan tidak merah
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyADtnNA0BH-vEm4BKWC8bzx6NEowA9C-lQ",
        appId: "1:122372410134:android:b23319275477f5e98e1e37",
        messagingSenderId: "122372410134",
        projectId: "agripedia-cloud",
        storageBucket: "agripedia-cloud.firebasestorage.app",
      ),
    );
    print("Firebase Berhasil! 🚀");
  } catch (e) {
    print("Firebase Error tapi lanjut: $e");
  }

  runApp(const AgriPediaApp());
}

class AgriPediaApp extends StatelessWidget {
  const AgriPediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgriPedia',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}