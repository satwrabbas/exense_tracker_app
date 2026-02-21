import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/transaction.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  await Hive.openBox<Transaction>('transactionsBox');

  runApp(
    ChangeNotifierProvider(
      create: (context) => TransactionProvider()..fetchTransactions(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ميزانيتي',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Cairo', // يمكنك إضافة خط عربي لاحقاً
      ),
      home: const HomeScreen(),
    );
  }
}