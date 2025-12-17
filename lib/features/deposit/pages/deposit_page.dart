import 'package:flutter/material.dart';
import '../../../core/services/calculator_service.dart';
import '../../../core/utils/formatter.dart';

class DepositPage extends StatefulWidget {
  const DepositPage({super.key});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _periodController = TextEditingController();

  String periodType = 'month';
  String rateType = 'annual';
  bool isCompound = false;
  Map<String, dynamic> result = {};
  bool showResult = false;

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      result = CalculatorService.calculateDeposit(
        principal: double.parse(_principalController.text.replaceAll(',', '')),
        rate: double.parse(_rateController.text),
        period: int.parse(_periodController.text),
        periodType: periodType,
        rateType: rateType,
        isCompound: isCompound,
      );
      showResult = true;
    });
  }

  Widget _buildInputWithPreview({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
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
          keyboardType: keyboardType ?? const TextInputType.numberWithOptions(decimal: true),
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
      appBar: AppBar(title: const Text('محاسبه سود سپرده')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInputWithPreview(
                controller: _principalController,
                label: 'مبلغ سپرده (تومان)',
                hint: '100000000',
                icon: Icons.savings,
              ),

              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(
                  labelText: 'نرخ سود (%)',
                  prefixIcon: Icon(Icons.percent),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? 'لطفاً نرخ را وارد کنید' : null,
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('سالیانه'),
                      value: 'annual',
                      groupValue: rateType,
                      onChanged: (v) => setState(() => rateType = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('ماهیانه'),
                      value: 'monthly',
                      groupValue: rateType,
                      onChanged: (v) => setState(() => rateType = v!),
                    ),
                  ),
                ],
              ),

              TextFormField(
                controller: _periodController,
                decoration: const InputDecoration(
                  labelText: 'مدت سپرده',
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'لطفاً مدت را وارد کنید' : null,
              ),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'نوع مدت',
                  prefixIcon: Icon(Icons.timelapse),
                ),
                value: periodType,
                items: const [
                  DropdownMenuItem(value: 'month', child: Text('ماه')),
                  DropdownMenuItem(value: 'day', child: Text('روز')),
                ],
                onChanged: (v) => setState(() => periodType = v!),
              ),

              CheckboxListTile(
                title: const Text('محاسبه سود مرکب'),
                value: isCompound,
                onChanged: (v) => setState(() => isCompound = v!),
                activeColor: Colors.deepPurple,
              ),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('محاسبه سود'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),

              if (showResult) ...[
                const SizedBox(height: 30),
                GlassCard(
                  color: Colors.green,
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
                        _resultRow('مبلغ اصل', result['principal']),
                        _resultRow('سود دریافتی', result['interest']),
                        _resultRow('کل مبلغ', result['totalAmount']),
                        const Divider(),
                        Text(
                          'مدت: ${result['months']} ماه',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
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
            '${Formatter.formatCurrency(value)} تومان',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
          ),
        ],
      ),
    );
  }
}