import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  final String boxName = 'transactionsBox';

  // --- الميزة الجديدة: الشهر المحدد ---
  DateTime _currentMonth = DateTime.now();
  DateTime get currentMonth => _currentMonth;

  // تغيير الشهر (للأمام أو للخلف)
  void changeMonth(int offset) {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset, 1);
    notifyListeners();
  }

  // --- جلب المعاملات الخاصة بالشهر المحدد فقط ---
  List<Transaction> get monthlyTransactions {
    return _transactions.where((tx) {
      return tx.date.year == _currentMonth.year && tx.date.month == _currentMonth.month;
    }).toList();
  }

  // ------------------------------------------------

  Future<void> fetchTransactions() async {
    var box = await Hive.openBox<Transaction>(boxName);
    _transactions = box.values.toList();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction tx) async {
    var box = await Hive.openBox<Transaction>(boxName);
    await box.add(tx);
    _transactions.add(tx);
    notifyListeners();
  }

  Future<void> deleteTransaction(Transaction tx) async {
    await tx.delete();
    _transactions.remove(tx);
    notifyListeners();
  }

  // --- تحديث الإحصائيات لتعتمد على الشهر المحدد (monthlyTransactions) بدلاً من كل المعاملات ---
  
  double get totalIncome {
    return monthlyTransactions.where((tx) => !tx.isExpense).fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return monthlyTransactions.where((tx) => tx.isExpense).fold(0.0, (sum, item) => sum + item.amount);
  }

  Map<String, double> get expenseByCategory {
    Map<String, double> categoryData = {};
    for (var tx in monthlyTransactions.where((tx) => tx.isExpense)) {
      if (categoryData.containsKey(tx.category)) {
        categoryData[tx.category] = categoryData[tx.category]! + tx.amount;
      } else {
        categoryData[tx.category] = tx.amount;
      }
    }
    return categoryData;
  }
}