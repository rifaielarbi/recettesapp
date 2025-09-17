import 'package:flutter/material.dart';
import 'utils/constants.dart';
import 'screens/liste_recettes.dart';

void main() {
  runApp(const RecettesApp());
}

class RecettesApp extends StatelessWidget {
  const RecettesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recettes Mondiales',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFDFDFD),
      ),
      home: const ListeRecettesScreen(),
    );
  }
}
