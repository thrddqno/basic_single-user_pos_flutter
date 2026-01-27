import 'dart:convert';

class ModifierOption {
  int? id;
  final int? modifierId;
  final String name;
  final double? price;
  final String tempKey;

  ModifierOption({
    this.id,
    this.modifierId,
    required this.name,
    this.price,
    String? tempKey,
  }) : tempKey = tempKey ?? DateTime.now().millisecondsSinceEpoch.toString();

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

  @override
  String toString() =>
      'ModifierOption(id: $id, modifierId: $modifierId, name: $name, price: $price)';
}
