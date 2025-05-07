//import 'package:hive/hive.dart';

import 'package:hive/hive.dart';
part 'calculation.g.dart';

@HiveType(typeId: 0)
class Calculation extends HiveObject{
  @HiveField(0)
  final String expression;

  @HiveField(1)
  final String result;



  Calculation({required this.expression, required this.result});
}
