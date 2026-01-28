import 'package:basic_single_user_pos_flutter/helpers/bills_helper.dart';
import 'package:basic_single_user_pos_flutter/providers/cart_provider.dart';
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
                        // Total Amount
                        Text(
                          '₱${context.read<CartProvider>().total.toStringAsFixed(2)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total Amount Due',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),

                        SizedBox(height: 100),

                        // Cash Received
                        Row(
                          children: [
                            Icon(Icons.payments, color: Colors.grey),
                            SizedBox(width: 16),
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'cashReceived',
                                initialValue: context
                                    .read<CartProvider>()
                                    .total
                                    .toString(),
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
                              onPressed: () {},
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

                        Row(
                          spacing: 20,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              BillsHelper.predictChange(
                                context.read<CartProvider>().total,
                              ).map((value) {
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
                                    onPressed: () {},
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
                        ),

                        SizedBox(height: 24),

                        // Card Payment Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade200),
                            minimumSize: Size(double.infinity, 60),
                            shape: BeveledRectangleBorder(),
                            elevation: 0,
                            backgroundColor: Colors.grey.shade100,
                          ),
                          onPressed: () {},
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
