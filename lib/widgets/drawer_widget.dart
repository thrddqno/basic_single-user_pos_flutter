import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

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
            onTap: () => (),
          ),
          DrawerTile(
            icon: FontAwesomeIcons.list,
            label: 'Items',
            onTap: () => (),
          ),
          DrawerTile(
            icon: FontAwesomeIcons.receipt,
            label: 'Transactions',
            onTap: () => (),
          ),
          DrawerTile(
            icon: FontAwesomeIcons.chartSimple,
            label: 'Analytics',
            onTap: () => (),
          ),
          Divider(),
          DrawerTile(
            icon: FontAwesomeIcons.circleQuestion,
            label: 'Help',
            onTap: () => (),
          ),
          DrawerTile(
            icon: FontAwesomeIcons.gear,
            label: 'Settings',
            onTap: () => (),
          ),
        ],
      ),
    );
  }
}

class DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      hoverColor: Colors.teal.shade100,
      onTap: onTap,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: 8, right: 32),
            child: Icon(icon, color: Colors.black45, size: 20),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
