import 'package:flutter/material.dart';
import '../../../core/services/calculator_service.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/utils/date_picker_helper.dart';
import 'package:shamsi_date/shamsi_date.dart';

class PenaltyPage extends StatefulWidget {
  const PenaltyPage({super.key});

  @override
  State<PenaltyPage> createState() => _PenaltyPageState();
}

class _PenaltyPageState extends State<PenaltyPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _rateController = TextEditingController();

  Jalali? dueDate;
  Jalali? payDate;
  Map<String, dynamic> result = {};
  bool showResult = false;

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    if (dueDate == null || payDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً تاریخ‌ها را انتخاب کنید'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      result = CalculatorService.calculatePenalty(
        amount: double.parse(_amountController.text.replaceAll(',', '')),
        rate: double.parse(_rateController.text),
        dueDate: dueDate!.toDateTime(),
        payDate: payDate!.toDateTime(),
      );
      showResult = true;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isDueDate) async {
    Jalali? picked = await showPersianDatePickerDialog(context);
    if (picked != null) {
      setState(() {
        if (isDueDate) {
          dueDate = picked;
        } else {
          payDate = picked;
        }
      });
    }
  }

  Widget _buildInputWithPreview({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) => v!.isEmpty ? 'لطفاً این فیلد را پر کنید' : null,
        ),
        CurrencyPreview(controller: controller),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('محاسبه جریمه تاخیر')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInputWithPreview(
                controller: _amountController,
                label: 'مبلغ قسط (تومان)',
                hint: '5000000',
                icon: Icons.money,
              ),

              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(
                  labelText: 'نرخ جریمه سالیانه (%)',
                  prefixIcon: Icon(Icons.percent),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? 'لطفاً نرخ را وارد کنید' : null,
              ),

              const SizedBox(height: 10),

              GlassCard(
                color: Colors.orange,
                child: ListTile(
                  title: const Text('تاریخ سررسید'),
                  subtitle: Text(dueDate == null ? 'انتخاب نشده' : Formatter.toShamsi(dueDate!.toDateTime())),
                  trailing: const Icon(Icons.calendar_today, color: Colors.orange),
                  onTap: () => _selectDate(context, true),
                ),
              ),

              GlassCard(
                color: Colors.orange,
                child: ListTile(
                  title: const Text('تاریخ پرداخت'),
                  subtitle: Text(payDate == null ? 'انتخاب نشده' : Formatter.toShamsi(payDate!.toDateTime())),
                  trailing: const Icon(Icons.calendar_today, color: Colors.orange),
                  onTap: () => _selectDate(context, false),
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('محاسبه جریمه'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),

              if (showResult) ...[
                const SizedBox(height: 30),
                GlassCard(
                  color: Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'نتیجه محاسبه',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        _resultRow('تعداد روز تاخیر', result['days'].toDouble()),
                        _resultRow('مبلغ جریمه', result['penaltyAmount']),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            label.contains('روز') ? '${value.toInt()} روز' : '${Formatter.formatCurrency(value)} تومان',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
    );
  }
}