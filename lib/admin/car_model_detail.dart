import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarModelDetailPage extends StatefulWidget {
  final QueryDocumentSnapshot doc;

  const CarModelDetailPage({Key? key, required this.doc}) : super(key: key);

  @override
  _CarModelDetailPageState createState() => _CarModelDetailPageState();
}

class _CarModelDetailPageState extends State<CarModelDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _picker = ImagePicker();

  late TextEditingController _modelNameController;
  late TextEditingController _brandController;
  late TextEditingController _carClassController;
  late TextEditingController _priceController;
  bool _active = false;
  List<String> _imageUrls = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final data = widget.doc.data() as Map<String, dynamic>;
    _modelNameController = TextEditingController(text: data['modelName']);
    _brandController = TextEditingController(text: data['brand']);
    _carClassController = TextEditingController(text: data['carClass']);
    _priceController = TextEditingController(text: data['price'].toString());
    _active = data['active'] ?? false;
    _imageUrls = List<String>.from(data['modelImages'] ?? []);
  }

  @override
  void dispose() {
    _modelNameController.dispose();
    _brandController.dispose();
    _carClassController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('carmodel').doc(widget.doc.id).update({
        'modelName': _modelNameController.text.trim(),
        'brand': _brandController.text.trim(),
        'carClass': _carClassController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'active': _active,
        'modelCode': _modelNameController.text.trim().toLowerCase().replaceAll(' ', '-'),
        'modelImages': _imageUrls,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated successfully')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    }
  }

  Future<void> _deleteCarModel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Confirmation'),
        content: const Text('Are you sure you want to delete this car model?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('carmodel').doc(widget.doc.id).delete();

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    }
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
      if (pickedFiles == null || pickedFiles.isEmpty) return;

      setState(() => _isLoading = true);

      final storage = FirebaseStorage.instance;
      final List<String> newUrls = [];

      for (var pickedFile in pickedFiles) {
        final file = File(pickedFile.path);
        final ref = storage.ref().child('car_images/${widget.doc.id}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        newUrls.add(url);
      }

      _imageUrls.addAll(newUrls);

      await _firestore.collection('carmodel').doc(widget.doc.id).update({
        'modelImages': _imageUrls,
      });

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload images: $e')));
    }
  }

  Future<void> _removeImageAt(int index) async {
    final removedUrl = _imageUrls.removeAt(index);
    setState(() {});

    // Also delete image from Firebase Storage
    try {
      final storageRef = FirebaseStorage.instance.refFromURL(removedUrl);
      await storageRef.delete();
      // Update Firestore after deletion
      await _firestore.collection('carmodel').doc(widget.doc.id).update({
        'modelImages': _imageUrls,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Car Model Details',
        style: TextStyle(color: AppTheme.textPrimary),),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete,
            color: AppTheme.textPrimary,),
            onPressed: _isLoading ? null : _deleteCarModel,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    if (_imageUrls.isNotEmpty)
                      CarouselSlider.builder(
                        itemCount: _imageUrls.length,
                        itemBuilder: (context, index, _) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(_imageUrls[index], fit: BoxFit.cover, width: double.infinity),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: () => _removeImageAt(index),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        options: CarouselOptions(
                          height: 250,
                          enableInfiniteScroll: false,
                          viewportFraction: 0.9,
                          enlargeCenterPage: true,
                        ),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                       style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                      icon: const Icon(Icons.add_a_photo,
                      color: AppTheme.textPrimary,),
                      label: const Text('Add Images',
                      style: TextStyle(color: AppTheme.textPrimary)),
                      onPressed: _pickImages,
                      
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _modelNameController,
                      decoration: const InputDecoration(labelText: 'Model Name'),
                      validator: (val) => val == null || val.isEmpty ? 'Enter model name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(labelText: 'Brand'),
                      validator: (val) => val == null || val.isEmpty ? 'Enter brand' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _carClassController,
                      decoration: const InputDecoration(labelText: 'Car Class'),
                      validator: (val) => val == null || val.isEmpty ? 'Enter car class' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Enter price';
                        if (double.tryParse(val) == null) return 'Enter valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Active'),
                      value: _active,
                      onChanged: (val) => setState(() => _active = val),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                      onPressed: _isLoading ? null : _saveChanges,
                      child: const Text('Save Changes',
                      style: TextStyle(fontSize: 16,color: AppTheme.textPrimary,)),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
