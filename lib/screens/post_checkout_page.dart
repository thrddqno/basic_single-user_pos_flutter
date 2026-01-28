import 'package:basic_single_user_pos_flutter/providers/cart_provider.dart';
import 'package:basic_single_user_pos_flutter/providers/receipt_provider.dart';
import 'package:basic_single_user_pos_flutter/widgets/ticket_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostCheckoutPage extends StatefulWidget {
  const PostCheckoutPage({super.key});

  @override
  State<PostCheckoutPage> createState() => _PostCheckoutPageState();
}

class _PostCheckoutPageState extends State<PostCheckoutPage> {
  @override
  Widget build(BuildContext context) {
    final receipt = context.watch<ReceiptProvider>().latestReceipt;
    final cartProvider = context.read<CartProvider>();

    if (receipt == null) {
      return const Scaffold(body: Center(child: Text('No receipt found')));
    }

    final total = receipt.total;

    final isCash = receipt.paymentMethod == 'cash';

    final totalPaid = isCash ? (receipt.cashReceived ?? total) : total;

    final change = isCash ? totalPaid - total : 0;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
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
              child: TicketWidget(readOnly: true),
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 25),
                  alignment: Alignment.bottomCenter,
                  height: 100,
                  decoration: BoxDecoration(color: Colors.teal),
                ),

                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 1),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 20,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '₱${totalPaid.toStringAsFixed(2)}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Total Paid',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              if (isCash) ...[
                                VerticalDivider(),
                                Column(
                                  children: [
                                    Text(
                                      '₱${change.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Change',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade200),
                            minimumSize: Size(double.infinity, 60),
                            shape: BeveledRectangleBorder(),
                            elevation: 0,
                            backgroundColor: Colors.teal,
                          ),
                          onPressed: () {
                            cartProvider.clear();
                            Navigator.pushReplacementNamed(context, '/sale');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 10,
                            children: [
                              Icon(Icons.check, color: Colors.white),
                              Text(
                                'New Sale',
                                style: TextStyle(
                                  color: Colors.white,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
