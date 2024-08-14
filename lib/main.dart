import 'package:apiapp/screens/loginpage.dart';
import 'package:apiapp/screens/mainscreen.dart';
import 'package:apiapp/screens/signuppage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue, scaffoldBackgroundColor: Colors.white),
      initialRoute: '/main',
      routes: {
        '/login': (context) => LoginPage(),
        '/main': (context) => MainScreen(),
        '/signup': (context) => SignupPage(),
      },
    );
  }
}
