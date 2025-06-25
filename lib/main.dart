import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tb_project/screens/login_screen.dart';
import 'package:tb_project/screens/home_screen.dart'; // Pastikan ini diimpor
import 'package:tb_project/providers/auth_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BolaSport News App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoggedIn) {
            // Jika sudah login, SELALU arahkan ke HomeScreen
            // Dan sekarang passing userRole ke HomeScreen
            return HomeScreen(userRole: authProvider.userRole);
          } else {
            return const LoginScreen(); // Jika belum login, tampilkan LoginScreen
          }
        },
      ),
    );
  }
}
