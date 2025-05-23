// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_application/cardetail.dart';
// import 'package:flutter_application/theme/app_theme.dart';

// class CarModelDashboard extends StatefulWidget {
//    CarModelDashboard({Key? key}) : super(key: key);

//   @override
//   _CarModelDashboardState createState() => _CarModelDashboardState();
// }

// class _CarModelDashboardState extends State<CarModelDashboard>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   String searchQuery = '';
//   int selectedTabIndex = 0;
//   String? adminUid;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     adminUid = FirebaseAuth.instance.currentUser?.uid;

//     _tabController.addListener(() {
//       if (!_tabController.indexIsChanging) {
//         setState(() {
//           selectedTabIndex = _tabController.index;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final screenWidth = mediaQuery.size.width;
//     final screenHeight = mediaQuery.size.height;
//     final isWideScreen = screenWidth > 600;

//     final cardHeight = isWideScreen ? screenHeight * 0.28 : screenHeight * 0.21;
//     final imageSize = cardHeight * 0.7;

//     return Scaffold(
//       appBar: AppBar(
//         elevation: 4,
//         centerTitle: true,
//         title:  Text(
//           'Car Models',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
//         ),
//         bottom: PreferredSize(
//           preferredSize: Size.fromHeight(screenHeight * 0.16),
//           child: Padding(
//             padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Column(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 8,
//                         offset: Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: TextField(
//                     onChanged: (val) => setState(() => searchQuery = val),
//                     cursorColor: Colors.blueAccent,
//                     decoration: InputDecoration(
//                       hintText: 'Search by Model Name or Code',
//                       prefixIcon:
//                            Icon(Icons.search, color: Colors.blueAccent),
//                       suffixIcon: searchQuery.isNotEmpty
//                           ? IconButton(
//                               icon:  Icon(Icons.clear),
//                               onPressed: () => setState(() => searchQuery = ''),
//                             )
//                           : null,
//                       border: InputBorder.none,
//                       contentPadding:  EdgeInsets.symmetric(vertical: 16),
//                     ),
//                   ),
//                 ),
//                  SizedBox(height: 12),
//                 Container(
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: AppTheme.primaryColor.withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: TabBar(
//                     controller: _tabController,
//                     indicatorColor: Colors.transparent,
//                     tabs: [
//                       tabItem('Sort by Date', selectedTabIndex == 0),
//                       tabItem('Sort by Order', selectedTabIndex == 1),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: adminUid == null
//           ?  Center(child: Text("Admin not logged in"))
//           : StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('carModels')
//                   .where('active', isEqualTo: true)
//                   .where('uploadedBy', isEqualTo: adminUid)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return  Center(child: Text('Error loading data'));
//                 }
//                 if (!snapshot.hasData) {
//                   return  Center(child: CircularProgressIndicator());
//                 }

//                 List<DocumentSnapshot> docs = snapshot.data!.docs;

//                 List<DocumentSnapshot> filtered = docs.where((doc) {
//                   final data = doc.data() as Map<String, dynamic>;
//                   final modelName = data['modelName'].toString().toLowerCase();
//                   final modelCode = data['modelCode'].toString().toLowerCase();
//                   final query = searchQuery.toLowerCase();
//                   return modelName.contains(query) || modelCode.contains(query);
//                 }).toList();

//                 if (selectedTabIndex == 0) {
//                   filtered.sort((a, b) => (b['dateOfManufacture'] as Timestamp)
//                       .compareTo(a['dateOfManufacture'] as Timestamp));
//                 } else {
//                   filtered.sort((a, b) =>
//                       (a['sortOrder'] as int).compareTo(b['sortOrder'] as int));
//                 }

//                 if (filtered.isEmpty) {
//                   return  Center(
//                       child: Text('No active car models uploaded by you.'));
//                 }

//                 return Padding(
//                   padding:  EdgeInsets.all(16),
//                   child: GridView.builder(
//                     itemCount: filtered.length,
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: isWideScreen ? 2 : 1,
//                       crossAxisSpacing: 16,
//                       mainAxisSpacing: 16,
//                       childAspectRatio: isWideScreen
//                           ? (screenWidth / 2) / cardHeight
//                           : screenWidth / cardHeight,
//                     ),
//                     itemBuilder: (context, index) {
//                       final doc = filtered[index];
//                       final data = doc.data() as Map<String, dynamic>;
//                       return GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   CarDetailScreen(docId: doc.id, carId: ''),
//                             ),
//                           );
//                         },
//                         child: Card(
//                           elevation: 3,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Padding(
//                             padding:  EdgeInsets.all(12.0),
//                             child: Row(
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(10),
//                                   child: Image.network(
//                                     data['thumbnail'],
//                                     width: imageSize,
//                                     height: imageSize,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stackTrace) =>
//                                         Container(
//                                       width: imageSize,
//                                       height: imageSize,
//                                       color: Colors.grey.shade300,
//                                       child:
//                                            Icon(Icons.car_repair, size: 40),
//                                     ),
//                                   ),
//                                 ),
//                                  SizedBox(width: 16),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceAround,
//                                     children: [
//                                       Text(data['modelName'],
//                                           style:  TextStyle(
//                                               fontSize: 18,
//                                               fontWeight: FontWeight.bold)),
//                                       Text('Brand: ${data['brand']}'),
//                                       Text('Class: ${data['class']}'),
//                                       Text('Price: \$${data['price']}'),
//                                        SizedBox(height: 4),
//                                       Row(
//                                         children: [
//                                            Text('Status: '),
//                                           Container(
//                                             padding:  EdgeInsets.symmetric(
//                                                 horizontal: 8, vertical: 4),
//                                             decoration: BoxDecoration(
//                                               color: Colors.green.shade100,
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                             child: Text(
//                                               'Active',
//                                               style: TextStyle(
//                                                 color: Colors.green.shade800,
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//     );
//   }

//   Widget tabItem(String text, bool isSelected) {
//     return Container(
//       alignment: Alignment.center,
//       padding:  EdgeInsets.symmetric(horizontal: 24),
//       decoration: BoxDecoration(
//         color: isSelected
//             ? Colors.white
//             : AppTheme.primaryColor.withOpacity(0.8),
//         borderRadius: isSelected
//             ?  BorderRadius.all(Radius.circular(12))
//             : BorderRadius.zero,
//         boxShadow:
//             isSelected ? [BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: isSelected ? Colors.blue.shade900 : Colors.white,
//           fontWeight: FontWeight.w600,
//           fontSize: 16,
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/theme/app_theme.dart';

class UserCarDashboard extends StatefulWidget {
   UserCarDashboard({Key? key}) : super(key: key);

  @override
  State<UserCarDashboard> createState() => _UserCarDashboardState();
}

class _UserCarDashboardState extends State<UserCarDashboard> {
  List<QueryDocumentSnapshot> docs = [];
  bool isLoading = false;
  bool ascending = false; // false = latest first, true = oldest first
  String searchQuery = '';

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      Query query = FirebaseFirestore.instance
          .collection('carmodel')
          .orderBy('dateOfManufacturing', descending: !ascending);

      final snapshot = await query.get();
      List<QueryDocumentSnapshot> allDocs = snapshot.docs;

      if (searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        allDocs = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final modelName = (data['modelName'] ?? '').toString().toLowerCase();
          final modelCode = (data['modelCode'] ?? '').toString().toLowerCase();
          return modelName.contains(lowerQuery) ||
              modelCode.contains(lowerQuery);
        }).toList();
      }

      setState(() {
        docs = allDocs;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer( Duration(milliseconds: 400), () {
      setState(() {
        searchQuery = val.trim();
      });
      _loadData();
    });
  }

  void _toggleSortOrder() {
    setState(() {
      ascending = !ascending;
    });
    _loadData();
  }

  Widget _buildThumbnail(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        width: 60,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.textPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child:  Icon(Icons.directions_car, size: 30, color: Colors.grey),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 60,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade200,
          width: 60,
          height: 40,
          child:  Icon(Icons.directions_car, size: 30, color: Colors.grey),
        ),
      ),
    );
  }

  DataRow _buildDataRow(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final modelName = data['modelName'] ?? '';
    final brand = data['brand'] ?? '';
    final carClass = data['carClass'] ?? data['class'] ?? '';
    final price = data['price'] ?? 0;
    final active = data['active'] ?? false;
    final thumbnail = (data['modelImages'] != null &&
            (data['modelImages'] as List).isNotEmpty)
        ? data['modelImages'][0]
        : '';

    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(MaterialState.hovered)) {
            return Colors.blue.shade50.withOpacity(0.3);
          }
          return null;
        },
      ),
      cells: [
        DataCell(_buildThumbnail(thumbnail)),
        DataCell(Text(modelName,
            style:  TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Text(brand)),
        DataCell(Text(carClass)),
        DataCell(Text('₹$price',
            style:  TextStyle(fontWeight: FontWeight.w500))),
        DataCell(
          AnimatedContainer(
            duration:  Duration(milliseconds: 300),
            padding:  EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: active ? Colors.green.shade100 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: active
                      ? Colors.green.shade300.withOpacity(0.4)
                      : Colors.red.shade300.withOpacity(0.4),
                  blurRadius: 8,
                  offset:  Offset(0, 2),
                )
              ],
            ),
            child: Text(
              active ? 'Active' : 'Inactive',
              style: TextStyle(
                color: active ? Colors.green.shade800 : Colors.red.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTable() {
    if (isLoading) {
      return  Center(child: CircularProgressIndicator());
    }
    if (docs.isEmpty) {
      return Center(
        child: Text(
          'No car models found.',
          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        ),
      );
    }

    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          dataRowHeight: 64,
          columnSpacing: 36,
          horizontalMargin: 24,
          headingTextStyle: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryColor,
            fontSize: 16,
            letterSpacing: 0.7,
          ),
          dataTextStyle:  TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          columns:  [
            DataColumn(label: Text('Images')),
            DataColumn(label: Text('Model Name')),
            DataColumn(label: Text('Brand')),
            DataColumn(label: Text('Class')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Status')),
          ],
          rows: docs.map((doc) => _buildDataRow(doc)).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchAndSort() {
    return Container(
      margin:  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding:  EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset:  Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by Model Name or Model Code',
                border: InputBorder.none,
                prefixIcon:  Icon(Icons.search, color: Colors.blueAccent),
              ),
              style:  TextStyle(fontSize: 16),
            ),
          ),
           SizedBox(width: 12),
          Tooltip(
            message: ascending ? 'Sort Oldest First' : 'Sort Latest First',
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: _toggleSortOrder,
              child: Container(
                padding:  EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withOpacity(0.1),
                ),
                child: Icon(
                  ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.blue.shade50.withOpacity(0.3),
      appBar: AppBar(
        title:  Text('Car Models Dashboard',
        style: TextStyle(color: AppTheme.textPrimary),),
        centerTitle: true,
        backgroundColor:AppTheme.primaryColor,
        elevation: 4,
        shadowColor:AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          _buildSearchAndSort(),
          Expanded(
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 16),
              child: _buildTable(),
            ),
          ),
        ],
      ),
    );
  }
}
