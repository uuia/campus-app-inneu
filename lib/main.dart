import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inneu/pages/card/cardPage.dart';
import 'package:inneu/pages/examPage.dart';
import 'package:inneu/pages/feedbackPage.dart';
import 'package:inneu/pages/gpaCalculatorPage.dart';
import 'package:inneu/pages/gradePage.dart';
import 'package:inneu/pages/smartNEU.dart';
import 'package:inneu/splash.dart';

import 'home.dart';


void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '在东大',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        "/grade": (context) => GradePage(),
        "/card": (context) => CardPage(),
        "/gpa-calculator": (context) => GpaCalculatorPage(),
        "/exam": (context) => ExamPage(),
        "/feedback": (context) => FeedBackPage(),
        "/smart-neu": (context) => SmartNEU(),
      },
      home: SplashScreen(),
    );
  }
}


