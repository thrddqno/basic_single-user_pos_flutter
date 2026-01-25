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
  }); // only date

  double get total => items.fold(0, (sum, item) => sum + item.total);

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
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

  @override
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Receipt #${id ?? "N/A"}');
    buffer.writeln('Date: ${date.toIso8601String()}');
    buffer.writeln('Payment Method: $paymentMethod');
    if (cashReceived != null) buffer.writeln('Cash Received: $cashReceived');
    buffer.writeln('Items:');

    for (var item in items) {
      final optionNames = item.options.map((o) => o.name).join(', ');
      buffer.writeln(
        '- ${item.product.name} x${item.quantity} ${optionNames.isNotEmpty ? "[$optionNames]" : ""} -> Total: ${item.total}',
      );
    }

    buffer.writeln('Total: $total');
    return buffer.toString();
  }
}
