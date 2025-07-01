import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tb_project/screens/login_screen.dart';
import 'package:tb_project/screens/home_screen.dart';
import 'package:tb_project/providers/auth_provider.dart';
import 'package:tb_project/providers/bookmark_provider.dart'; // Import BookmarkProvider
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);

  runApp(
    MultiProvider( // Menggunakan MultiProvider karena ada lebih dari satu provider
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => BookmarkProvider()), // Tambah BookmarkProvider
      ],
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
            return HomeScreen(userRole: authProvider.userRole);
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
