import 'package:flutter/material.dart';
import '../models/receipt.dart';
import '../repositories/receipt_repository.dart';

class ReceiptProvider with ChangeNotifier {
  final ReceiptRepository _receiptRepository;

  List<Receipt> _receipts = [];
  List<Receipt> get receipts => _receipts;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  ReceiptProvider(this._receiptRepository);

  Future<void> loadAll() async {
    _isLoading = true;
    _receipts = await _receiptRepository.getAll();
    _isLoading = false;
    notifyListeners();
  }

  Receipt? get latestReceipt => _receipts.isNotEmpty ? _receipts.last : null;

  Future<void> createReceipt(Receipt receipt) async {
    var id = await _receiptRepository.insertReceipt(receipt);
    receipt.id = id;
    _receipts.add(receipt);
    notifyListeners();
  }

  Future<void> deleteReceipt(int id) async {
    await _receiptRepository.deleteReceipt(id);
    await loadAll();
  }
}
