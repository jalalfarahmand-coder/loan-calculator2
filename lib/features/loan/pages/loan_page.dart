import 'package:flutter/material.dart';
import '../../../core/services/calculator_service.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/models/loan_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LoanPage extends StatefulWidget {
  const LoanPage({super.key});

  @override
  State<LoanPage> createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _monthsController = TextEditingController();
  final _graceDaysController = TextEditingController();

  String rateType = 'annual';
  String installmentType = 'monthly';
  Map<String, dynamic> result = {};
  bool showResult = false;

  @override
  void initState() {
    super.initState();
    _graceDaysController.text = '0';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _principalController.dispose();
    _rateController.dispose();
    _monthsController.dispose();
    _graceDaysController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      result = CalculatorService.calculateLoan(
        principal: double.parse(_principalController.text.replaceAll(',', '')),
        rate: double.parse(_rateController.text),
        months: int.parse(_monthsController.text),
        graceDays: int.parse(_graceDaysController.text),
        rateType: rateType,
        installmentType: installmentType,
      );
      showResult = true;
    });

    final box = Hive.box<LoanModel>('loans');
    box.add(LoanModel(
      principal: double.parse(_principalController.text.replaceAll(',', '')),
      monthlyRate: rateType == 'annual' ? double.parse(_rateController.text) / 12 / 100 : double.parse(_rateController.text) / 100,
      months: int.parse(_monthsController.text),
      graceDays: int.parse(_graceDaysController.text),
      installments: result['installments'],
      createdAt: DateTime.now(),
      installmentType: installmentType,
      title: _titleController.text.isEmpty ? 'وام' : _titleController.text,
    ));
  }

  Future<void> _exportPdf() async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.amiriRegular();

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font),
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return [
            pw.Header(level: 0, child: pw.Text('گزارش اقساط وام')),
            pw.Text('تاریخ: ${Formatter.toShamsi(DateTime.now())}'),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['قسط', 'مبلغ (تومان)'],
              data: List.generate(
                result['installments'].length,
                    (i) => ['${i + 1}', Formatter.formatCurrency(result['installments'][i])],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('مبلغ کل وام: ${Formatter.formatCurrency(double.parse(_principalController.text.replaceAll(',', '')))} تومان'),
            pw.Text('جمع سود: ${Formatter.formatCurrency(result['totalInterest'])} تومان'),
            pw.Text('کل بازپرداخت: ${Formatter.formatCurrency(result['totalAmount'])} تومان'),
          ];
        },
      ),
    );
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'loan_report.pdf');
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
          keyboardType: keyboardType ?? TextInputType.number,
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
      appBar: AppBar(title: const Text('محاسبه اقساط وام')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان وام (اختیاری)',
                  hintText: 'مثلا: وام مسکن',
                ),
              ),
              const SizedBox(height: 10),

              _buildInputWithPreview(
                controller: _principalController,
                label: 'مبلغ وام (تومان)',
                hint: '100000000',
                icon: Icons.money,
              ),

              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(
                  labelText: 'نرخ سود (%)',
                  suffixText: 'سالانه/ماهیانه',
                  prefixIcon: Icon(Icons.percent),
                ),
                keyboardType: TextInputType.number,
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
                controller: _monthsController,
                decoration: const InputDecoration(
                  labelText: 'تعداد اقساط (ماه)',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'لطفاً تعداد اقساط را وارد کنید' : null,
              ),

              TextFormField(
                controller: _graceDaysController,
                decoration: const InputDecoration(
                  labelText: 'روزهای تنفس',
                  hintText: '0',
                  prefixIcon: Icon(Icons.timelapse),
                ),
                keyboardType: TextInputType.number,
              ),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'فاصله زمانی اقساط',
                  prefixIcon: Icon(Icons.timeline),
                ),
                value: installmentType,
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('ماهانه')),
                  DropdownMenuItem(value: 'bimonthly', child: Text('دو ماهه')),
                  DropdownMenuItem(value: 'quarterly', child: Text('سه ماهه')),
                  DropdownMenuItem(value: 'yearly', child: Text('سالانه')),
                ],
                onChanged: (v) => setState(() => installmentType = v!),
              ),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('محاسبه اقساط'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),

              if (showResult) ...[
                const SizedBox(height: 30),
                GlassCard(
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
                        _resultRow('مبلغ هر قسط', result['installmentAmount']),
                        _resultRow('جمع سود', result['totalInterest']),
                        _resultRow('کل بازپرداخت', result['totalAmount']),
                        if (int.parse(_graceDaysController.text) > 0) ...[
                          const Divider(),
                          _resultRow('مبلغ با تنفس', result['principalWithGrace']),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _exportPdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('خروجی PDF'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
        ],
      ),
    );
  }
}