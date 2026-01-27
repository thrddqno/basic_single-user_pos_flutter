import 'dart:convert';

class Product {
  int? id;
  final String name;
  final int categoryId;
  final double price;
  // list of enabled modifier
  final List<int> enabledModifierIds;
  final double? cost;
  final String color;

  Product({
    this.id,
    required this.name,
    this.categoryId = 1,
    required this.price,
    this.enabledModifierIds = const [],
    this.cost,
    required this.color,
  });

  //convert to map
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category_id': categoryId,
    'price': price,
    'enabled_modifier_ids': jsonEncode(enabledModifierIds),
    'cost': cost,
    'color': color,
  };

  // from map, parse to product
  factory Product.fromMap(Map<String, dynamic> map) => Product(
    id: map['id'],
    name: map['name'],
    categoryId: map['category_id'],
    price: map['price'],
    // list enabled modifiers, if null, then null
    enabledModifierIds: map['enabled_modifier_ids'] != null
        ? List<int>.from(jsonDecode(map['enabled_modifier_ids']))
        : [],
    cost: map['cost'],
    color: map['color'],
  );

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(jsonDecode(source));
  @override
  String toString() =>
      'Product(id: $id, name: $name, categoryId: $categoryId, price: $price, cost: $cost, color: $color, enabledModifierIds: $enabledModifierIds)';
}
