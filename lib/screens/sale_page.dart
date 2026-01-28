import 'package:basic_single_user_pos_flutter/helpers/color_helper.dart';
import 'package:basic_single_user_pos_flutter/widgets/drawer_widget.dart';
import 'package:basic_single_user_pos_flutter/widgets/ticket_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:basic_single_user_pos_flutter/providers/category_provider.dart';
import 'package:basic_single_user_pos_flutter/providers/product_provider.dart';
import 'package:basic_single_user_pos_flutter/models/product.dart';
import 'package:basic_single_user_pos_flutter/providers/modifier_provider.dart';
import 'package:basic_single_user_pos_flutter/models/modifier.dart';

class SalePage extends StatefulWidget {
  const SalePage({super.key});

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final selectedId = categoryProvider.selectedCategoryId;
    final selectedName = categoryProvider.selectedCategoryName;

    return Scaffold(
      drawer: DrawerWidget(
        currentRoute: ModalRoute.of(context)!.settings.name ?? '',
      ),
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 25),
                  alignment: Alignment.bottomCenter,
                  height: 100,
                  decoration: BoxDecoration(color: Colors.teal),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Builder(
                            builder: (context) => IconButton(
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                              },
                              icon: Icon(
                                FontAwesomeIcons.bars,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            selectedName,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Consumer<ProductProvider>(
                          builder: (context, productProvider, _) {
                            final allProducts = productProvider.products;

                            final filteredProducts = selectedId == null
                                ? allProducts
                                : allProducts
                                      .where((p) => p.categoryId == selectedId)
                                      .toList();

                            if (filteredProducts.isEmpty) {
                              return const Center(
                                child: Text('No products in this category'),
                              );
                            }

                            return GridView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: filteredProducts.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 5,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 1.2,
                                  ),
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                return _ProductTile(product: product);
                              },
                            );
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: Offset(0, -4),
                              ),
                            ],
                          ),
                          height: 100,

                          child: Consumer<CategoryProvider>(
                            builder: (context, categoryProvider, _) {
                              final categories = categoryProvider.categories;

                              if (categories.isEmpty) {
                                return const Center(
                                  child: Text('No categories'),
                                );
                              }

                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: categories.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == categories.length) {
                                    return _AllCategoryButton(
                                      isSelected: selectedId == null,
                                      onTap: () {
                                        categoryProvider.selectCategory(
                                          null,
                                          'All',
                                        );
                                      },
                                    );
                                  }

                                  final category = categories[index];

                                  return _CategoryRow(
                                    name: category.name,
                                    isSelected: selectedId == category.id,
                                    onTap: () {
                                      categoryProvider.selectCategory(
                                        category.id,
                                        category.name,
                                      );
                                    },

                                    onIconTap: () {},
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  Expanded(child: TicketWidget()),

                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        backgroundColor: Colors.teal,
                        minimumSize: Size(double.infinity, 70),
                      ),
                      child: Text(
                        'Charge',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllCategoryButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _AllCategoryButton({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isSelected ? Colors.teal : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Icon(
          Icons.grid_view,
          color: isSelected ? Colors.teal : Colors.black54,
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onIconTap;

  const _CategoryRow({
    required this.name,
    required this.isSelected,
    required this.onTap,
    required this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    if (name == 'No Category') {
      return SizedBox.shrink();
    }
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isSelected ? Colors.teal : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;

  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final modifierProvider = context.read<ModifierProvider>();

        if (product.enabledModifierIds.isNotEmpty) {
          final Map<int, Set<int>> selectedOptionsPerModifier = {};

          showDialog(
            context: context,
            builder: (_) => Dialog(
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
                            product.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'ADD',
                            style: TextStyle(color: Colors.teal),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Expanded(
                      child: ListView(
                        children: [
                          ...product.enabledModifierIds.map((modifierId) {
                            final modifier = modifierProvider.modifiers
                                .firstWhere(
                                  (m) => m.id == modifierId,
                                  orElse: () => Modifier(
                                    id: modifierId,
                                    name: 'Unknown Modifier',
                                  ),
                                );

                            final options = modifierProvider.optionsForModifier(
                              modifierId,
                            );

                            selectedOptionsPerModifier.putIfAbsent(
                              modifierId,
                              () => {},
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
                                          if (isSelected) {
                                            selectedOptionsPerModifier[modifierId]!
                                                .remove(option.id);
                                          } else {
                                            selectedOptionsPerModifier[modifierId]!
                                                .add(option.id!);
                                          }

                                          (context as Element).markNeedsBuild();
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.teal.withValues(
                                                    alpha: 0.3,
                                                  )
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.teal
                                                  : Colors.grey.withValues(
                                                      alpha: 0.3,
                                                    ),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(option.name),
                                              Text(
                                                '₱ ${option.price.toString()}',
                                              ),
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[100],
                                        foregroundColor: Colors
                                            .black, // icon color// square size
                                        shape: RoundedRectangleBorder(
                                          // small rounded corners
                                          side: BorderSide(
                                            color: Colors.grey, // border color
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {},
                                      child: Icon(Icons.remove),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        labelText: 'Quantity',
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[100],
                                        foregroundColor: Colors
                                            .black, // icon color// square size
                                        shape: RoundedRectangleBorder(
                                          // small rounded corners
                                          side: BorderSide(
                                            color: Colors.grey, // border color
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {},
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
            ),
          );
        } else {
          debugPrint('Added ${product.name} to ticket directly');
        }
      },

      child: Container(
        decoration: BoxDecoration(
          color: ColorHelper.fromHex(product.color).withValues(),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 6),
            Text(
              product.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '₱${product.price.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
