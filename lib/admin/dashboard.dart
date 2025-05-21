import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/admin/add_car_model.dart';
import 'package:flutter_application/admin/car_model_detail.dart';
import 'package:flutter_application/admin/report_page.dart';
import 'package:flutter_application/theme/app_theme.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminDashboard extends StatefulWidget {
  AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _firestore = FirebaseFirestore.instance;
  String searchQuery = '';
  List<QueryDocumentSnapshot> models = [];
  bool isLoading = true;
  int activeCount = 0;
  int inactiveCount = 0;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    final snapshot = await _firestore.collection('carmodel').get();
    final docs = snapshot.docs;
    models = docs;

    activeCount = docs.where((d) => d['active'] == true).length;
    inactiveCount = docs.length - activeCount;

    setState(() => isLoading = false);
  }

  Future<void> _exportToPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Text('Car Models Report', style: pw.TextStyle(fontSize: 20)),
            pw.SizedBox(height: 20),
            ...models.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return pw.Text(
                  '${data['modelName']} | ${data['brand']} | ${data['carClass']} | \$${data['price']} | Active: ${data['active']}');
            })
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final filtered = models.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['modelName']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          data['modelCode']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
    }).toList();

    final pieData = {
      "Active": activeCount.toDouble(),
      "Inactive": inactiveCount.toDouble(),
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.picture_as_pdf,
              color: AppTheme.textPrimary,
            ),
            onPressed: _exportToPdf,
          ),
          IconButton(
            icon: Icon(Icons.bar_chart, color: AppTheme.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ReportsPage()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by Model Name or Code',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (val) => setState(() => searchQuery = val),
                  ),
                ),
                PieChart(
                  dataMap: pieData,
                  chartType: ChartType.ring,
                  colorList: [AppTheme.activeColor, AppTheme.inactiveColor],
                  chartRadius: 150,
                  legendOptions: LegendOptions(showLegends: true),
                  chartValuesOptions:
                      ChartValuesOptions(showChartValuesInPercentage: true),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final doc = filtered[i];
                      final data = doc.data() as Map<String, dynamic>;
                      final imageUrl = data['modelImages'] != null &&
                              data['modelImages'].isNotEmpty
                          ? data['modelImages'][0]
                          : null;

                      return Card(
                        child: InkWell(
                          onTap: () async {
                            // Navigate to detail page and wait for result to refresh list if needed
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CarModelDetailPage(doc: doc),
                              ),
                            );
                            if (result == true) {
                              _loadModels();
                            }
                          },
                          child: ListTile(
                            leading: imageUrl != null
                                ? Image.network(imageUrl,
                                    width: 60, height: 60, fit: BoxFit.cover)
                                : Icon(Icons.image),
                            title: Text(data['modelName'] ?? ''),
                            subtitle:
                                Text('${data['brand']} | ${data['carClass']}'),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('₹${data['price'] ?? ''}'),
                                SizedBox(height: 4),
                                Text(
                                  data['active'] ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: data['active']
                                        ? AppTheme.activeColor
                                        : AppTheme.inactiveColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddCarModelPage()),
          );
          if (added == true) {
            _loadModels(); // reload list after adding
          }
        },
        child: Icon(
          Icons.add,
          color: AppTheme.textPrimary,
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
