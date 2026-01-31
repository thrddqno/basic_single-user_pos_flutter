import 'package:flutter/material.dart';
import 'package:basic_single_user_pos_flutter/models/receipt.dart';
import 'package:basic_single_user_pos_flutter/repositories/receipt_repository.dart';
import 'package:basic_single_user_pos_flutter/repositories/category_repository.dart';

class ChartData {
  ChartData(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color? color;
}

class SalesData {
  SalesData(this.label, this.sales);
  final String label;
  final double sales;
}

/// Per-point data for stacked chart: Net Sales = Cost + Gross Profit.
class StackedChartPoint {
  StackedChartPoint(this.label, this.netSales, this.cost, this.profit);
  final String label;
  final double netSales;
  final double cost;
  final double profit;
}

class CategorySalesRow {
  final String category;
  final int itemsSold;
  final double netSales;
  final double cost;
  final double profit;
  CategorySalesRow({
    required this.category,
    required this.itemsSold,
    required this.netSales,
    required this.cost,
    required this.profit,
  });
}

class ItemSalesRow {
  final String item;
  final int itemsSold;
  final double netSales;
  final double cost;
  final double profit;
  ItemSalesRow({
    required this.item,
    required this.itemsSold,
    required this.netSales,
    required this.cost,
    required this.profit,
  });
}

class AnalyticsProvider with ChangeNotifier {
  final ReceiptRepository _receiptRepository;
  final CategoryRepository _categoryRepository;

  List<Receipt> _receipts = [];
  List<Receipt> get receipts => _receipts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<int, String> _categoryNames = {};
  late DateTime _rangeStart;
  late DateTime _rangeEnd;

  DateTime get rangeStart => _rangeStart;
  DateTime get rangeEnd => _rangeEnd;

  bool get isSingleDay {
    return _rangeStart.year == _rangeEnd.year &&
        _rangeStart.month == _rangeEnd.month &&
        _rangeStart.day == _rangeEnd.day;
  }

  AnalyticsProvider(this._receiptRepository, this._categoryRepository) {
    final now = DateTime.now();
    _rangeStart = DateTime(now.year, now.month, now.day);
    _rangeEnd = now;
  }

  double get grossSales => _receipts.fold(0.0, (sum, r) => sum + r.total);

  double get netSales => grossSales;

  double get totalCost {
    double cost = 0;
    for (final r in _receipts) {
      for (final item in r.items) {
        final unitCost = item.productCost ?? 0;
        cost += unitCost * item.quantity;
      }
    }
    return cost;
  }

  double get profit => netSales - totalCost;

  static const List<String> _hourLabels = [
    '12 AM',
    '1 AM',
    '2 AM',
    '3 AM',
    '4 AM',
    '5 AM',
    '6 AM',
    '7 AM',
    '8 AM',
    '9 AM',
    '10 AM',
    '11 AM',
    '12 PM',
    '1 PM',
    '2 PM',
    '3 PM',
    '4 PM',
    '5 PM',
    '6 PM',
    '7 PM',
    '8 PM',
    '9 PM',
    '10 PM',
    '11 PM',
  ];

  /// Cost for a single receipt.
  double _receiptCost(Receipt r) {
    double cost = 0;
    for (final item in r.items) {
      cost += (item.productCost ?? 0) * item.quantity;
    }
    return cost;
  }

  /// Stacked chart data: every hour (single day) or every day (multi day), with net sales, cost, profit. Fills 0 for periods with no data.
  List<StackedChartPoint> get stackedLineChartData {
    if (isSingleDay) {
      final netByHour = List.filled(24, 0.0);
      final costByHour = List.filled(24, 0.0);
      for (final r in _receipts) {
        final hour = r.date.hour;
        netByHour[hour] += r.total;
        costByHour[hour] += _receiptCost(r);
      }
      return _hourLabels.asMap().entries.map((e) {
        final i = e.key;
        final net = netByHour[i];
        final cost = costByHour[i];
        return StackedChartPoint(e.value, net, cost, net - cost);
      }).toList();
    }
    // Multiple days: generate every day in range, fill 0 when no data.
    final days = <DateTime>[];
    for (
      var d = DateTime(_rangeStart.year, _rangeStart.month, _rangeStart.day);
      !d.isAfter(DateTime(_rangeEnd.year, _rangeEnd.month, _rangeEnd.day));
      d = d.add(const Duration(days: 1))
    ) {
      days.add(d);
    }
    final netByDay = <DateTime, double>{};
    final costByDay = <DateTime, double>{};
    for (final r in _receipts) {
      final day = DateTime(r.date.year, r.date.month, r.date.day);
      netByDay[day] = (netByDay[day] ?? 0) + r.total;
      costByDay[day] = (costByDay[day] ?? 0) + _receiptCost(r);
    }
    return days.map((d) {
      final net = netByDay[d] ?? 0;
      final cost = costByDay[d] ?? 0;
      final label = '${d.month}/${d.day}';
      return StackedChartPoint(label, net, cost, net - cost);
    }).toList();
  }

  static final List<Color> _pieColors = [
    Colors.teal,
    Colors.orange,
    Colors.blue,
    Colors.purple,
    Colors.amber,
  ];

  List<ChartData> get topItemsPieData {
    final byProduct = <int, ({double sales, String name})>{};
    for (final r in _receipts) {
      for (final item in r.items) {
        final id = item.product.id ?? 0;
        final name = item.product.name;
        byProduct[id] = (
          sales: (byProduct[id]?.sales ?? 0) + item.total,
          name: name,
        );
      }
    }
    final sorted = byProduct.entries.toList()
      ..sort((a, b) => b.value.sales.compareTo(a.value.sales));
    final top5 = sorted.take(5).toList();
    return top5.asMap().entries.map((e) {
      return ChartData(
        e.value.value.name,
        e.value.value.sales,
        _pieColors[e.key % _pieColors.length],
      );
    }).toList();
  }

  List<CategorySalesRow> get salesByCategory {
    final byCategory = <int, ({int qty, double net, double cost})>{};
    for (final r in _receipts) {
      for (final item in r.items) {
        final cid = item.productCategoryId ?? 0;
        final unitCost = item.productCost ?? 0;
        final cost = unitCost * item.quantity;
        final prev = byCategory[cid];
        if (prev == null) {
          byCategory[cid] = (qty: item.quantity, net: item.total, cost: cost);
        } else {
          byCategory[cid] = (
            qty: prev.qty + item.quantity,
            net: prev.net + item.total,
            cost: prev.cost + cost,
          );
        }
      }
    }
    return byCategory.entries.map((e) {
      final name = _categoryNames[e.key] ?? 'Category #${e.key}';
      final net = e.value.net;
      final cost = e.value.cost;
      return CategorySalesRow(
        category: name,
        itemsSold: e.value.qty,
        netSales: net,
        cost: cost,
        profit: net - cost,
      );
    }).toList()..sort((a, b) => b.netSales.compareTo(a.netSales));
  }

  List<ItemSalesRow> get salesByItem {
    final byProduct = <String, ({int qty, double net, double cost})>{};
    for (final r in _receipts) {
      for (final item in r.items) {
        final name = item.product.name;
        final unitCost = item.productCost ?? 0;
        final cost = unitCost * item.quantity;
        final prev = byProduct[name];
        if (prev == null) {
          byProduct[name] = (qty: item.quantity, net: item.total, cost: cost);
        } else {
          byProduct[name] = (
            qty: prev.qty + item.quantity,
            net: prev.net + item.total,
            cost: prev.cost + cost,
          );
        }
      }
    }
    return byProduct.entries.map((e) {
      final net = e.value.net;
      final cost = e.value.cost;
      return ItemSalesRow(
        item: e.key,
        itemsSold: e.value.qty,
        netSales: net,
        cost: cost,
        profit: net - cost,
      );
    }).toList()..sort((a, b) => b.netSales.compareTo(a.netSales));
  }

  void setDateRange(DateTime start, DateTime end) {
    _rangeStart = DateTime(start.year, start.month, start.day);
    _rangeEnd = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
    if (_rangeEnd.isBefore(_rangeStart)) {
      final t = _rangeStart;
      _rangeStart = _rangeEnd;
      _rangeEnd = DateTime(t.year, t.month, t.day, 23, 59, 59, 999);
    }
    notifyListeners();
  }

  Future<void> loadAnalytics() async {
    _isLoading = true;
    notifyListeners();
    final categories = await _categoryRepository.getAll();
    _categoryNames = {for (var c in categories) c.id!: c.name};
    _receipts = await _receiptRepository.getReceiptByDateRange(
      _rangeStart,
      _rangeEnd,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshIfNeeded() async {
    await loadAnalytics();
  }
}
