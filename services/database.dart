import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../models/cash_entry.dart';


class DatabaseService {
  static const String customersBoxName = 'customersBox';
  static Box<Customer>? _customersBox;
  static Box<CashEntry>? _cashbookBox;
  static late Box settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(CustomerAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TransactionAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(CashEntryAdapter());

    _customersBox = await Hive.openBox<Customer>(customersBoxName);
    _cashbookBox = await Hive.openBox<CashEntry>('cashbookBox');
    settingsBox = await Hive.openBox('settings'); 
  }

  static Box<Customer> get customersBox => _customersBox!;
  static Box<CashEntry> get cashbookBox => _cashbookBox!;

  static Future<Box<Transaction>> getTransactionsBox(String customerId) async {
    final boxName = 'transactions_$customerId';
    if (!Hive.isBoxOpen(boxName)) return await Hive.openBox<Transaction>(boxName);
    return Hive.box<Transaction>(boxName);
  }

  static Future<void> addCustomer(Customer customer) async {
    customer.lastUpdated = DateTime.now();
    await customersBox.put(customer.id, customer);
  }

  static Future<void> deleteCustomer(String id) async {
    final boxName = 'transactions_$id';
    if (Hive.isBoxOpen(boxName)) await Hive.box<Transaction>(boxName).close();
    await Hive.deleteBoxFromDisk(boxName);
    await customersBox.delete(id);
  }

  static Future<void> addTransaction(Transaction transaction) async {
    final box = await getTransactionsBox(transaction.customerId);
    await box.add(transaction);
    final customer = customersBox.get(transaction.customerId);
    if (customer != null) {
      customer.lastUpdated = DateTime.now();
      await customer.save();
    }
  }
}