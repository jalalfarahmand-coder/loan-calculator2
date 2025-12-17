import 'dart:math';
import '../models/loan_model.dart';

class CalculatorService {
  static Map<String, dynamic> calculateLoan({
    required double principal,
    required double rate,
    required int months,
    int graceDays = 0,
    String rateType = 'annual',
    String installmentType = 'monthly',
  }) {
    double monthlyRate = rateType == 'annual' ? rate / 12 / 100 : rate / 100;

    double amount = principal;
    if (graceDays > 0) {
      amount += principal * (monthlyRate / 30) * graceDays;
    }

    int installmentCount = months;
    double installmentRate = monthlyRate;

    switch (installmentType) {
      case 'bimonthly':
        installmentCount = (months / 2).ceil();
        installmentRate = monthlyRate * 2;
        break;
      case 'quarterly':
        installmentCount = (months / 3).ceil();
        installmentRate = monthlyRate * 3;
        break;
      case 'yearly':
        installmentCount = (months / 12).ceil();
        installmentRate = monthlyRate * 12;
        break;
    }

    double installmentAmount;
    if (installmentRate == 0) {
      installmentAmount = amount / installmentCount;
    } else {
      installmentAmount = amount *
          (installmentRate * pow(1 + installmentRate, installmentCount)) /
          (pow(1 + installmentRate, installmentCount) - 1);
    }

    List<double> installments = List.generate(installmentCount, (_) => installmentAmount);

    return {
      'installments': installments,
      'installmentAmount': installmentAmount,
      'totalAmount': installmentAmount * installmentCount,
      'totalInterest': (installmentAmount * installmentCount) - principal,
      'principalWithGrace': amount,
    };
  }

  static Map<String, dynamic> calculateDeposit({
    required double principal,
    required double rate,
    required int period,
    String periodType = 'month',
    String rateType = 'annual',
    bool isCompound = false,
  }) {
    double monthlyRate = rateType == 'annual' ? rate / 12 / 100 : rate / 100;
    int months = periodType == 'day' ? (period / 30).ceil() : period;

    double totalAmount;
    double interest;

    if (isCompound) {
      totalAmount = principal * pow(1 + monthlyRate, months);
      interest = totalAmount - principal;
    } else {
      interest = principal * monthlyRate * months;
      totalAmount = principal + interest;
    }

    return {
      'principal': principal,
      'interest': interest,
      'totalAmount': totalAmount,
      'months': months,
    };
  }

  static Map<String, dynamic> calculatePenalty({
    required double amount,
    required double rate,
    required DateTime dueDate,
    required DateTime payDate,
  }) {
    int days = payDate.difference(dueDate).inDays;
    if (days <= 0) {
      return {'penaltyAmount': 0.0, 'days': 0};
    }

    double penaltyAmount = amount * (rate / 100 / 365) * days;
    return {'penaltyAmount': penaltyAmount, 'days': days};
  }
}