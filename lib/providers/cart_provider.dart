import 'package:basic_single_user_pos_flutter/models/cart_item.dart';
import 'package:basic_single_user_pos_flutter/models/product.dart';
import 'package:basic_single_user_pos_flutter/providers/modifier_provider.dart';

import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  ModifierProvider modifierProvider;

  double _cachedTotal = 0;
  bool _totalDirty = true;

  CartProvider({required this.modifierProvider}) {
    modifierProvider.addListener(_onModifierDataChanged);
  }

  void _onModifierDataChanged() {
    _totalDirty = true;
    notifyListeners();
  }

  @override
  void dispose() {
    modifierProvider.removeListener(_onModifierDataChanged);
    super.dispose();
  }

  double _modifierTotalForSelection(Map<int, Set<int>> modifiers) {
    double sum = 0;
    for (final entry in modifiers.entries) {
      for (final optionId in entry.value) {
        final option = modifierProvider.optionById(optionId);
        if (option != null) {
          sum += option.price ?? 0;
        }
      }
    }
    return sum;
  }

  double _computeTotal() {
    double sum = 0;
    for (final item in _items) {
      final modifierTotal = _modifierTotalForSelection(item.selectedModifiers);
      sum += (item.product.price + modifierTotal) * item.quantity;
    }
    return sum;
  }

  void addItem(Product product, int quantity, Map<int, Set<int>> modifiers) {
    final modifierTotal = _modifierTotalForSelection(modifiers);
    final itemTotal = (product.price + modifierTotal) * quantity;

    if (itemTotal <= 0) return;

    int existingIndex = -1;
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].product.id == product.id &&
          _modifiersEqual(_items[i].selectedModifiers, modifiers)) {
        existingIndex = i;
        break;
      }
    }

    if (existingIndex >= 0) {
      _items[existingIndex] = CartItem(
        product: _items[existingIndex].product,
        quantity: _items[existingIndex].quantity + quantity,
        selectedModifiers: _items[existingIndex].selectedModifiers,
      );
    } else {
      _items.add(
        CartItem(
          product: product,
          quantity: quantity,
          selectedModifiers: modifiers,
        ),
      );
    }

    _totalDirty = true;
    notifyListeners();
  }

  bool _modifiersEqual(
    Map<int, Set<int>> modifiers1,
    Map<int, Set<int>> modifiers2,
  ) {
    if (modifiers1.length != modifiers2.length) return false;
    for (var entry in modifiers1.entries) {
      if (!modifiers2.containsKey(entry.key)) return false;
      final set1 = entry.value;
      final set2 = modifiers2[entry.key]!;
      if (set1.length != set2.length) return false;
      for (var id in set1) {
        if (!set2.contains(id)) return false;
      }
    }
    return true;
  }

  void removeItem(int index) {
    _items.removeAt(index);
    _totalDirty = true;
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) return;
    _items[index] = CartItem(
      product: _items[index].product,
      quantity: newQuantity,
      selectedModifiers: _items[index].selectedModifiers,
    );
    _totalDirty = true;
    notifyListeners();
  }

  void updateItem(
    int index,
    Product product,
    int quantity,
    Map<int, Set<int>> modifiers,
  ) {
    if (quantity <= 0) {
      removeItem(index);
      return;
    }

    final modifierTotal = _modifierTotalForSelection(modifiers);
    final itemTotal = (product.price + modifierTotal) * quantity;

    if (itemTotal <= 0) {
      removeItem(index);
      return;
    }

    _items[index] = CartItem(
      product: product,
      quantity: quantity,
      selectedModifiers: modifiers,
    );

    _totalDirty = true;
    notifyListeners();
  }

  double get total {
    if (_totalDirty) {
      _cachedTotal = _computeTotal();
      _totalDirty = false;
    }
    return _cachedTotal;
  }

  void clear() {
    _items.clear();
    _cachedTotal = 0;
    _totalDirty = false;
    notifyListeners();
  }
}
