import 'package:basic_single_user_pos_flutter/helpers/price_helper.dart';
import 'package:basic_single_user_pos_flutter/providers/analytics_provider.dart';
import 'package:basic_single_user_pos_flutter/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            child: Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: Icon(FontAwesomeIcons.bars, color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Analytics',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Consumer<AnalyticsProvider>(
            builder: (context, analytics, _) {
              return Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _DateRangePicker(
                          rangeStart: analytics.rangeStart,
                          rangeEnd: analytics.rangeEnd,
                          onRangeChanged: (start, end) {
                            analytics.setDateRange(start, end);
                            analytics.loadAnalytics();
                          },
                        ),
                      ),
                      if (analytics.isLoading)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        ..._buildContent(context, analytics),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContent(
    BuildContext context,
    AnalyticsProvider analytics,
  ) {
    return [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 25),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                offset: Offset(0, 0),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            spacing: 16,
            children: [
              Row(
                spacing: 32,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text('Gross Sales'),
                        Text(
                          '₱${formatPrice(analytics.grossSales)}',
                          style: TextStyle(fontSize: 32),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text('Net Sales'),
                        Text(
                          '₱${formatPrice(analytics.netSales)}',
                          style: TextStyle(fontSize: 32),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text('Gross Profit'),
                        Text(
                          '₱${formatPrice(analytics.profit)}',
                          style: TextStyle(fontSize: 32),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 280),
                child: analytics.stackedLineChartData.isEmpty
                    ? Center(child: Text('No data in this period'))
                    : SfCartesianChart(
                        legend: Legend(isVisible: true),
                        primaryXAxis: CategoryAxis(),
                        primaryYAxis: NumericAxis(labelFormat: '₱{value}'),
                        trackballBehavior: TrackballBehavior(
                          enable: true,
                          activationMode: ActivationMode.singleTap,
                          tooltipSettings: InteractiveTooltip(
                            enable: true,
                            format: 'point.x : point.y',
                            borderWidth: 1,
                            borderColor: Colors.grey,
                          ),
                          tooltipDisplayMode:
                              TrackballDisplayMode.groupAllPoints,
                        ),
                        series: <StackedAreaSeries<StackedChartPoint, String>>[
                          StackedAreaSeries<StackedChartPoint, String>(
                            dataSource: analytics.stackedLineChartData,
                            xValueMapper: (StackedChartPoint p, _) => p.label,
                            yValueMapper: (StackedChartPoint p, _) => p.cost,
                            name: 'Cost',
                            color: Colors.red,
                            opacity: 0.5,
                            borderColor: Colors.red.shade700,
                            borderWidth: 3,
                          ),
                          StackedAreaSeries<StackedChartPoint, String>(
                            dataSource: analytics.stackedLineChartData,
                            xValueMapper: (StackedChartPoint p, _) => p.label,
                            yValueMapper: (StackedChartPoint p, _) => p.profit,
                            name: 'Gross Profit',
                            color: Colors.teal,
                            opacity: 0.5,
                            borderColor: Colors.teal.shade700,
                            borderWidth: 3,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 25),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                offset: Offset(0, 0),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top 5 items',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              if (analytics.topItemsPieData.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text('No items in this period')),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 200,
                        maxHeight: 200,
                      ),
                      child: SfCircularChart(
                        series: <CircularSeries>[
                          PieSeries<ChartData, String>(
                            dataSource: analytics.topItemsPieData,
                            pointColorMapper: (ChartData data, _) =>
                                data.color ?? Colors.grey,
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: _TopItemsListView(
                        items: analytics.topItemsPieData,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Text(
          'Sales by category',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _SalesByCategoryTable(rows: analytics.salesByCategory),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          'Sales by item',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: _SalesByItemTable(rows: analytics.salesByItem),
      ),
    ];
  }
}

class _DateRangePicker extends StatefulWidget {
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final void Function(DateTime start, DateTime end) onRangeChanged;

  const _DateRangePicker({
    required this.rangeStart,
    required this.rangeEnd,
    required this.onRangeChanged,
  });

  @override
  State<_DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<_DateRangePicker> {
  late DateTime _rangeStart;
  late DateTime _rangeEnd;

  DateTime? _tempStart;
  DateTime? _tempEnd;

  @override
  void initState() {
    super.initState();
    _rangeStart = widget.rangeStart;
    _rangeEnd = widget.rangeEnd;
  }

  @override
  void didUpdateWidget(covariant _DateRangePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rangeStart != widget.rangeStart ||
        oldWidget.rangeEnd != widget.rangeEnd) {
      _rangeStart = widget.rangeStart;
      _rangeEnd = widget.rangeEnd;
    }
  }

  String _formatDate(DateTime d) {
    return '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}-${d.year}';
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          SizedBox(width: 8),
          _DateChip(
            label: isSameDay(_rangeStart, _rangeEnd)
                ? _formatDate(_rangeStart)
                : '${_formatDate(_rangeStart)} - ${_formatDate(_rangeEnd)}',
            onTap: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    child: Container(
                      width: 400,
                      height: 500,
                      child: SfDateRangePicker(
                        initialSelectedRange: PickerDateRange(
                          _rangeStart,
                          _rangeEnd,
                        ),
                        showActionButtons: true,
                        selectionMode: DateRangePickerSelectionMode.range,

                        onSelectionChanged: (args) {
                          if (args.value is PickerDateRange) {
                            final range = args.value as PickerDateRange;
                            _tempStart = range.startDate;
                            _tempEnd = range.endDate;
                          }
                        },

                        onSubmit: (_) {
                          if (_tempStart != null) {
                            setState(() {
                              _rangeStart = _tempStart!;
                              _rangeEnd = _tempEnd ?? _tempStart!;
                            });

                            widget.onRangeChanged(_rangeStart, _rangeEnd);
                          }
                          Navigator.of(context).pop();
                        },

                        onCancel: () => Navigator.of(context).pop(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DateChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.teal.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(width: 8),
              Icon(Icons.calendar_today, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopItemsListView extends StatelessWidget {
  final List<ChartData> items;

  const _TopItemsListView({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: item.color ?? Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black26),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.x,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '₱${formatPrice(item.y)}',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SalesByCategoryTable extends StatelessWidget {
  final List<CategorySalesRow> rows;

  const _SalesByCategoryTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            offset: Offset(0, 0),
            blurRadius: 4,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 32,
          ),
          child: DataTable(
            columns: const [
              DataColumn(
                label: Text(
                  'Category',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Items sold',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'Net sales',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'Cost',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'Profit',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                numeric: true,
              ),
            ],
            rows: rows.map((r) {
              return DataRow(
                cells: [
                  DataCell(Text(r.category)),
                  DataCell(Text('${r.itemsSold}')),
                  DataCell(Text('₱${formatPrice(r.netSales)}')),
                  DataCell(Text('₱${formatPrice(r.cost)}')),
                  DataCell(Text('₱${formatPrice(r.profit)}')),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _SalesByItemTable extends StatelessWidget {
  final List<ItemSalesRow> rows;

  const _SalesByItemTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            offset: Offset(0, 0),
            blurRadius: 4,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 32,
          ),
          child: DataTable(
            columns: const [
              DataColumn(
                label: Text(
                  'Item',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Items sold',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'Net sales',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'Cost',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'Profit',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                numeric: true,
              ),
            ],
            rows: rows.map((r) {
              return DataRow(
                cells: [
                  DataCell(Text(r.item)),
                  DataCell(Text('${r.itemsSold}')),
                  DataCell(Text('₱${formatPrice(r.netSales)}')),
                  DataCell(Text('₱${formatPrice(r.cost)}')),
                  DataCell(Text('₱${formatPrice(r.profit)}')),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
