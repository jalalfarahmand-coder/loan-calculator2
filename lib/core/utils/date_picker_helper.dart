import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'formatter.dart';

Future<Jalali?> showPersianDatePickerDialog(BuildContext context) async {
  Jalali selectedDate = Jalali.now();

  return await showDialog<Jalali>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('انتخاب تاریخ', textAlign: TextAlign.center),
      content: SizedBox(
        height: 200,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<int>(
                  value: selectedDate.year,
                  items: List.generate(51, (index) => Jalali.now().year - 25 + index)
                      .map((year) => DropdownMenuItem(value: year, child: Text('$year')))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedDate = Jalali(value, selectedDate.month, selectedDate.day);
                    }
                  },
                ),
                DropdownButton<int>(
                  value: selectedDate.month,
                  items: List.generate(12, (index) => index + 1)
                      .map((month) => DropdownMenuItem(value: month, child: Text('$month')))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedDate = Jalali(selectedDate.year, value, selectedDate.day);
                    }
                  },
                ),
                DropdownButton<int>(
                  value: selectedDate.day,
                  items: List.generate(31, (index) => index + 1)
                      .map((day) => DropdownMenuItem(value: day, child: Text('$day')))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedDate = Jalali(selectedDate.year, selectedDate.month, value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selectedDate),
              child: const Text('تایید'),
            ),
          ],
        ),
      ),
    ),
  );
}