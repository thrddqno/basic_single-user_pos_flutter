import 'package:basic_single_user_pos_flutter/models/receipt_item.dart';
import 'dart:convert';

class Receipt {
  final int? id;
  final DateTime date;
  final List<ReceiptItem> items;
  final String paymentMethod;
  final double? cashReceived;

  Receipt({
    this.id,
    required this.date,
    required this.items,
    required this.paymentMethod,
    this.cashReceived,
  });

  double get total => items.fold(0, (sum, item) => sum + item.total);

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'items': items.map((item) => item.toMap()).toList(),
    'total': total,
    'paymentMethod': paymentMethod,
    'cashReceived': cashReceived,
  };

  factory Receipt.fromMap(Map<String, dynamic> map) => Receipt(
    id: map['id'],
    date: DateTime.parse(map['date']),
    items: (map['items'] as List)
        .map((item) => ReceiptItem.fromMap(item))
        .toList(),
    paymentMethod: map['paymentMethod'],
    cashReceived: map['cashReceived'],
  );

  String toJson() => jsonEncode(toMap());

  factory Receipt.fromJson(String source) =>
      Receipt.fromMap(jsonDecode(source));
}
