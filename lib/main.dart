import 'package:boundpages_final/features/user_auth/presentation/pages/mainpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// Import Firebase Auth
import 'package:boundpages_final/features/user_auth/presentation/pages/profile_page.dart';
import 'package:boundpages_final/features/app/splash_screen/splash_screen.dart';
import 'package:boundpages_final/features/user_auth/presentation/pages/homepage.dart';
import 'package:boundpages_final/features/user_auth/presentation/pages/login_page.dart';
import 'package:boundpages_final/features/user_auth/presentation/pages/signup_page.dart';
import'package:boundpages_final/features/user_auth/presentation/pages/books_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCsHDQtI9DItQgSqwy45_y2xG9tDGxuER8",
        appId: "1:540215271818:web:8b22d4aee01acdce862873",
        messagingSenderId: "540215271818",
        projectId: "flutter-firebase-9c136",
        // Your web Firebase config options
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase',
      routes: {
        '/': (context) => const SplashScreen(
          // Here, you can decide whether to show the LoginPage or HomePage based on user authentication
          child: LoginPage(),
        ),
        '/login': (context) => const LoginPage(),
        '/signUp': (context) => const SignUpPage(),
        '/home': (context) =>  GenreSelectionScreen(),
        '/mainpage':(context) =>  MainPage(),
        '/profilepage':(context) => Profilepage(),

      },
    );
  }
}