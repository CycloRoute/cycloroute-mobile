import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 800;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 160 << 20;
  await dotenv.load(fileName: '.env');
  runApp(const CycloRouteApp());
}
