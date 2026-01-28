import 'package:basic_single_user_pos_flutter/helpers/bills_helper.dart';
import 'package:basic_single_user_pos_flutter/models/modifier_option.dart';
import 'package:basic_single_user_pos_flutter/models/receipt.dart';
import 'package:basic_single_user_pos_flutter/models/receipt_item.dart';
import 'package:basic_single_user_pos_flutter/providers/cart_provider.dart';
import 'package:basic_single_user_pos_flutter/providers/modifier_provider.dart';
import 'package:basic_single_user_pos_flutter/providers/receipt_provider.dart';
import 'package:flutter/material.dart';
import 'package:basic_single_user_pos_flutter/widgets/ticket_widget.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class CheckOutCart extends StatefulWidget {
  const CheckOutCart({super.key});

  @override
  State<CheckOutCart> createState() => _CheckOutCartState();
}

class _CheckOutCartState extends State<CheckOutCart> {
  late TextEditingController _cashController;

  @override
  void initState() {
    super.initState();
    final total = context.read<CartProvider>().total;
    _cashController = TextEditingController(text: total.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  void _checkout({required String method}) async {
    final cartProvider = context.read<CartProvider>();
    final modifierProvider = context.read<ModifierProvider>();
    final receiptProvider = context.read<ReceiptProvider>();

    double? cashReceived;
    if (method == 'cash') {
      cashReceived = double.tryParse(_cashController.text);
      if (cashReceived == null || cashReceived < cartProvider.total) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cash received must cover total amount!')),
        );
        return;
      }
    }

    final receiptItems = cartProvider.items.map((cartItem) {
      final options = <ModifierOption>[];

      cartItem.selectedModifiers.forEach((modifierId, optionIds) {
        final availableOptions = modifierProvider.optionsForModifier(
          modifierId,
        );

        for (var optionId in optionIds) {
          final option = availableOptions.firstWhere((o) => o.id == optionId);
          options.add(option);
        }
      });

      return ReceiptItem(
        product: cartItem.product,
        options: options,
        quantity: cartItem.quantity,
      );
    }).toList();

    final receipt = Receipt(
      date: DateTime.now(),
      items: receiptItems,
      paymentMethod: method,
      cashReceived: cashReceived,
    );

    await receiptProvider.createReceipt(receipt);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/postCheckOut');
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Builder(
                            builder: (context) => IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                FontAwesomeIcons.arrowLeft,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 1),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Selector<CartProvider, double>(
                          selector: (_, cart) => cart.total,
                          builder: (context, total, _) => Text(
                            '₱${total.toStringAsFixed(2)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'Total Amount Due',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),

                        SizedBox(height: 100),

                        Row(
                          children: [
                            Icon(Icons.payments, color: Colors.grey),
                            SizedBox(width: 16),
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'cashReceived',
                                controller: _cashController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Cash Received',

                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(120, 60),
                                shape: BeveledRectangleBorder(),
                                elevation: 0,
                                backgroundColor: Colors.teal,
                              ),
                              onPressed: () => _checkout(method: 'cash'),
                              child: Text(
                                'CHARGE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24),

                        Selector<CartProvider, double>(
                          selector: (_, cart) => cart.total,
                          builder: (context, total, _) {
                            return Row(
                              spacing: 20,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: BillsHelper.predictChange(total).map((
                                value,
                              ) {
                                return Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      side: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                      minimumSize: Size(120, 60),
                                      shape: BeveledRectangleBorder(),
                                      elevation: 0,
                                      backgroundColor: Colors.grey.shade100,
                                    ),
                                    onPressed: () {
                                      _cashController.text = value.toString();
                                      _checkout(method: 'cash');
                                    },
                                    child: Text(
                                      value.toString(),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),

                        SizedBox(height: 24),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade200),
                            minimumSize: Size(double.infinity, 60),
                            shape: BeveledRectangleBorder(),
                            elevation: 0,
                            backgroundColor: Colors.grey.shade100,
                          ),
                          onPressed: () => _checkout(method: 'card'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 10,
                            children: [
                              Icon(Icons.payment, color: Colors.grey.shade600),
                              Text(
                                'Card',
                                style: TextStyle(
                                  color: Colors.black,
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
