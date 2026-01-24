import 'dart:convert';

class Modifier {
  final int? id;
  final String name;

  Modifier({this.id, required this.name});

  // Convert Modifier -> Map for storage
  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  // Convert Map -> Modifier
  factory Modifier.fromMap(Map<String, dynamic> map) =>
      Modifier(id: map['id'], name: map['name']);

  String toJson() => json.encode(toMap());

  factory Modifier.fromJson(String source) =>
      Modifier.fromMap(jsonDecode(source));
}
