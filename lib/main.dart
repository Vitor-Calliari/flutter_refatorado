import 'package:flutter/material.dart';
import 'core/database_factory.dart';
import 'app.dart';

// APP

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa factory
  DatabaseFactoryProvider.instance;
  
  runApp(const PessoasApp());
}


