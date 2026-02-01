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

  Future<int> addProduct(Product product) async {
    final id = await productRepository.insert(product);
    product.id = id;
    _products.add(product);

    await updateProductModifiers(id, product.enabledModifierIds);
    notifyListeners();

    return id;
  }

  Future<void> updateProduct(Product product) async {
    await productRepository.update(product);

    await updateProductModifiers(product.id!, product.enabledModifierIds);

    final refreshedProduct = await productRepository.getById(product.id!);

    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = refreshedProduct!;
      notifyListeners();
    }
  }

  Future<void> updateProductModifiers(
    int productId,
    List<int> modifierIds,
  ) async {
    await productRepository.updateProductModifiers(productId, modifierIds);
  }

  Future<void> deleteProduct(int id) async {
    await productRepository.delete(id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
