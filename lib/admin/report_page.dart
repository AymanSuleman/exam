import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> models = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final snapshot = await _firestore.collection('carmodel').get();
    models = snapshot.docs;
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final modelCountByBrand = <String, int>{};
    final modelCountByClass = <String, int>{};
    double totalImageSizeMB = 0;
    final imageCounts = <String, int>{};

    int activeCount = 0;
    int inactiveCount = 0;

    double totalPrice = 0;
    double minPrice = double.infinity;
    double maxPrice = double.negativeInfinity;

    for (var doc in models) {
      final data = doc.data() as Map<String, dynamic>;
      final brand = data['brand'] ?? 'Unknown';
      final carClass = data['carClass'] ?? 'Unknown';
      final price = (data['price'] ?? 0).toDouble();
      final images = (data['modelImages'] ?? []) as List;
      final active = data['active'] ?? false;

      modelCountByBrand[brand] = (modelCountByBrand[brand] ?? 0) + 1;
      modelCountByClass[carClass] = (modelCountByClass[carClass] ?? 0) + 1;
      imageCounts[data['modelName']] = images.length;

      if (active) activeCount++; else inactiveCount++;

      totalPrice += price;
      if (price < minPrice) minPrice = price;
      if (price > maxPrice) maxPrice = price;
    }

    final averagePrice = models.isNotEmpty ? totalPrice / models.length : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Model Count by Brand', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    children: modelCountByBrand.entries
                        .map((e) => Chip(label: Text('${e.key}: ${e.value}')))
                        .toList(),
                  ),
                  SizedBox(height: 10),
                  Text('Model Count by Class', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    children: modelCountByClass.entries
                        .map((e) => Chip(label: Text('${e.key}: ${e.value}')))
                        .toList(),
                  ),
                  SizedBox(height: 20),
                  Text('Active vs Inactive Models', style: TextStyle(fontWeight: FontWeight.bold)),
                  PieChart(
                    dataMap: {
                      'Active': activeCount.toDouble(),
                      'Inactive': inactiveCount.toDouble(),
                    },
                    chartType: ChartType.ring,
                    chartRadius: 130,
                  ),
                  SizedBox(height: 20),
                  Text('Price Distribution', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Average: ₹${averagePrice.toStringAsFixed(2)}'),
                  Text('Min: ₹${minPrice.toStringAsFixed(2)}'),
                  Text('Max: ₹${maxPrice.toStringAsFixed(2)}'),
                  SizedBox(height: 20),
                  Text('Image Storage Usage', style: TextStyle(fontWeight: FontWeight.bold)),
                  Column(
                    children: imageCounts.entries
                        .map((e) => ListTile(
                              title: Text(e.key),
                              trailing: Text('${e.value} images'),
                            ))
                        .toList(),
                  )
                ],
              ),
            ),
    );
  }
}
