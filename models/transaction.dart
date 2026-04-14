import 'package:hive/hive.dart';
part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  String customerId;
  @HiveField(1)
  String type;
  @HiveField(2)
  double amount;
  @HiveField(3)
  String? note;
  @HiveField(4)
  DateTime date;

  Transaction({required this.customerId, required this.type, required this.amount, this.note, required this.date});

  Map<String, dynamic> toMap() => {
    'customerId': customerId, 'type': type, 'amount': amount, 
    'note': note, 'date': date.toIso8601String(),
  };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
    customerId: map['customerId'], type: map['type'],
    amount: (map['amount'] as num).toDouble(),
    note: map['note'], date: DateTime.parse(map['date']),
  );
}