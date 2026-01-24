import 'dart:convert';

class ModifierOption {
  final int? id;
  final String name;
  final double price;

  ModifierOption({this.id, required this.name, required this.price});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'price': price};

  factory ModifierOption.fromMap(Map<String, dynamic> map) =>
      ModifierOption(id: map['id'], name: map['name'], price: map['price']);

  String toJson() => json.encode(toMap());

  factory ModifierOption.fromJson(String json) =>
      ModifierOption.fromMap(jsonDecode(json));
}
