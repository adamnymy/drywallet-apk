import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String description;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final bool isExpense;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String category;

  @HiveField(5)
  String? notes;

  Transaction({
    required this.description,
    required this.amount,
    required this.isExpense,
    required this.date,
    required this.category,
    this.notes,
  });
}
