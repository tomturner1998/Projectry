import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_finder/project_finder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProjectFinder());
}
