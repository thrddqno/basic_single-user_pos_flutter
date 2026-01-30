import 'package:basic_single_user_pos_flutter/helpers/price_helper.dart';
import 'package:basic_single_user_pos_flutter/widgets/modifier_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:basic_single_user_pos_flutter/providers/cart_provider.dart';
import 'package:basic_single_user_pos_flutter/providers/modifier_provider.dart';

class TicketWidget extends StatelessWidget {
  final bool readOnly;

  const TicketWidget({super.key, this.readOnly = false});

  static const double headerHeight = 100;

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: headerHeight),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: cartProvider.items.length,
                        itemBuilder: (context, index) {
                          final item = cartProvider.items[index];
                          final modifierProvider = context
                              .read<ModifierProvider>();

                          final modifierNames = item.selectedModifiers.entries
                              .expand(
                                (entry) => entry.value.map((optionId) {
                                  return modifierProvider
                                          .optionById(optionId)
                                          ?.name ??
                                      'Unknown';
                                }),
                              )
                              .where((name) => name.isNotEmpty)
                              .join(", ");

                          double modifierTotal = 0;
                          for (final entry in item.selectedModifiers.entries) {
                            for (final optionId in entry.value) {
                              final opt = modifierProvider.optionById(optionId);
                              if (opt != null) {
                                modifierTotal += opt.price ?? 0;
                              }
                            }
                          }

                          final itemTotal =
                              (item.product.price + modifierTotal) *
                              item.quantity;

                          return readOnly
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: TicketItem(
                                    index: index,
                                    productName: item.product.name,
                                    qty: item.quantity,
                                    itemTotal: itemTotal,
                                    modifierOptions: modifierNames,
                                    readOnly: true,
                                  ),
                                )
                              : Dismissible(
                                  key: ValueKey('${item.product.id}-$index'),
                                  direction: DismissDirection.endToStart,
                                  dismissThresholds: {
                                    DismissDirection.endToStart: 0.3,
                                  },
                                  resizeDuration: Duration(milliseconds: 100),
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    color: Colors.red,
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  onDismissed: (_) {
                                    context.read<CartProvider>().removeItem(
                                      index,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: TicketItem(
                                      index: index,
                                      productName: item.product.name,
                                      qty: item.quantity,
                                      itemTotal: itemTotal,
                                      modifierOptions: modifierNames,
                                      readOnly: false,
                                    ),
                                  ),
                                );
                        },
                      ),
                    ),
                    Divider(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₱${formatPrice(cartProvider.total)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Material(
              elevation: 2,
              color: Colors.white,
              child: Container(
                height: headerHeight,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 25,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cart',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    if (!readOnly)
                      PopupMenuButton<String>(
                        onSelected: (value) => value == 'clear'
                            ? context.read<CartProvider>().clear()
                            : '',
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'clear',
                            child: Text('Clear Cart'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class TicketItem extends StatelessWidget {
  final int index;
  final String productName;
  final int qty;
  final double itemTotal;
  final String? modifierOptions;
  final bool readOnly;

  const TicketItem({
    required this.index,
    required this.productName,
    required this.qty,
    required this.itemTotal,
    this.modifierOptions,
    this.readOnly = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: readOnly
          ? null
          : () {
              final cartProvider = context.read<CartProvider>();
              final modifierProvider = context.read<ModifierProvider>();
              final item = cartProvider.items[index];

              showDialog(
                context: context,
                builder: (_) => ModifierDialog(
                  product: item.product,
                  modifierProvider: modifierProvider,
                  cartProvider: cartProvider,
                  editingItem: item,
                  editingItemIndex: index,
                ),
              );
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'x${qty.toString()}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (modifierOptions!.isNotEmpty)
                    Text(
                      modifierOptions!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),

            Text(
              '₱${formatPrice(itemTotal)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
