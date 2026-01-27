import 'package:basic_single_user_pos_flutter/helpers/color_helper.dart';
import 'package:basic_single_user_pos_flutter/models/modifier.dart';
import 'package:basic_single_user_pos_flutter/models/product.dart';
import 'package:basic_single_user_pos_flutter/widgets/drawer_widget.dart';
import 'package:basic_single_user_pos_flutter/models/category.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:basic_single_user_pos_flutter/providers/modifier_provider.dart';
import 'package:basic_single_user_pos_flutter/providers/product_provider.dart';
import 'package:basic_single_user_pos_flutter/providers/category_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  String selectedTab = 'Items';

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
    return Scaffold(
      drawer: DrawerWidget(
        currentRoute: ModalRoute.of(context)!.settings.name ?? '',
      ),
      body: Column(
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
                        icon: Icon(FontAwesomeIcons.bars, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      selectedTab,
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
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: Offset(2, 0),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  width: 300,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _menuButton('Items', FontAwesomeIcons.list),
                      _menuButton('Categories', FontAwesomeIcons.layerGroup),
                      _menuButton('Modifiers', FontAwesomeIcons.solidClone),
                    ],
                  ),
                ),

                //right page
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 1),
                    color: Colors.white,
                    child: Stack(
                      children: [
                        ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            if (selectedTab == 'Items') ...[
                              ...context.watch<ProductProvider>().products.map((
                                product,
                              ) {
                                final category = context
                                    .read<CategoryProvider>()
                                    .categories
                                    .firstWhere(
                                      (c) => c.id == product.categoryId,
                                    );
                                return _productTile(product, category.name);
                              }),
                            ] else if (selectedTab == 'Categories') ...[
                              ...context
                                  .watch<CategoryProvider>()
                                  .categories
                                  .map((category) {
                                    return _categoryTile(category);
                                  }),
                            ] else if (selectedTab == 'Modifiers') ...[
                              ...context
                                  .watch<ModifierProvider>()
                                  .modifiers
                                  .map((modifier) {
                                    return _modifierTile(modifier);
                                  }),
                            ],
                          ],
                        ),
                        Positioned(
                          right: 24,
                          bottom: 24,
                          child: FloatingActionButton(
                            shape: CircleBorder(),
                            backgroundColor: Colors.teal,
                            elevation: 1,
                            onPressed: () {
                              if (selectedTab == 'Items') {
                                Navigator.pushNamed(context, '/addProduct');
                              } else if (selectedTab == 'Categories') {
                                Navigator.pushNamed(context, '/addCategory');
                              } else if (selectedTab == 'Modifiers') {
                                Navigator.pushNamed(context, '/addModifier');
                              }
                            },
                            child: Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // case modifiers

                // case categories
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuButton(String label, IconData icon) {
    bool selected = selectedTab == label;

    return Container(
      color: selected ? Colors.black12 : null,
      child: ListTile(
        hoverColor: Colors.teal.shade50,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.only(left: 8, right: 32),
              child: Icon(
                icon,
                color: selected ? Colors.teal : Colors.black45,
                size: 20,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.teal : Colors.black,
                fontSize: 16,
                fontWeight: selected ? FontWeight.bold : FontWeight.w400,
              ),
            ),
          ],
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        onTap: () {
          if (!selected) {
            setState(() {
              selectedTab = label;
            });
          }
        },
      ),
    );
  }

  Widget _productTile(Product product, String categoryName) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ColorHelper.fromHex(product.color),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.black12, width: 1),
            ),
          ),
          title: Text(
            product.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            categoryName,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          trailing: Text(
            '₱ ${product.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          onTap: () {
            debugPrint(product.toString());
            Navigator.pushNamed(context, '/addProduct', arguments: product);
          },
        ),
        Divider(color: Colors.grey.shade300, thickness: 1),
      ],
    );
  }

  Widget _categoryTile(Category category) {
    if (category.name == 'No Category') {
      return SizedBox.shrink();
    }
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          title: Text(
            category.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            debugPrint(category.toString());
            Navigator.pushNamed(context, '/addCategory', arguments: category);
          },
        ),
        Divider(color: Colors.grey.shade300, thickness: 1),
      ],
    );
  }

  Widget _modifierTile(Modifier modifier) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          title: Text(
            modifier.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            debugPrint(modifier.toString());
            Navigator.pushNamed(context, '/addModifier', arguments: modifier);
          },
        ),
        Divider(color: Colors.grey.shade300, thickness: 1),
      ],
    );
  }
}
