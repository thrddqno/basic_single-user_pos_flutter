import 'package:basic_single_user_pos_flutter/models/modifier_option.dart';
import 'dart:convert';

class Modifier {
  final int? id;
  final String name;
  final List<ModifierOption> options;

  Modifier({this.id, required this.name, required this.options});

  // Convert Modifier -> Map for storage
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'options': options.map((o) => o.toMap()).toList(),
  };

  // Convert Map -> Modifier
  factory Modifier.fromMap(Map<String, dynamic> map) => Modifier(
    id: map['id'],
    name: map['name'],
    options: (map['options'] as List)
        .map((o) => ModifierOption.fromMap(o))
        .toList(),
  );

  String toJson() => json.encode(toMap());

  factory Modifier.fromJson(String source) =>
      Modifier.fromMap(jsonDecode(source));
}
