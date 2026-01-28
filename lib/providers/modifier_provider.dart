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
  Map<int, List<ModifierOption>> _optionsByModifierId = const {};
  Map<int, ModifierOption> _optionById = const {};

  List<Modifier> get modifiers => _modifiers;
  List<ModifierOption> get options => _options;

  Future<ModifierOption> getOption(int id) async {
    return await modifierOptionRepository.getModifierOption(id);
  }

  List<ModifierOption> optionsForModifier(int modifierId) {
    return _optionsByModifierId[modifierId] ?? const <ModifierOption>[];
  }

  ModifierOption? optionById(int optionId) => _optionById[optionId];

  void _rebuildOptionCaches() {
    final byModifier = <int, List<ModifierOption>>{};
    final byId = <int, ModifierOption>{};

    for (final opt in _options) {
      final id = opt.id;
      if (id != null) {
        byId[id] = opt;
      }
      byModifier
          .putIfAbsent(opt.modifierId!, () => <ModifierOption>[])
          .add(opt);
    }

    _optionsByModifierId = byModifier.map(
      (k, v) => MapEntry(k, List<ModifierOption>.unmodifiable(v)),
    );
    _optionById = Map<int, ModifierOption>.unmodifiable(byId);
  }

  Future<void> loadAll() async {
    _modifiers = await modifierRepository.getAll();
    _options = await modifierOptionRepository.getAll();
    _rebuildOptionCaches();
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
    _rebuildOptionCaches();
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
      _rebuildOptionCaches();
      notifyListeners();
    }
  }

  Future<void> deleteModifier(int modifierId) async {
    await modifierOptionRepository.deleteByModifierId(modifierId);
    await modifierRepository.delete(modifierId);
    _modifiers.removeWhere((m) => m.id == modifierId);
    _options.removeWhere((o) => o.modifierId == modifierId);
    _rebuildOptionCaches();
    notifyListeners();
  }

  Future<void> deleteByModifierId(int modifierId) async {
    await modifierOptionRepository.deleteByModifierId(modifierId);
  }

  Future<void> deleteOption(int optionId) async {
    await modifierOptionRepository.delete(optionId);
    _options.removeWhere((o) => o.id == optionId);
    _rebuildOptionCaches();
    notifyListeners();
  }
}
