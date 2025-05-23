// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class CarDetailScreen extends StatefulWidget {
//   final String carId;

//   const CarDetailScreen({Key? key, required this.carId, required String docId}) : super(key: key);

//   @override
//   State<CarDetailScreen> createState() => _CarDetailScreenState();
// }

// class _CarDetailScreenState extends State<CarDetailScreen> {
//   Map<String, dynamic>? carData;
//   int _currentImage = 0;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchCarData();
//   }

//   Future<void> fetchCarData() async {
//     try {
//       DocumentSnapshot snapshot = await FirebaseFirestore.instance
//           .collection('carModels')
//           .doc(widget.carId)
//           .get();

//       if (snapshot.exists) {
//         setState(() {
//           carData = snapshot.data() as Map<String, dynamic>;
//           isLoading = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//       }
//     } catch (e) {
//       print("Error fetching car: $e");
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;

//     if (isLoading) {
//       return Scaffold(
//         appBar: AppBar(title: const Text("Loading...")),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (carData == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text("Car Detail")),
//         body: const Center(child: Text("Car not found")),
//       );
//     }

//     final images = List<String>.from(carData!['images'] ?? [carData!['thumbnail']]);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(carData!['modelName'] ?? 'Car Detail'),
//         backgroundColor: Colors.black,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Image Carousel
//             CarouselSlider.builder(
//               itemCount: images.length,
//               itemBuilder: (context, index, realIdx) {
//                 return CachedNetworkImage(
//                   imageUrl: images[index],
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                   height: screenHeight * 0.4,
//                   placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
//                   errorWidget: (context, url, error) => const Icon(Icons.error),
//                 );
//               },
//               options: CarouselOptions(
//                 height: screenHeight * 0.4,
//                 viewportFraction: 1.0,
//                 enableInfiniteScroll: false,
//                 onPageChanged: (index, reason) {
//                   setState(() => _currentImage = index);
//                 },
//               ),
//             ),

//             // Thumbnails
//             if (images.length > 1)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: images.asMap().entries.map((entry) {
//                     return GestureDetector(
//                       onTap: () {
//                         setState(() => _currentImage = entry.key);
//                       },
//                       child: Container(
//                         width: 60,
//                         height: 60,
//                         margin: const EdgeInsets.symmetric(horizontal: 4),
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             color: _currentImage == entry.key ? Colors.blue : Colors.grey,
//                           ),
//                         ),
//                         child: CachedNetworkImage(
//                           imageUrl: entry.value,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),

//             // Car Info Card
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Card(
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                 elevation: 4,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         carData!['modelName'] ?? '',
//                         style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 10),
//                       Text("Brand: ${carData!['brand']}", style: const TextStyle(fontSize: 16)),
//                       const SizedBox(height: 6),
//                       Text("Class: ${carData!['class']}", style: const TextStyle(fontSize: 16)),
//                       const SizedBox(height: 6),
//                       Text("Model Code: ${carData!['modelCode']}", style: const TextStyle(fontSize: 16)),
//                       const SizedBox(height: 6),
//                       Text("Sort Order: ${carData!['sortOrder']}", style: const TextStyle(fontSize: 16)),
//                       const SizedBox(height: 6),
//                       Text("Price: ₹${carData!['price']}", style: const TextStyle(fontSize: 18, color: Colors.green)),
//                       const SizedBox(height: 6),
//                       Text("Manufactured On: ${(carData!['dateOfManufacture'] as Timestamp).toDate()}",
//                           style: const TextStyle(fontSize: 15)),
//                       const SizedBox(height: 12),
//                       Text(carData!['description'] ?? 'No description provided', style: const TextStyle(fontSize: 15)),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // Book Now Button
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: ElevatedButton.icon(
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 50),
//                   backgroundColor: Colors.black,
//                 ),
//                 icon: const Icon(Icons.shopping_cart_checkout),
//                 label: const Text("Book Now"),
//                 onPressed: () {
//                   // Handle booking logic here
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class CarDetailScreen extends StatefulWidget {
  final String carId;

  const CarDetailScreen({Key? key, required this.carId, required String docId}) : super(key: key);

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  Map<String, dynamic>? carData;
  int _currentImage = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCarData();
  }

  Future<void> fetchCarData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('carModel')
          .doc(widget.carId)
          .get();

      if (snapshot.exists) {
        setState(() {
          carData = snapshot.data() as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching car: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dateFormatter = DateFormat('dd MMM yyyy');

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Loading...")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (carData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Car Detail")),
        body: const Center(child: Text("Car not found")),
      );
    }

    final images = List<String>.from(carData!['images'] ?? [carData!['thumbnail']]);

    return Scaffold(
      appBar: AppBar(
        title: Text(carData!['modelName'] ?? 'Car Detail'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel with thumbnails
            Stack(
              children: [
                CarouselSlider.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index, realIdx) => CachedNetworkImage(
                    imageUrl: images[index],
                    width: double.infinity,
                    height: screenHeight * 0.4,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, size: 50),
                  ),
                  options: CarouselOptions(
                    height: screenHeight * 0.4,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() => _currentImage = index);
                    },
                  ),
                ),
                if (images.length > 1)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: images.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => setState(() => _currentImage = entry.key),
                          child: Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImage == entry.key
                                  ? Colors.white
                                  : Colors.white54,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    carData!['modelName'] ?? '',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Brand and Class
                  Row(
                    children: [
                      Chip(
                        label: Text(carData!['brand'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.grey.shade200,
                      ),
                      const SizedBox(width: 10),
                      Chip(
                        label: Text(carData!['class'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Price
                  Text(
                    'Price: ₹${carData!['price']}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Model Code and Sort Order
                  Text('Model Code: ${carData!['modelCode'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 16, color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text('Sort Order: ${carData!['sortOrder'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 16, color: Colors.black87)),
                  const SizedBox(height: 6),

                  // Date of Manufacture nicely formatted
                  if (carData!['dateOfManufacture'] != null)
                    Text(
                      'Manufactured On: ${dateFormatter.format((carData!['dateOfManufacture'] as Timestamp).toDate())}',
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    carData!['description'] ?? 'No description provided',
                    style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.black87),
                  ),

                  const SizedBox(height: 30),

                  // Book Now Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_cart_checkout),
                      label: const Text(
                        'Book Now',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Add booking logic here
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
