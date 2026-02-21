import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late DateTime date;

  @HiveField(4)
  late bool isExpense;

  
  @HiveField(5)
  late String category; 

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isExpense,
    required this.category, 
  });
}