import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'controlers/hive.dart';
import 'models/calculation.dart';
import 'views/calculator_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  /*Hive.registerAdapter(CalculationAdapter());
  if (!Hive.isBoxOpen('history')) {
    await Hive.openBox<CalculationAdapter>('history');
  }*/

  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);

  Hive.registerAdapter(CalculationAdapter());

  if (!Hive.isBoxOpen('history')) {
    await Hive.openBox<Calculation>('history'); // Abre a box do tipo Calculation
  }

  runApp(const SmartCalcApp());
}

class SmartCalcApp extends StatelessWidget {
  const SmartCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartCalc',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const CalculatorView(),
    );
  }
}
