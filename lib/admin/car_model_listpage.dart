import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/admin/add_car_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CarModelListPage extends StatelessWidget {
  const CarModelListPage({super.key});

  Future<void> _deleteCarModel(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('car_models').doc(docId).delete();
      Fluttertoast.showToast(msg: "Deleted successfully");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to delete: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Car Models")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('car_models').orderBy('sortOrder').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              return ListTile(
                title: Text(data['modelName'] ?? ''),
                subtitle: Text("Brand: ${data['brand']}, Price: ₹${data['price']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddCarModelPage(docId: docId)),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _confirmDelete(context, docId),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddCarModelPage()),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Car Model"),
        content: Text("Are you sure you want to delete this car model?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text("Delete"),
            onPressed: () {
              Navigator.pop(context);
              _deleteCarModel(docId);
            },
          ),
        ],
      ),
    );
  }
}
