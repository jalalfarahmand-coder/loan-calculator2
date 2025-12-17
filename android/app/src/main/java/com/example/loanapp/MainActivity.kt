package com.example.loanapp

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.widget.*

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // UI ساده با LinearLayout
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(50, 50, 50, 50)
        }

        val etPrincipal = EditText(this).apply { hint = "مبلغ وام (تومان)" }
        val etRate = EditText(this).apply { hint = "نرخ سود (%)" }
        val etMonths = EditText(this).apply { hint = "تعداد ماه" }
        val btnCalculate = Button(this).apply { text = "محاسبه" }
        val tvResult = TextView(this).apply { textSize = 20f }

        btnCalculate.setOnClickListener {
            val principal = etPrincipal.text.toString().toDoubleOrNull() ?: 0.0
            val rate = etRate.text.toString().toDoubleOrNull() ?: 0.0
            val months = etMonths.text.toString().toIntOrNull() ?: 0

            val monthlyRate = rate / 100 / 12
            val installment = principal * (monthlyRate * Math.pow(1 + monthlyRate, months.toDouble())) /
                    (Math.pow(1 + monthlyRate, months.toDouble()) - 1)

            tvResult.text = "قسط ماهانه: ${String.format("%,.0f", installment)} تومان"
        }

        layout.addView(etPrincipal)
        layout.addView(etRate)
        layout.addView(etMonths)
        layout.addView(btnCalculate)
        layout.addView(tvResult)

        setContentView(layout)
    }
}