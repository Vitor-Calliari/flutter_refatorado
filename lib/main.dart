import 'package:flutter/material.dart';
import 'core/dependencies.dart';
import 'app.dart';

// APP

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // dependências
  await setupDependencies();
  
  runApp(const PessoasApp());
}


