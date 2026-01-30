import 'package:basic_single_user_pos_flutter/models/modifier.dart';
import 'package:basic_single_user_pos_flutter/models/modifier_option.dart';
import 'package:basic_single_user_pos_flutter/providers/modifier_provider.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ModifierFormPage extends StatefulWidget {
  const ModifierFormPage({super.key});

  @override
  State<ModifierFormPage> createState() => _ModifierFormPageState();
}

class _ModifierFormPageState extends State<ModifierFormPage> {
  late GlobalKey<FormBuilderState> _formKey;
  late Map<String, dynamic> initialModifierValues;
  Modifier? modifierArg;
  List<ModifierOption> _options = [];
  final Map<String, TextEditingController> _nameControllers = {};
  final Map<String, TextEditingController> _priceControllers = {};

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormBuilderState>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    modifierArg = ModalRoute.of(context)?.settings.arguments as Modifier?;

    if (modifierArg != null) {
      final provider = context.read<ModifierProvider>();
      initialModifierValues = {'name': modifierArg!.name};
      _options = List<ModifierOption>.from(
        provider.optionsForModifier(modifierArg!.id!),
      );
    } else {
      initialModifierValues = {'name': ''};
      _options = [];
    }
  }

  @override
  void dispose() {
    _nameControllers.values.forEach((controller) => controller.dispose());
    _priceControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [_buildHeader(), _buildForm()]));
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 25),
      alignment: Alignment.bottomCenter,
      height: 100,
      decoration: const BoxDecoration(color: Colors.teal),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      FontAwesomeIcons.angleLeft,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    modifierArg == null ? "Add Modifier" : "Edit Modifier",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (modifierArg != null && modifierArg!.id != null)
                    _buildDeleteButton(),
                  _buildSaveButton(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return IconButton(
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Delete Modifier"),
            content: const Text(
              "Are you sure you want to delete this modifier?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await context.read<ModifierProvider>().deleteModifier(
            modifierArg!.id!,
          );
          Navigator.pop(context);
        }
      },
      icon: const Icon(Icons.delete, color: Colors.red),
    );
  }

  Widget _buildSaveButton() {
    return TextButton(
      onPressed: () async {
        if (_formKey.currentState?.saveAndValidate() ?? false) {
          try {
            final formData = _formKey.currentState!.value;
            final modifierProvider = context.read<ModifierProvider>();

            final modifier = Modifier(
              id: modifierArg?.id,
              name: formData['modifierName'],
            );

            bool allOptionsValid = true;
            for (var option in _options) {
              final key = option.id?.toString() ?? option.tempKey;
              final name = formData['optionName_$key']?.toString().trim();
              final priceText = formData['price_$key']?.toString().trim();

              if (name == null ||
                  name.isEmpty ||
                  priceText == null ||
                  priceText.isEmpty) {
                allOptionsValid = false;
                break;
              }
            }

            if (!allOptionsValid) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill in all option names and prices.'),
                ),
              );
              return;
            }

            if (modifierArg == null) {
              await modifierProvider.addModifier(modifier);
              final newModifierId = modifierProvider.modifiers.last.id!;

              for (var option in _options) {
                final key = option.id?.toString() ?? option.tempKey;
                final newOption = ModifierOption(
                  id: option.id,
                  modifierId: newModifierId,
                  name: formData['optionName_$key'],
                  price:
                      double.tryParse(formData['price_$key'].toString()) ?? 0,
                  tempKey: option.tempKey,
                );
                await modifierProvider.addOption(newOption);
              }
            }
            if (modifierArg != null) {
              // Existing modifier being edited
              final oldOptionIds = _options
                  .where((o) => o.id != null)
                  .map((o) => o.id!)
                  .toSet();

              // Delete options that existed in DB but were removed locally
              final existingOptionsInDb = await modifierProvider
                  .optionsForModifier(modifierArg!.id!);

              final toDelete = existingOptionsInDb.where(
                (option) => !oldOptionIds.contains(option.id),
              );

              for (var option in toDelete) {
                await modifierProvider.deleteOption(option.id!);
              }

              // Update existing / add new options
              for (var option in _options) {
                final key = option.id?.toString() ?? option.tempKey;
                final updatedOption = ModifierOption(
                  id: option.id,
                  modifierId: modifierArg!.id!,
                  name: formData['optionName_$key'],
                  price:
                      double.tryParse(formData['price_$key'].toString()) ?? 0,
                  tempKey: option.tempKey,
                );

                if (updatedOption.id == null) {
                  await modifierProvider.addOption(updatedOption);
                } else {
                  await modifierProvider.updateOption(updatedOption);
                }
              }
            }

            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error saving modifier: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: const Text(
        "SAVE",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 200, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormBuilderTextField(
                name: 'modifierName',
                initialValue: initialModifierValues['name'],
                decoration: const InputDecoration(labelText: 'Name'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              ..._options.asMap().entries.map((entry) {
                return _optionRow(entry.value);
              }),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _options.add(
                      ModifierOption(
                        id: null,
                        modifierId: modifierArg?.id ?? 0,
                        name: '',
                        tempKey: DateTime.now().millisecondsSinceEpoch
                            .toString(),
                      ),
                    );
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Option'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionRow(ModifierOption option) {
    final key = option.id?.toString() ?? option.tempKey;

    _nameControllers.putIfAbsent(
      key,
      () => TextEditingController(text: option.name),
    );
    _priceControllers.putIfAbsent(
      key,
      () => TextEditingController(
        text: option.price == null ? '' : option.price!.toString(),
      ),
    );

    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              flex: 7,
              child: FormBuilderTextField(
                name: 'optionName_$key',
                controller: _nameControllers[key],
                decoration: const InputDecoration(labelText: 'Option Name'),
                validator: FormBuilderValidators.required(),
              ),
            ),
            SizedBox(width: 50),
            Expanded(
              flex: 3,
              child: FormBuilderTextField(
                name: 'price_$key',
                controller: _priceControllers[key],
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: '₱ ',
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                  FormBuilderValidators.min(0),
                ]),
              ),
            ),
            SizedBox(width: 50),
            IconButton(
              onPressed: () {
                setState(() {
                  _options.remove(option);
                  _nameControllers.remove(key);
                  _priceControllers.remove(key);
                });
              },
              icon: Icon(Icons.delete),
            ),
          ],
        ),
      ],
    );
  }
}
