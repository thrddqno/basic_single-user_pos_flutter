import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TicketWidget extends StatelessWidget {
  const TicketWidget({super.key});

  static const double headerHeight = 100;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Cart content (goes UNDER the header)
        Padding(
          padding: const EdgeInsets.only(top: headerHeight),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                //cart items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    children: [
                      TicketItem(
                        productName: 'Bread',
                        qty: 2,
                        itemTotal: 102,
                        modifierOptions: 'chicken, pasta, shit',
                      ),
                      TicketItem(
                        productName: 'Wafer Cone',
                        qty: 2,
                        itemTotal: 30,
                        modifierOptions: '',
                      ),
                    ],
                  ),
                ),

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
                        'PriceTotal',
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

        // ── Cart header (floats ABOVE)
        Material(
          elevation: 2,
          color: Colors.white,
          child: Container(
            height: headerHeight,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 25),
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
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    FontAwesomeIcons.ellipsisVertical,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TicketItem extends StatelessWidget {
  final String productName;
  final int qty;
  final int itemTotal;
  final String? modifierOptions;

  const TicketItem({
    required this.productName,
    required this.qty,
    required this.itemTotal,
    this.modifierOptions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // spacing between items
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$productName x$qty',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
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

          // Item total
          Text(
            '₱$itemTotal',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
