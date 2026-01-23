import 'package:basic_single_user_pos_flutter/models/modifier_option.dart';
import 'package:basic_single_user_pos_flutter/models/product.dart';

class ReceiptItem {
  final int id;
  final Product product;
  final List<ModifierOption> options;
  final int quantity;

  ReceiptItem({
    required this.id,
    required this.product,
    required this.options,
    required this.quantity,
  });

  double get total {
    double optionsTotal = options.fold(0, (sum, option) => sum + option.price);
    return (product.price + optionsTotal) * quantity;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product': product.toJson(),
    'options': options.map((option) => option.toJson()).toList(),
    'quantity': quantity,
    'total': total,
  };

  factory ReceiptItem.fromJson(Map<String, dynamic> json) => ReceiptItem(
    id: json['id'],
    product: Product.fromJson(json['product']),
    options: (json['options'] as List)
        .map((option) => ModifierOption.fromJson(option))
        .toList(),
    quantity: json['quantity'],
  );
}
