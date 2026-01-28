import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DrawerWidget extends StatelessWidget {
  final String currentRoute;

  const DrawerWidget({required this.currentRoute, super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SimplePOS',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Biboy\'s Ice Cream and Waffles',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          DrawerTile(
            icon: FontAwesomeIcons.basketShopping,
            label: 'Sale',
            routeName: '/sale',
            currentRoute: currentRoute,
          ),
          DrawerTile(
            icon: FontAwesomeIcons.list,
            label: 'Items',
            routeName: '/items',
            currentRoute: currentRoute,
          ),
          DrawerTile(
            icon: FontAwesomeIcons.receipt,
            label: 'Transactions',
            routeName: '/receiptsPage',
            currentRoute: currentRoute,
          ),
        ],
      ),
    );
  }
}

class DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String routeName;
  final String currentRoute;

  const DrawerTile({
    required this.icon,
    required this.label,
    required this.routeName,
    required this.currentRoute,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = routeName == currentRoute;

    return ListTile(
      tileColor: selected ? Colors.black12 : null,
      hoverColor: Colors.teal.shade50,
      onTap: () {
        if (selected) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, routeName);
        }
      },
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
    );
  }
}
