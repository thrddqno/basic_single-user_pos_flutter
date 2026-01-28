import 'package:flutter/material.dart';
import 'package:basic_single_user_pos_flutter/widgets/ticket_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
