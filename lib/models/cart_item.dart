import 'package:basic_single_user_pos_flutter/models/product.dart';

class CartItem {
  final Product product;
  final int quantity;
  final Map<int, Set<int>> selectedModifiers;

  CartItem({
    required this.product,
    this.quantity = 1,
    Map<int, Set<int>>? selectedModifiers,
  }) : selectedModifiers = selectedModifiers ?? {};
}
