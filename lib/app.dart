import 'package:flutter/material.dart';
import 'pages/pessoas_page.dart';

class PessoasApp extends StatelessWidget {
  const PessoasApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Persistência Local (SQLite)',
      theme: ThemeData(useMaterial3: true),
      home: const PessoasPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
