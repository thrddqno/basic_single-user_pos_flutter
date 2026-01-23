import 'package:basic_single_user_pos_flutter/models/category.dart';
import 'package:basic_single_user_pos_flutter/models/modifier.dart';

class Product {
  final int id;
  final String name;
  final Category category;
  final double price;
  // list of enabled modifier
  final List<Modifier> enabledModifiers;
  final double? cost;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.enabledModifiers = const [],
    this.cost,
  });

  //convert to map
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category.toJson(),
    'price': price,
    'enabledModifiers': enabledModifiers
        .map((modifier) => modifier.toJson())
        .toList(),
    'cost': cost,
  };

  // from map, parse to product
  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    category: Category.fromJson(json['category']),
    price: json['price'],
    // list enabled modifiers, if null, then null
    enabledModifiers:
        (json['enabledModifiers'] as List<dynamic>?)
            ?.map((modifier) => Modifier.fromJson(modifier))
            .toList() ??
        [],
    cost: json['cost'],
  );
}
