import 'package:basic_single_user_pos_flutter/models/modifier_option.dart';
import 'package:basic_single_user_pos_flutter/models/product.dart';
import 'dart:convert';

class ReceiptItem {
  final int? id;
  final Product product;
  final List<ModifierOption> options;
  final int quantity;

  ReceiptItem({
    this.id,
    required this.product,
    required this.options,
    required this.quantity,
  });

  double get total {
    double optionsTotal = options.fold(0, (sum, option) => sum + option.price!);
    return (product.price + optionsTotal) * quantity;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'product': product.toMap(),
    'options': options.map((option) => option.toMap()).toList(),
    'quantity': quantity,
    'total': total,
  };

  factory ReceiptItem.fromMap(Map<String, dynamic> map) => ReceiptItem(
    id: map['id'],
    product: Product.fromMap(map['product']),
    options: (map['options'] as List)
        .map((option) => ModifierOption.fromMap(option))
        .toList(),
    quantity: map['quantity'],
  );

  String toJson() => json.encode(toMap());

  factory ReceiptItem.fromJson(String source) =>
      ReceiptItem.fromMap(jsonDecode(source));
}
