import 'dart:convert';

class ModifierOption {
  final int? id;
  final int modifierId;
  final String name;
  final double price;

  ModifierOption({
    this.id,
    required this.modifierId,
    required this.name,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'modifier_id': modifierId,
    'name': name,
    'price': price,
  };

  factory ModifierOption.fromMap(Map<String, dynamic> map) => ModifierOption(
    id: map['id'],
    modifierId: map['modifier_id'],
    name: map['name'],
    price: map['price'],
  );

  String toJson() => json.encode(toMap());

  factory ModifierOption.fromJson(String json) =>
      ModifierOption.fromMap(jsonDecode(json));

  String toString() =>
      'ModiferOption(id: $id, modifierId: $modifierId, name: $name, price: $price)';
}
