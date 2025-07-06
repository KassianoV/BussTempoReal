import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/driver_screen.dart';
import 'screens/route_select_screen.dart';
import 'screens/student_map_screen.dart';
import 'auth_provider.dart'; // Um provedor de estado para gerenciar o tipo de usuário

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: UffBusTrackerApp(),
    ),
  );
}

class UffBusTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UFF Bus Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Sans',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // A tela inicial é sempre o Login
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/driver': (context) => DriverScreen(),
        '/select-route': (context) => RouteSelectScreen(),
        '/student-map': (context) => StudentMapScreen(),
      },
    );
  }
}
