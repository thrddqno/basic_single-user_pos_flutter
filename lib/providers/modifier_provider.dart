import 'package:basic_single_user_pos_flutter/models/modifier.dart';
import 'package:basic_single_user_pos_flutter/models/modifier_option.dart';
import 'package:basic_single_user_pos_flutter/repositories/modifier_option_repository.dart';
import 'package:basic_single_user_pos_flutter/repositories/modifier_repository.dart';
import 'package:flutter/material.dart';

class ModifierProvider extends ChangeNotifier {
  final ModifierRepository modifierRepository;
  final ModifierOptionRepository modifierOptionRepository;

  ModifierProvider(this.modifierRepository, this.modifierOptionRepository);

  List<Modifier> _modifiers = [];
  List<ModifierOption> _options = [];

  List<Modifier> get modifiers => _modifiers;
  List<ModifierOption> get options => _options;

  List<ModifierOption> optionsForModifier(int modifierId) {
    return _options.where((o) => o.modifierId == modifierId).toList();
  }

  Future<void> loadAll() async {
    _modifiers = await modifierRepository.getAll();
    _options = await modifierOptionRepository.getAll();
    notifyListeners();
  }

  Future<void> addModifier(Modifier modifier) async {
    final id = await modifierRepository.insert(modifier);
    _modifiers.add(Modifier(id: id, name: modifier.name));
    notifyListeners();
  }

  Future<void> addOption(ModifierOption option) async {
    final id = await modifierOptionRepository.insert(option);
    _options.add(
      ModifierOption(
        id: id,
        modifierId: option.modifierId,
        name: option.name,
        price: option.price,
      ),
    );
    notifyListeners();
  }

  Future<void> updateModifier(Modifier modifier) async {
    if (modifier.id == null) return;

    await modifierRepository.update(modifier);

    final index = _modifiers.indexWhere((m) => m.id == modifier.id);
    if (index != -1) {
      _modifiers[index] = modifier;
      notifyListeners();
    }
  }

  Future<void> updateOption(ModifierOption option) async {
    if (option.id == null) return;

    await modifierOptionRepository.update(option);

    final index = _options.indexWhere((o) => o.id == option.id);
    if (index != -1) {
      _options[index] = option;
      notifyListeners();
    }
  }

  Future<void> deleteModifier(int modifierId) async {
    await modifierOptionRepository.deleteByModifierId(modifierId);
    await modifierRepository.delete(modifierId);
    _modifiers.removeWhere((m) => m.id == modifierId);
    _options.removeWhere((o) => o.modifierId == modifierId);
    notifyListeners();
  }

  Future<void> deleteByModifierId(int modifierId) async {
    await modifierOptionRepository.deleteByModifierId(modifierId);
  }

  Future<void> deleteOption(int optionId) async {
    await modifierOptionRepository.delete(optionId);
    _options.removeWhere((o) => o.id == optionId);
    notifyListeners();
  }
}
