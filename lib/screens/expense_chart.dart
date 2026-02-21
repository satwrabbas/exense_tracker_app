import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class ExpenseChart extends StatelessWidget {
  const ExpenseChart({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final data = provider.expenseByCategory;

    // ألوان للتصنيفات المختلفة
    final List<Color> colors = [
      Colors.blue, Colors.orange, Colors.purple, Colors.teal, Colors.pink, Colors.brown
    ];

    if (data.isEmpty) {
      return const SizedBox(); // لا تعرض شيء إذا لم تكن هناك مصاريف
    }

    int colorIndex = 0;
    List<PieChartSectionData> sections = data.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: entry.key,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }
}