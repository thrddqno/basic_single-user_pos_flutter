import 'package:flutter/foundation.dart';
import 'package:basic_single_user_pos_flutter/models/product.dart';
import 'package:basic_single_user_pos_flutter/repositories/product_repository.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository productRepository;

  List<Product> _products = [];
  List<Product> get products => _products;

  ProductProvider(this.productRepository);

  Future<void> loadProducts() async {
    _products = await productRepository.getAll();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final id = await productRepository.insert(product); // return the new ID
    product.id = id; // assign it
    _products.add(product);
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    await productRepository.update(product);
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    await productRepository.delete(id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
