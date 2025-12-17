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
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('حذف تاریخچه'),
                  content: const Text('آیا مطمئن هستید؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('خیر'),
                    ),
                    TextButton(
                      onPressed: () {
                        Hive.box<LoanModel>('loans').clear();
                        Navigator.pop(context);
                        setState(() {});
                      },
                      child: const Text('بله', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<LoanModel>('loans').listenable(),
        builder: (context, Box<LoanModel> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('هنوز محاسبه‌ای انجام نشده', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final loan = box.getAt(index)!;
              return GlassCard(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    loan.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${loan.months} قسط • ${Formatter.toShamsi(loan.createdAt)}'),
                      Text(
                        'نوع: ${getInstallmentTypeLabel(loan.installmentType)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '${Formatter.formatCurrency(loan.installments.first)} تومان',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
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
                              _detailRow('مبلغ وام', '${Formatter.formatCurrency(loan.principal)} تومان'),
                              _detailRow('مبلغ هر قسط', '${Formatter.formatCurrency(loan.installments.first)} تومان'),
                              _detailRow('تعداد اقساط', '${loan.months} قسط'),
                              _detailRow('روزهای تنفس', '${loan.graceDays} روز'),
                              _detailRow('نرخ', '${loan.monthlyRate * 100}% ماهانه'),
                              _detailRow('تاریخ', Formatter.toShamsi(loan.createdAt)),
                              const Divider(),
                              _detailRow('کل بازپرداخت', '${Formatter.formatCurrency(loan.installments.first * loan.installments.length)} تومان'),
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String getInstallmentTypeLabel(String type) {
    switch (type) {
      case 'bimonthly': return 'دو ماهه';
      case 'quarterly': return 'سه ماهه';
      case 'yearly': return 'سالانه';
      default: return 'ماهانه';
    }
  }
}