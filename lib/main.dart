import 'package:flutter/material.dart';
import 'package:radhe/ceramic_splash_screen.dart';
import 'package:radhe/home_screen.dart';
import 'package:radhe/login_screen.dart';
import 'package:radhe/registration_screen.dart';
import 'package:radhe/screens/customer_list_status_screen.dart';

import 'customer_form_screen.dart';
import 'forgot_password_screen.dart';
import 'screens/customer_list_screen.dart';

void main() async {
  // phone=9876543210&password=12345678
  WidgetsFlutterBinding.ensureInitialized();

  // try {
  //   await Firebase.initializeApp(
  //     options: const FirebaseOptions(
  //       apiKey: "AIzaSyBYPDsgas0D_Fvsbh7pkwrcMlY4QYm1-4c",
  //       appId: "1:95920999008:android:d2515b60c0410eb4c1d105",
  //       messagingSenderId: "95920999008",
  //       projectId: "radhe-fa592",
  //       storageBucket: "radhe-fa592.appspot.com",
  //     ),
  //   );
  //   debugPrint('Firebase initialized successfully');
  // } catch (e) {
  //   debugPrint('Firebase initialization error: $e');
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radhe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF122B84),
          primary: const Color(0xFF122B84),
          secondary: const Color(0xFF1E3A8A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF122B84),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF122B84),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF122B84),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const CeramicSplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
        '/customer-form': (context) => const CustomerFormScreen(),
        '/customer-list': (context) => const CustomerListScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/customer-list-status': (context) => const CustomerListStatusScreen(),
      },
    );
  }
}
