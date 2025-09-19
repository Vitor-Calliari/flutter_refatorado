import 'package:flutter/material.dart';
import 'pages/pessoas_page.dart';
import 'package:exemplo/core/dependencies.dart';
import 'package:exemplo/repositories/i_pessoas_repository.dart';

class PessoasApp extends StatelessWidget {
  const PessoasApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Persistência Local (SQLite)',
      theme: ThemeData(useMaterial3: true),
      home: PessoasPage(repo: getIt<IPessoasRepository>()),
      debugShowCheckedModeBanner: false,
    );
  }
}
