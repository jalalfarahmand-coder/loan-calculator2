import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

class Formatter {
  static final NumberFormat _currencyFormatter = NumberFormat('#,###', 'fa_IR');

  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount.toInt());
  }

  static String toShamsi(DateTime date) {
    final shamsi = Jalali.fromDateTime(date);
    return '${shamsi.year}/${shamsi.month.toString().padLeft(2, '0')}/${shamsi.day.toString().padLeft(2, '0')}';
  }
}

// نمایش لحظه‌ای فرمت شده
class CurrencyPreview extends StatefulWidget {
  final TextEditingController controller;

  const CurrencyPreview({super.key, required this.controller});

  @override
  State<CurrencyPreview> createState() => _CurrencyPreviewState();
}

class _CurrencyPreviewState extends State<CurrencyPreview> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.text;
    if (value.isEmpty) return const SizedBox.shrink();

    double? number = double.tryParse(value.replaceAll(',', ''));
    if (number == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 12),
      child: Text(
        'مقدار: ${Formatter.formatCurrency(number)}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontFamily: 'Vazirmatn',
        ),
      ),
    );
  }
}

// افکت شیشه‌ای
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? color;

  const GlassCard({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (color ?? Colors.deepPurple).withOpacity(0.2),
            (color ?? Colors.teal).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: child,
      ),
    );
  }
}