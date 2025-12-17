import 'package:flutter/material.dart';
import '../../../core/models/loan_model.dart';
import '../../../core/utils/formatter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تاریخچه محاسبات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              Hive.box<LoanModel>('loans').clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<LoanModel>('loans').listenable(),
        builder: (context, Box<LoanModel> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('هنوز محاسبه‌ای انجام نشده'));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final loan = box.getAt(index)!;
              return Card(
                child: ListTile(
                  title: Text(loan.title),
                  subtitle: Text('${loan.months} قسط • ${Formatter.toShamsi(loan.createdAt)}'),
                  trailing: Text(
                    '${Formatter.formatCurrency(loan.installments.first)} تومان',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(loan.title),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('مبلغ وام: ${Formatter.formatCurrency(loan.principal)}'),
                              Text('مبلغ هر قسط: ${Formatter.formatCurrency(loan.installments.first)}'),
                              Text('تعداد اقساط: ${loan.months}'),
                              Text('روزهای تنفس: ${loan.graceDays}'),
                              Text('تاریخ: ${Formatter.toShamsi(loan.createdAt)}'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('بستن'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}