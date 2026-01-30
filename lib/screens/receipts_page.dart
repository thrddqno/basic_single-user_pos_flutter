import 'package:basic_single_user_pos_flutter/helpers/price_helper.dart';
import 'package:basic_single_user_pos_flutter/models/receipt.dart';
import 'package:basic_single_user_pos_flutter/providers/receipt_provider.dart';
import 'package:basic_single_user_pos_flutter/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ReceiptsPage extends StatefulWidget {
  const ReceiptsPage({super.key});

  @override
  State<ReceiptsPage> createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptsPage> {
  Receipt? _selectedReceipt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReceiptProvider>().loadIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final receipts = context.watch<ReceiptProvider>().receipts;
    final groupedReceipts = _groupReceiptsByDate(receipts);
    final dates = groupedReceipts.keys.toList()..sort((a, b) => b.compareTo(a));

    final List<dynamic> listItems = [];
    for (final date in dates) {
      listItems.add(date);
      final receiptsForDate = groupedReceipts[date]!;
      receiptsForDate.sort((a, b) => b.date.compareTo(a.date));
      listItems.addAll(receiptsForDate);
    }

    return Scaffold(
      drawer: DrawerWidget(
        currentRoute: ModalRoute.of(context)!.settings.name ?? '',
      ),
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 25,
                      ),
                      alignment: Alignment.bottomCenter,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            offset: Offset(2, 0),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
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
                            'Receipts',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
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
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: listItems.length,
                                itemBuilder: (context, index) {
                                  final item = listItems[index];

                                  if (item is DateTime) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 20,
                                      ),
                                      child: Text(
                                        '${_getDayName(item)}, ${_getMonthName(item)} ${item.day}, ${item.year}',
                                        style: TextStyle(
                                          color: Colors.teal[800],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  }

                                  final receipt = item as Receipt;
                                  return Column(
                                    children: [
                                      Container(
                                        color:
                                            _selectedReceipt?.id == receipt.id
                                            ? Colors.grey.withValues(alpha: 0.5)
                                            : Colors.transparent,
                                        child: ListTile(
                                          leading: Icon(
                                            receipt.paymentMethod
                                                        .toLowerCase() ==
                                                    'cash'
                                                ? Icons.payments
                                                : Icons.payment,
                                            color: Colors.grey[600],
                                          ),
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '₱${formatPrice(receipt.total)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Text(
                                                '#${receipt.id}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          subtitle: Text(
                                            '${receipt.date.hour % 12}:${receipt.date.minute.toString().padLeft(2, '0')} ${receipt.date.hour >= 12 ? 'PM' : 'AM'}',
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _selectedReceipt = receipt;
                                            });
                                          },
                                        ),
                                      ),
                                      const Divider(height: 1, indent: 70),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: _selectedReceipt == null
                    ? const Center(
                        child: Text("Select a receipt to view details"),
                      )
                    : Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 0.5),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 25,
                            ),
                            alignment: Alignment.bottomCenter,
                            height: 100,
                            decoration: const BoxDecoration(color: Colors.teal),
                            child: Row(
                              children: [
                                const Icon(
                                  FontAwesomeIcons.receipt,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Receipt #${_selectedReceipt!.id}',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 100,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    offset: Offset(0, 0),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(70),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '₱${formatPrice(_selectedReceipt!.total)}',
                                      style: TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Total',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    const Divider(),
                                    SizedBox(height: 8),
                                    Row(
                                      spacing: 8,
                                      children: [
                                        Text(
                                          'Business Name: ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Text(
                                          'Biboy\'s Ice Cream and Waffles',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    const Divider(),
                                    SizedBox(height: 8),

                                    ..._selectedReceipt!.items.map(
                                      (item) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '${item.product.name} x${item.quantity}',
                                                ),
                                                Text(
                                                  '₱${formatPrice(item.total)}',
                                                ),
                                              ],
                                            ),
                                            if (item.options.isNotEmpty)
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  item.options
                                                      .map((opt) => opt.name)
                                                      .join(', '),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    const Divider(),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Total',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '₱${formatPrice(_selectedReceipt!.total)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    if (_selectedReceipt!.paymentMethod ==
                                        'cash') ...[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Cash Received'),
                                          Text(
                                            '₱${formatPrice(_selectedReceipt!.cashReceived)}',
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Change'),
                                          Text(
                                            '₱${formatPrice(_selectedReceipt!.cashReceived! - _selectedReceipt!.total)}',
                                          ),
                                        ],
                                      ),
                                    ] else ...[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Card'),
                                          Text(
                                            '₱${formatPrice(_selectedReceipt!.total)}',
                                          ),
                                        ],
                                      ),
                                    ],
                                    SizedBox(height: 8),
                                    const Divider(),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatFullDate(
                                            _selectedReceipt!.date,
                                          ),
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Text(
                                          'Receipt #${_selectedReceipt!.id}',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
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
          _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    final isLoading = context.watch<ReceiptProvider>().isLoading;

    if (!isLoading) return const SizedBox.shrink();

    return IgnorePointer(
      ignoring: true,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: Offset(2, 0),
                blurRadius: 2,
              ),
            ],
          ),

          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    String yyyy = date.year.toString();
    String dd = date.day.toString().padLeft(2, '0');
    String mm = date.month.toString().padLeft(2, '0');

    int hour = date.hour % 12;
    if (hour == 0) hour = 12;
    String hh = hour.toString().padLeft(2, '0');

    String min = date.minute.toString().padLeft(2, '0');
    String period = date.hour >= 12 ? 'PM' : 'AM';

    return '$yyyy-$dd-$mm $hh:$min $period';
  }

  Map<DateTime, List<Receipt>> _groupReceiptsByDate(List<Receipt> receipts) {
    final Map<DateTime, List<Receipt>> grouped = {};

    final sortedReceipts = List<Receipt>.from(receipts)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final receipt in sortedReceipts) {
      final dateKey = DateTime(
        receipt.date.year,
        receipt.date.month,
        receipt.date.day,
      );

      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(receipt);
    }

    return grouped;
  }

  String _getDayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  String _getMonthName(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[date.month - 1];
  }
}
