// import 'package:flutter/material.dart';
// import 'package:flutter_application/theme/app_theme.dart';

// class CarModelDashboard extends StatefulWidget {
//   const CarModelDashboard({Key? key}) : super(key: key);

//   @override
//   _CarModelDashboardState createState() => _CarModelDashboardState();
// }

// class _CarModelDashboardState extends State<CarModelDashboard>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   String searchQuery = '';
//   int selectedTabIndex = 0;

//   final List<Map<String, dynamic>> carModels = [
//     {
//       'thumbnail': 'https://example.com/default-car.jpg',
//       'modelName': 'A3',
//       'brand': 'Audi',
//       'class': 'A-Class',
//       'price': 35000,
//       'active': true,
//       'dateOfManufacture': DateTime(2023, 5, 1),
//       'sortOrder': 2,
//       'modelCode': 'AUDI-A3-01',
//     },
//     {
//       'thumbnail': 'https://example.com/default-car2.jpg',
//       'modelName': 'XJ',
//       'brand': 'Jaguar',
//       'class': 'B-Class',
//       'price': 60000,
//       'active': false,
//       'dateOfManufacture': DateTime(2022, 8, 10),
//       'sortOrder': 1,
//       'modelCode': 'JAG-XJ-02',
//     },
//     {
//       'thumbnail': 'https://example.com/default-car3.jpg',
//       'modelName': 'Civic',
//       'brand': 'Honda',
//       'class': 'C-Class',
//       'price': 25000,
//       'active': true,
//       'dateOfManufacture': DateTime(2024, 1, 10),
//       'sortOrder': 3,
//       'modelCode': 'HON-CIVIC-03',
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _tabController.addListener(() {
//       if (!_tabController.indexIsChanging) {
//         setState(() {
//           selectedTabIndex = _tabController.index;
//         });
//       }
//     });
//   }

//   List<Map<String, dynamic>> get filteredModels {
//     final query = searchQuery.toLowerCase();
//     List<Map<String, dynamic>> filtered = carModels.where((model) {
//       final modelName = model['modelName'].toString().toLowerCase();
//       final modelCode = model['modelCode'].toString().toLowerCase();
//       final isActive = model['active'] == true;

//       return isActive &&
//           (modelName.contains(query) || modelCode.contains(query));
//     }).toList();

//     if (selectedTabIndex == 0) {
//       // Sort by date (latest first)
//       filtered.sort((a, b) => (b['dateOfManufacture'] as DateTime)
//           .compareTo(a['dateOfManufacture'] as DateTime));
//     } else {
//       // Sort by sortOrder
//       filtered.sort(
//           (a, b) => (a['sortOrder'] as int).compareTo(b['sortOrder'] as int));
//     }

//     return filtered;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final screenWidth = mediaQuery.size.width;
//     final screenHeight = mediaQuery.size.height;
//     final isWideScreen = screenWidth > 600;

//     // Calculate responsive heights based on screen height
//     final cardHeight = isWideScreen ? screenHeight * 0.28 : screenHeight * 0.21;
//     final imageSize =
//         cardHeight * 0.7; // Image size proportional to card height

//     return Scaffold(
//       appBar: AppBar(
//         elevation: 4,
//         centerTitle: true,
//         title: const Text(
//           ' Car Models',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
//         ),
//         bottom: PreferredSize(
//           preferredSize: Size.fromHeight(screenHeight * 0.16),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Column(
//               children: [
//                 // Search box with shadow & rounded corners
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
//                       hintText: 'Search by Model Name or Model Code',
//                       prefixIcon:
//                           const Icon(Icons.search, color: Colors.blueAccent),
//                       suffixIcon: searchQuery.isNotEmpty
//                           ? IconButton(
//                               icon: const Icon(Icons.clear, color: Colors.grey),
//                               onPressed: () => setState(() => searchQuery = ''),
//                             )
//                           : null,
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 12),

//                 // TabBar with underline indicator and spacing
//                 Container(
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: AppTheme.primaryColor.withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: TabBar(
//                     controller: _tabController,
//                     indicatorColor: Colors.transparent,
//                     labelPadding: EdgeInsets.zero,
//                     tabs: List.generate(2, (index) {
//                       final isSelected = _tabController.index == index;
//                       final text =
//                           index == 0 ? 'Sort by Date' : 'Sort by Order';

//                       return Container(
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? Colors.white
//                               : AppTheme.primaryColor.withOpacity(0.8),
//                           borderRadius: BorderRadius.horizontal(
//                             left: index == 0
//                                 ? const Radius.circular(12)
//                                 : Radius.zero,
//                             right: index == 1
//                                 ? const Radius.circular(12)
//                                 : Radius.zero,
//                           ),
//                           boxShadow: isSelected
//                               ? [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.15),
//                                     blurRadius: 5,
//                                     offset: const Offset(0, 2),
//                                   )
//                                 ]
//                               : [],
//                         ),
//                         alignment: Alignment.center,
//                         padding: const EdgeInsets.symmetric(horizontal: 24),
//                         child: Text(
//                           text,
//                           style: TextStyle(
//                             color: isSelected
//                                 ? Colors.blue.shade900
//                                 : Colors.white,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 16,
//                           ),
//                         ),
//                       );
//                     }),
//                     onTap: (index) {
//                       setState(() {
//                         _tabController.index = index;
//                       });
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: filteredModels.isEmpty
//           ? const Center(
//               child: Text(
//               'No active car models found.',
//               style: TextStyle(fontSize: 16),
//             ))
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: GridView.builder(
//                 itemCount: filteredModels.length,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: isWideScreen ? 2 : 1,
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 16,
//                   childAspectRatio: isWideScreen
//                       ? (screenWidth / 2) / cardHeight
//                       : screenWidth / cardHeight,
//                 ),
//                 itemBuilder: (context, index) {
//                   final model = filteredModels[index];
//                   return Card(
//                     elevation: 3,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: SizedBox(
//                       height: cardHeight,
//                       child: Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Row(
//                           children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: Image.network(
//                                 model['thumbnail'],
//                                 width: imageSize,
//                                 height: imageSize,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) =>
//                                     Container(
//                                   width: imageSize,
//                                   height: imageSize,
//                                   color: Colors.grey.shade300,
//                                   child: const Icon(Icons.car_repair,
//                                       color: Colors.grey, size: 40),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceAround,
//                                 children: [
//                                   Text(model['modelName'],
//                                       style: const TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold)),
//                                   Text('Brand: ${model['brand']}'),
//                                   Text('Class: ${model['class']}'),
//                                   Text('Price: \$${model['price']}'),
//                                   const SizedBox(height: 4),
//                                   Row(
//                                     children: [
//                                       const Text('Status: '),
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 8, vertical: 4),
//                                         decoration: BoxDecoration(
//                                           color: Colors.green.shade100,
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                         ),
//                                         child: Text(
//                                           'Active',
//                                           style: TextStyle(
//                                             color: Colors.green.shade800,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('carModels')
            .where('active', isEqualTo: true)
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
            return const Center(child: Text('No active car models found.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: filtered.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWideScreen ? 2 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio:
                    isWideScreen ? (screenWidth / 2) / cardHeight : screenWidth / cardHeight,
              ),
              itemBuilder: (context, index) {
                final doc = filtered[index];
                final data = doc.data() as Map<String, dynamic>;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CarDetailScreen(docId: doc.id, carId: '',),
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
                                child: const Icon(Icons.car_repair, size: 40),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                        borderRadius: BorderRadius.circular(12),
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
        color: isSelected ? Colors.white : AppTheme.primaryColor.withOpacity(0.8),
        borderRadius: isSelected
            ? const BorderRadius.all(Radius.circular(12))
            : BorderRadius.zero,
        boxShadow: isSelected
            ? [BoxShadow(color: Colors.black12, blurRadius: 4)]
            : [],
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
