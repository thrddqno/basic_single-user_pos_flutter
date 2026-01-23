class ModifierOption {
  final int id;
  final String name;
  final double price;

  ModifierOption({required this.id, required this.name, required this.price});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};

  factory ModifierOption.fromJson(Map<String, dynamic> json) =>
      ModifierOption(id: json['id'], name: json['name'], price: json['price']);
}
