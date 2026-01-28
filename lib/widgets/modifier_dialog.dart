import 'package:flutter/material.dart';
import 'package:basic_single_user_pos_flutter/models/product.dart';
import 'package:basic_single_user_pos_flutter/models/modifier.dart';
import 'package:basic_single_user_pos_flutter/models/cart_item.dart';
import 'package:basic_single_user_pos_flutter/providers/modifier_provider.dart';
import 'package:basic_single_user_pos_flutter/providers/cart_provider.dart';

class ModifierDialog extends StatefulWidget {
  final Product product;
  final ModifierProvider modifierProvider;
  final CartProvider cartProvider;
  final CartItem? editingItem;
  final int? editingItemIndex;

  const ModifierDialog({
    super.key,
    required this.product,
    required this.modifierProvider,
    required this.cartProvider,
    this.editingItem,
    this.editingItemIndex,
  });

  @override
  State<ModifierDialog> createState() => _ModifierDialogState();
}

class _ModifierDialogState extends State<ModifierDialog> {
  late final Map<int, Set<int>> selectedOptionsPerModifier;
  late final TextEditingController quantityController;

  @override
  void initState() {
    super.initState();
    selectedOptionsPerModifier = {};

    if (widget.editingItem != null) {
      for (var entry in widget.editingItem!.selectedModifiers.entries) {
        selectedOptionsPerModifier[entry.key] = Set<int>.from(entry.value);
      }
      quantityController = TextEditingController(
        text: widget.editingItem!.quantity.toString(),
      );
    } else {
      for (int modifierId in widget.product.enabledModifierIds) {
        selectedOptionsPerModifier[modifierId] = {};
      }
      quantityController = TextEditingController(text: '1');
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final quantity = int.tryParse(quantityController.text) ?? 1;

    if (quantity == 0) {
      if (widget.editingItemIndex != null) {
        widget.cartProvider.removeItem(widget.editingItemIndex!);
      }
    } else {
      if (widget.editingItem != null && widget.editingItemIndex != null) {
        widget.cartProvider.removeItem(widget.editingItemIndex!);
        widget.cartProvider.addItem(
          widget.product,
          quantity,
          selectedOptionsPerModifier,
        );
      } else {
        widget.cartProvider.addItem(
          widget.product,
          quantity,
          selectedOptionsPerModifier,
        );
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 100, vertical: 24),
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.clear),
                ),
                Expanded(
                  child: Text(
                    widget.product.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: _saveChanges,
                  child: Text(
                    widget.editingItem != null ? 'SAVE' : 'ADD',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: ListView(
                children: [
                  ...widget.product.enabledModifierIds.map((modifierId) {
                    final modifier = widget.modifierProvider.modifiers
                        .firstWhere(
                          (m) => m.id == modifierId,
                          orElse: () => Modifier(
                            id: modifierId,
                            name: 'Unknown Modifier',
                          ),
                        );

                    final options = widget.modifierProvider.optionsForModifier(
                      modifierId,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8,
                          ),
                          child: Text(
                            modifier.name,
                            style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          height:
                              ((options.length / 2).ceil() * 55) +
                              ((options.length / 2).ceil() * 16),
                          child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: options.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 10,
                                ),
                            itemBuilder: (context, index) {
                              final option = options[index];
                              final isSelected =
                                  selectedOptionsPerModifier[modifierId]!
                                      .contains(option.id);

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedOptionsPerModifier[modifierId]!
                                          .remove(option.id);
                                    } else {
                                      selectedOptionsPerModifier[modifierId]!
                                          .add(option.id!);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.teal.withValues(alpha: 0.3)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.teal
                                          : Colors.grey.withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(option.name),
                                      Text('₱ ${option.price.toString()}'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Quantity',
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[100],
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                final current =
                                    int.tryParse(quantityController.text) ?? 1;
                                if (current > 0) {
                                  setState(() {
                                    quantityController.text = (current - 1)
                                        .toString();
                                  });
                                }
                              },
                              child: Icon(Icons.remove),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[100],
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                final current =
                                    int.tryParse(quantityController.text) ?? 1;
                                setState(() {
                                  quantityController.text = (current + 1)
                                      .toString();
                                });
                              },
                              child: Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
