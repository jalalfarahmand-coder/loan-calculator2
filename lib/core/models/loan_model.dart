import 'package:hive/hive.dart';

part 'loan_model.g.dart';

@HiveType(typeId: 0)
class LoanModel {
  @HiveField(0)
  final double principal;

  @HiveField(1)
  final double monthlyRate;

  @HiveField(2)
  final int months;

  @HiveField(3)
  final int graceDays;

  @HiveField(4)
  final List<double> installments;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final String installmentType;

  @HiveField(7)
  final String title;

  LoanModel({
    required this.principal,
    required this.monthlyRate,
    required this.months,
    required this.graceDays,
    required this.installments,
    required this.createdAt,
    required this.installmentType,
    this.title = 'وام',
  });
}