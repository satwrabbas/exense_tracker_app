import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// الاستدعاءات المهمة
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart'; // هذا السطر الذي كان ينقصنا
import 'expense_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تعريف الـ Providers الاثنين هنا
    final provider = Provider.of<TransactionProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المصاريف'),
        centerTitle: true,
        actions: [
          // زر تبديل الوضع المظلم والمضيء
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط التنقل بين الأشهر
          Container(
            color: themeProvider.isDarkMode 
                ? Colors.grey.withOpacity(0.2) 
                : Colors.green.withOpacity(0.1), // تعديل اللون ليناسب الوضعين
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => provider.changeMonth(-1), // الشهر السابق
                ),
                Text(
                  DateFormat('MMMM yyyy').format(provider.currentMonth),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 20),
                  onPressed: () => provider.changeMonth(1), // الشهر القادم
                ),
              ],
            ),
          ),

          // الإحصائيات
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('الدخل', provider.totalIncome, Colors.green),
                _buildStatCard('المصاريف', provider.totalExpense, Colors.red),
              ],
            ),
          ),
          
          // الرسم البياني
          const ExpenseChart(), 
          
          const Divider(),
          
          // قائمة المعاملات
          Expanded(
            child: provider.monthlyTransactions.isEmpty
                ? const Center(child: Text('لا توجد معاملات في هذا الشهر!'))
                : ListView.builder(
                    itemCount: provider.monthlyTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = provider.monthlyTransactions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: tx.isExpense ? Colors.red : Colors.green,
                            child: Icon(
                              tx.isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(tx.title),
                          subtitle: Text('${DateFormat('yyyy-MM-dd').format(tx.date)} • ${tx.category}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            onPressed: () => provider.deleteTransaction(tx),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // دالة الإحصائيات
  Widget _buildStatCard(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('\$${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, color: color)),
      ],
    );
  }

  // دالة نافذة الإضافة
  void _showAddDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isExpense = true;
    
    final List<String> categories = ['طعام', 'مواصلات', 'فواتير', 'ترفيه', 'راتب', 'أخرى'];
    String selectedCategory = categories.first; 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20, left: 20, right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'وصف المعاملة'),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'المبلغ'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'التصنيف'),
                    items: categories.map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('النوع:'),
                      ChoiceChip(
                        label: const Text('مصروف'),
                        selected: isExpense,
                        onSelected: (val) => setState(() => isExpense = true),
                        selectedColor: Colors.red.shade200,
                      ),
                      ChoiceChip(
                        label: const Text('دخل'),
                        selected: !isExpense,
                        onSelected: (val) => setState(() => isExpense = false),
                        selectedColor: Colors.green.shade200,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isEmpty || amountController.text.isEmpty) return;
                      
                      final newTx = Transaction(
                        id: DateTime.now().toString(),
                        title: titleController.text,
                        amount: double.parse(amountController.text),
                        date: DateTime.now(),
                        isExpense: isExpense,
                        category: selectedCategory, 
                      );

                      Provider.of<TransactionProvider>(context, listen: false).addTransaction(newTx);
                      Navigator.of(context).pop();
                    },
                    child: const Text('إضافة'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}