import 'package:flutter/foundation.dart' hide Category;
import 'package:basic_single_user_pos_flutter/models/category.dart';
import 'package:basic_single_user_pos_flutter/repositories/category_repository.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryRepository categoryRepository;

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  int? _selectedCategoryId;
  String _selectedCategoryName = 'All';

  int? get selectedCategoryId => _selectedCategoryId;
  String get selectedCategoryName => _selectedCategoryName;

  CategoryProvider(this.categoryRepository);

  Future<void> loadCategories() async {
    _categories = await categoryRepository.getAll();
    notifyListeners();
  }

  void selectCategory(int? id, String name) {
    _selectedCategoryId = id;
    _selectedCategoryName = name;
    notifyListeners();
  }

  Future<int> addCategory(Category category) async {
    final id = await categoryRepository.insert(category);
    _categories.add(Category(id: id, name: category.name));
    notifyListeners();
    return id;
  }

  Future<void> updateCategory(Category category) async {
    await categoryRepository.update(category);
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(int id) async {
    await categoryRepository.delete(id);

    _categories.removeWhere((c) => c.id == id);

    if (_selectedCategoryId == id) {
      _selectedCategoryId = null;
      _selectedCategoryName = 'All';
    }

    notifyListeners();
  }
}
