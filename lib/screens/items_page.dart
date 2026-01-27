import 'package:basic_single_user_pos_flutter/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                //add product
                Expanded(
                  child: ClipRRect(
                    child: Container(
                      margin: EdgeInsets.only(left: 1),
                      clipBehavior: Clip.none,
                      color: Colors.white,
                      child: Stack(
                        children: [
                          ListView(children: [
                                
                              ],
                            ),
                          Positioned(
                            right: 24,
                            bottom: 24,
                            child: FloatingActionButton(
                              shape: CircleBorder(),
                              backgroundColor: Colors.teal,
                              elevation: 1,
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/addProduct'),
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
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
