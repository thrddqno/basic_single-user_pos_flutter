import 'dart:convert';

class Category {
  final int? id;
  final String name;

  Category({this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory Category.fromMap(Map<String, dynamic> map) =>
      Category(id: map['id'], name: map['name']);

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String source) =>
      Category.fromMap(jsonDecode(source));

  @override
  String toString() => 'Category(id: $id, name: $name)';
}
