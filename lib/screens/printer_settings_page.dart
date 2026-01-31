import 'package:basic_single_user_pos_flutter/providers/printer_provider.dart';
import 'package:basic_single_user_pos_flutter/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});

  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final printerProvider = context.watch<PrinterProvider>();

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
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        icon: Icon(FontAwesomeIcons.bars, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Settings',
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: printerProvider.isScanning
                            ? null
                            : () => printerProvider.startScan(),
                        icon: Icon(Icons.search),
                        label: Text('Scan Printers'),
                      ),
                      ElevatedButton.icon(
                        onPressed: printerProvider.isScanning
                            ? () => printerProvider.stopScan()
                            : null,
                        icon: Icon(Icons.stop),
                        label: Text('Stop'),
                      ),
                      if (printerProvider.isScanning)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12),

                  if (printerProvider.connectedPrinter != null)
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Connected to Printer',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                Text(
                                  printerProvider.connectedPrinter!.name ??
                                      'Unknown',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                printerProvider.disconnectPrinter(),
                            child: Text('Disconnect'),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 16),

                  Text(
                    'Available Printers',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  Expanded(
                    child: printerProvider.printers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.print, size: 48, color: Colors.grey),
                                SizedBox(height: 12),
                                Text(
                                  'No printers found',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Tap "Scan Printers" to find available devices',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: printerProvider.printers.length,
                            separatorBuilder: (_, __) => Divider(),
                            itemBuilder: (context, index) {
                              final printer = printerProvider.printers[index];
                              final isConnected =
                                  printerProvider.connectedPrinter?.name ==
                                  printer.name;

                              return Card(
                                margin: EdgeInsets.zero,
                                child: ListTile(
                                  leading: Icon(
                                    isConnected
                                        ? Icons.check_circle
                                        : Icons.print,
                                    color: isConnected
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  title: Text(
                                    printer.name ?? 'Unknown Printer',
                                  ),
                                  subtitle: Text(
                                    '${printer.address ?? 'N/A'} • ${printer.connectionTypeString}',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: isConnected
                                        ? () => printerProvider
                                              .disconnectPrinter()
                                        : () => printerProvider.connectPrinter(
                                            printer,
                                          ),
                                    child: Text(
                                      isConnected ? 'Disconnect' : 'Connect',
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  if (printerProvider.lastError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                printerProvider.lastError!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  SizedBox(height: 12),

                  if (printerProvider.connectedPrinter != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: printerProvider.isPrinting
                            ? null
                            : () => _testPrint(printerProvider),
                        icon: printerProvider.isPrinting
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(Icons.print),
                        label: Text(
                          printerProvider.isPrinting
                              ? 'Printing...'
                              : 'Test Print',
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

  void _testPrint(PrinterProvider printerProvider) {
    Future.microtask(() async {
      try {
        await printerProvider.printWidget(
          context,
          SizedBox(width: 1, height: 1),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Test print completed'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Printing failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }
}
