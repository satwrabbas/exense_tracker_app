import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';

class TotalStatisticsScreen extends StatelessWidget {
  const TotalStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final categoryData = provider.overallExpenseByCategory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإحصائيات الشاملة'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              Card(
                color: provider.overallBalance >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'الرصيد المتبقي الإجمالي',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '\$${provider.overallBalance.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard('إجمالي الدخل', provider.overallIncome, Colors.green),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSummaryCard('إجمالي المصاريف', provider.overallExpense, Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              
              const Text(
                'توزيع المصاريف الكلية حسب التصنيف',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              
              categoryData.isEmpty
                  ? const Center(child: Text('لا توجد مصاريف بعد لرسمها!'))
                  : SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sections: _generateChartData(categoryData),
                          centerSpaceRadius: 50,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
              
              const SizedBox(height: 30),
              
              
              if (categoryData.isNotEmpty) ...[
                const Text(
                  'تفاصيل المصاريف:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...categoryData.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    trailing: Text(
                      '\$${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  );
                }).toList(),
              ]
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  
  List<PieChartSectionData> _generateChartData(Map<String, double> data) {
    final List<Color> colors = [
      Colors.blue, Colors.orange, Colors.purple, Colors.teal, Colors.pink, Colors.brown
    ];
    int colorIndex = 0;

    return data.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: entry.key,
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }
}