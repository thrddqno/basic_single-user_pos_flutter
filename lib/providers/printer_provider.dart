import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterProvider with ChangeNotifier {
  final FlutterThermalPrinter _printer = FlutterThermalPrinter.instance;

  List<Printer> _scannedPrinters = [];

  List<Printer> _allPrinters = [];
  List<Printer> get printers => _allPrinters;

  Printer? _connectedPrinter;
  Printer? get connectedPrinter => _connectedPrinter;

  StreamSubscription<List<Printer>>? _streamSub;

  String? _lastError;
  String? get lastError => _lastError;

  bool _isPrinting = false;
  bool get isPrinting => _isPrinting;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  String? _savedPrinterAddress;
  Printer? _savedPrinter;

  PrinterProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadSavedPrinter();
      await startScan();
      await reconnectSavedPrinter();
    });
  }

  Future<void> _loadSavedPrinter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _savedPrinterAddress = prefs.getString('printer_address');
    } catch (e) {
      _lastError = "Failed to load saved printer: $e";
      notifyListeners();
    }
  }

  Future<void> startScan() async {
    _isScanning = true;
    _lastError = null;
    notifyListeners();

    try {
      _streamSub?.cancel();

      await _printer.getPrinters(
        connectionTypes: [ConnectionType.BLE, ConnectionType.USB],
      );

      _streamSub = _printer.devicesStream.listen(
        (devices) {
          _scannedPrinters = devices
              .where((p) => p.name != null && p.name!.isNotEmpty)
              .toList();

          _updateAllPrinters();
        },
        onError: (e) {
          _lastError = "Scan error: $e";
          _isScanning = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _lastError = "Failed to start scan: $e";
      _isScanning = false;
      notifyListeners();
    }
  }

  void stopScan() {
    _printer.stopScan();
    _streamSub?.cancel();
    _isScanning = false;
    notifyListeners();
  }

  void _updateAllPrinters() {
    final combined = <String, Printer>{};

    for (var printer in _scannedPrinters) {
      final key = printer.address ?? printer.name ?? '';
      if (key.isNotEmpty) {
        combined[key] = printer;
      }
    }

    if (_savedPrinter != null) {
      final key = _savedPrinter!.address ?? _savedPrinter!.name ?? '';
      if (key.isNotEmpty && !combined.containsKey(key)) {
        combined[key] = _savedPrinter!;
      }
    }

    _allPrinters = combined.values.toList();
    notifyListeners();
  }

  Future<void> connectPrinter(Printer printer) async {
    try {
      _lastError = null;
      notifyListeners();

      await _printer.connect(printer);
      _connectedPrinter = printer;
      await _saveConnectedPrinter(printer);
      notifyListeners();
    } catch (e) {
      _lastError = "Failed to connect: $e";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> disconnectPrinter() async {
    if (_connectedPrinter == null) return;

    try {
      _lastError = null;
      notifyListeners();

      await _printer.disconnect(_connectedPrinter!);
      _connectedPrinter = null;
      await _removeSavedPrinter();
      notifyListeners();
    } catch (e) {
      _lastError = "Failed to disconnect: $e";
      notifyListeners();
    }
  }

  Future<void> _saveConnectedPrinter(Printer printer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final address = printer.address ?? printer.name ?? '';

      await prefs.setString('printer_address', address);
      await prefs.setString('printer_type', printer.connectionTypeString);

      _savedPrinterAddress = address;
      _savedPrinter = printer;
    } catch (e) {
      _lastError = "Failed to save printer: $e";
      notifyListeners();
    }
  }

  Future<void> _removeSavedPrinter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('printer_address');
      await prefs.remove('printer_type');

      _savedPrinterAddress = null;
      _savedPrinter = null;
    } catch (e) {
      _lastError = "Failed to clear saved printer: $e";
      notifyListeners();
    }
  }

  Future<void> reconnectSavedPrinter() async {
    if (_savedPrinterAddress == null) return;
    if (_connectedPrinter != null) return;

    try {
      final savedPrinter = _scannedPrinters.cast<Printer?>().firstWhere(
        (p) =>
            p != null &&
            (p.address == _savedPrinterAddress ||
                p.name == _savedPrinterAddress),
        orElse: () => null,
      );

      if (savedPrinter != null) {
        _savedPrinter = savedPrinter;
        await connectPrinter(savedPrinter);
      }
    } catch (e) {
      debugPrint("Could not auto-reconnect to saved printer: $e");
    }
  }

  Future<void> printWidget(BuildContext context, Widget widget) async {
    if (_connectedPrinter == null) {
      _lastError = "No printer connected";
      notifyListeners();
      return;
    }

    _isPrinting = true;
    notifyListeners();

    try {
      await _printer.printWidget(
        context,
        widget: widget,
        printer: _connectedPrinter!,
        cutAfterPrinted: true,
      );
      _lastError = null;
    } catch (e) {
      _lastError = "Print failed: $e";
      debugPrint("Print error: $e");
    } finally {
      _isPrinting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    stopScan();
    super.dispose();
  }
}
