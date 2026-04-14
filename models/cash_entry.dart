import 'package:hive/hive.dart';
part 'cash_entry.g.dart';

@HiveType(typeId: 2)
class CashEntry extends HiveObject {
  @HiveField(0)
  double amount;
  @HiveField(1)
  String type;
  @HiveField(2)
  DateTime date;
  @HiveField(3)
  String? note;

  CashEntry({required this.amount, required this.type, required this.date, this.note});

  Map<String, dynamic> toMap() => {
    'amount': amount, 'type': type, 'date': date.toIso8601String(), 'note': note,
  };

  factory CashEntry.fromMap(Map<String, dynamic> map) => CashEntry(
    amount: (map['amount'] as num).toDouble(),
    type: map['type'], date: DateTime.parse(map['date']), note: map['note'],
  );
}