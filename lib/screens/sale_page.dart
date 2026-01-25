import 'package:basic_single_user_pos_flutter/widgets/drawer_widget.dart';
import 'package:basic_single_user_pos_flutter/widgets/ticket_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SalePage extends StatefulWidget {
  const SalePage({super.key});

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(
        currentRoute: ModalRoute.of(context)!.settings.name ?? '',
      ),
      body: Row(
        children: [
          //sales page main
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
                                Scaffold.of(context).openDrawer();
                              },
                              icon: Icon(
                                FontAwesomeIcons.bars,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Sale',
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
                Expanded(child: Container(margin: EdgeInsets.only(top: 8))),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    offset: Offset(-2, 0),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(child: TicketWidget()),

                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        backgroundColor: Colors.teal,
                        minimumSize: Size(double.infinity, 70),
                      ),
                      child: Text(
                        'Charge',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
