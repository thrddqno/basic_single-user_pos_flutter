import 'package:basic_single_user_pos_flutter/models/modifier_option.dart';

class Modifier {
  final int id;
  final String name;
  final List<ModifierOption> options;

  Modifier({required this.id, required this.name, required this.options});

  // Convert Modifier -> Map for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'options': options.map((o) => o.toJson()).toList(),
  };

  // Convert Map -> Modifier
  factory Modifier.fromJson(Map<String, dynamic> json) => Modifier(
    id: json['id'],
    name: json['name'],
    options: (json['options'] as List)
        .map((o) => ModifierOption.fromJson(o))
        .toList(),
  );
}
