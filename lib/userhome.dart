import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/cardetail.dart';
import 'package:flutter_application/theme/app_theme.dart';

class CarModelDashboard extends StatefulWidget {
  const CarModelDashboard({Key? key}) : super(key: key);

  @override
  _CarModelDashboardState createState() => _CarModelDashboardState();
}

class _CarModelDashboardState extends State<CarModelDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = '';
  int selectedTabIndex = 0;
  String? adminUid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    adminUid = FirebaseAuth.instance.currentUser?.uid;

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          selectedTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isWideScreen = screenWidth > 600;

    final cardHeight = isWideScreen ? screenHeight * 0.28 : screenHeight * 0.21;
    final imageSize = cardHeight * 0.7;

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        centerTitle: true,
        title: const Text(
          'Car Models',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => searchQuery = val),
                    cursorColor: Colors.blueAccent,
                    decoration: InputDecoration(
                      hintText: 'Search by Model Name or Code',
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.blueAccent),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => searchQuery = ''),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    tabs: [
                      tabItem('Sort by Date', selectedTabIndex == 0),
                      tabItem('Sort by Order', selectedTabIndex == 1),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: adminUid == null
          ? const Center(child: Text("Admin not logged in"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('carModels')
                  .where('active', isEqualTo: true)
                  .where('uploadedBy', isEqualTo: adminUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading data'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> docs = snapshot.data!.docs;

                List<DocumentSnapshot> filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final modelName = data['modelName'].toString().toLowerCase();
                  final modelCode = data['modelCode'].toString().toLowerCase();
                  final query = searchQuery.toLowerCase();
                  return modelName.contains(query) || modelCode.contains(query);
                }).toList();

                if (selectedTabIndex == 0) {
                  filtered.sort((a, b) => (b['dateOfManufacture'] as Timestamp)
                      .compareTo(a['dateOfManufacture'] as Timestamp));
                } else {
                  filtered.sort((a, b) =>
                      (a['sortOrder'] as int).compareTo(b['sortOrder'] as int));
                }

                if (filtered.isEmpty) {
                  return const Center(
                      child: Text('No active car models uploaded by you.'));
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    itemCount: filtered.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWideScreen ? 2 : 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isWideScreen
                          ? (screenWidth / 2) / cardHeight
                          : screenWidth / cardHeight,
                    ),
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CarDetailScreen(docId: doc.id, carId: ''),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    data['thumbnail'],
                                    width: imageSize,
                                    height: imageSize,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      width: imageSize,
                                      height: imageSize,
                                      color: Colors.grey.shade300,
                                      child:
                                          const Icon(Icons.car_repair, size: 40),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(data['modelName'],
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      Text('Brand: ${data['brand']}'),
                                      Text('Class: ${data['class']}'),
                                      Text('Price: \$${data['price']}'),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Text('Status: '),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Active',
                                              style: TextStyle(
                                                color: Colors.green.shade800,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget tabItem(String text, bool isSelected) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white
            : AppTheme.primaryColor.withOpacity(0.8),
        borderRadius: isSelected
            ? const BorderRadius.all(Radius.circular(12))
            : BorderRadius.zero,
        boxShadow:
            isSelected ? [BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.blue.shade900 : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}
