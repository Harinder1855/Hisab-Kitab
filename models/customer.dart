import 'package:hive/hive.dart';
part 'customer.g.dart';

@HiveType(typeId: 0)
class Customer extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String? phone;
  @HiveField(3)
  DateTime? lastUpdated;

  Customer({required this.id, required this.name, this.phone, this.lastUpdated});

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'phone': phone, 
    'lastUpdated': lastUpdated?.toIso8601String(),
  };

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
    id: map['id'], name: map['name'], phone: map['phone'],
    lastUpdated: map['lastUpdated'] != null ? DateTime.parse(map['lastUpdated']) : null,
  );
}