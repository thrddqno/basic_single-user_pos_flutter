import 'package:basic_single_user_pos_flutter/models/receipt_item.dart';

class Receipt {
  final int id;
  final DateTime date;
  final List<ReceiptItem> items;
  final String paymentMethod;
  final double? cashReceived;

  Receipt({
    required this.id,
    required this.date,
    required this.items,
    required this.paymentMethod,
    this.cashReceived,
  });

  double get total => items.fold(0, (sum, item) => sum + item.total);

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'items': items.map((item) => item.toJson()).toList(),
    'total': total,
    'paymentMethod': paymentMethod,
    'cashReceived': cashReceived,
  };

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
    id: json['id'],
    date: DateTime.parse(json['date']),
    items: (json['items'] as List)
        .map((item) => ReceiptItem.fromJson(item))
        .toList(),
    paymentMethod: json['paymentMethod'],
    cashReceived: json['cashReceived'],
  );
}
