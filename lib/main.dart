import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:project4/pages/flowanalyser.dart';
import 'package:project4/pages/log_in.dart';
import 'package:project4/pages/profile.dart';
import 'package:project4/pages/reward.dart';
import 'package:project4/pages/signup_page.dart';
import 'package:project4/pages/water%20usage.dart';
import './pages/education.dart';
import './pages/dashboard.dart';
import './controllers/auth_service.dart';
import './pages/home_page.dart';
import './pages/login_page.dart';
import 'firebase_options.dart';
import './pages/feedback.dart';
import './pages/log_in.dart';
import './pages/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Phone Auth Tutorial',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
          useMaterial3: true,
        ),
        home: Dashboard());
  }
}
