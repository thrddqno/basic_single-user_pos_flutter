import 'package:basic_single_user_pos_flutter/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:basic_single_user_pos_flutter/providers/product_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  String selectedTab = 'Items';
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
                      _menuButton('Categories', FontAwesomeIcons.borderAll),
                      _menuButton('Modifiers', FontAwesomeIcons.pen),
                    ],
                  ),
                ),

                //right page
                Expanded(
                  child: Stack(
                    children: [
                      // List of products
                      Consumer<ProductProvider>(
                        builder: (context, productProvider, child) {
                          final products = productProvider.products;

                          if (products.isEmpty) {
                            return Center(
                              child: Text(
                                "No items found. Add an item!",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black45,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(product.name),
                                  subtitle: Text(
                                    '₱${product.price.toStringAsFixed(2)}',
                                  ),
                                  trailing: Icon(Icons.edit),
                                  onTap: () {},
                                ),
                              );
                            },
                          );
                        },
                      ),

                      // FloatingActionButton
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton(
                          elevation: 1,
                          backgroundColor: Colors.teal,
                          shape: CircleBorder(),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/addProduct'),
                          child: Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
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
}
