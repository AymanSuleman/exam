
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddCarModelPage extends StatefulWidget {
  final String? docId;
  const AddCarModelPage({this.docId});

  @override
  _AddCarModelPageState createState() => _AddCarModelPageState();
}

class _AddCarModelPageState extends State<AddCarModelPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _modelNameController = TextEditingController();
  final TextEditingController _modelCodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _featuresController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  DateTime? _manufactureDate;
  bool _active = true;
  int? _sortOrder;

  String? _selectedBrand;
  String? _selectedClass;

  List<XFile>? _images = [];

  final List<String> brands = ['Audi', 'Jaguar', 'Land Rover', 'Renault'];
  final List<String> classes = ['A-Class', 'B-Class', 'C-Class'];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.docId != null) {
      _loadCarModelData();
    }
  }

  Future<void> _loadCarModelData() async {
    final doc = await FirebaseFirestore.instance.collection('carmodel').doc(widget.docId).get();
    if (doc.exists) {
      final data = doc.data()!;
      _modelNameController.text = data['modelName'] ?? '';
      _modelCodeController.text = data['modelCode'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _featuresController.text = data['features'] ?? '';
      _priceController.text = data['price']?.toString() ?? '';
      _selectedBrand = data['brand'];
      _selectedClass = data['carClass'];
      _active = data['active'] ?? true;
      _sortOrder = data['sortOrder'];
      _manufactureDate = data['dateOfManufacturing'] != null
          ? (data['dateOfManufacturing'] as Timestamp).toDate()
          : null;
      if (data['modelImages'] != null) {
        _images = (data['modelImages'] as List<dynamic>)
            .map((url) => XFile(url))
            .toList();
      }
      setState(() {});
    }
  }

  Future<void> _pickManufactureDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _manufactureDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _manufactureDate = pickedDate;
      });
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedImages = await picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (pickedImages != null) {
      setState(() {
        _images = pickedImages;
      });
    }
  }

  Future<List<String>> _uploadImages(List<XFile> images) async {
    List<String> urls = [];
    for (var image in images) {
      if (!image.path.startsWith("http")) {
        final file = File(image.path);
        final filename = DateTime.now().millisecondsSinceEpoch.toString() + '_' + image.name;
        final ref = FirebaseStorage.instance.ref().child('carmodel_images/$filename');
        final uploadTask = await ref.putFile(file);
        final url = await uploadTask.ref.getDownloadURL();
        urls.add(url);
      } else {
        urls.add(image.path);
      }
    }
    return urls;
  }

  Future<void> _saveCarModel() async {
    if (!_formKey.currentState!.validate()) return;

    if (_manufactureDate == null) {
      Fluttertoast.showToast(msg: "Please select date of manufacturing");
      return;
    }

    if (_selectedBrand == null) {
      Fluttertoast.showToast(msg: "Please select brand");
      return;
    }

    if (_selectedClass == null) {
      Fluttertoast.showToast(msg: "Please select class");
      return;
    }

    if (_images == null || _images!.isEmpty) {
      Fluttertoast.showToast(msg: "Please upload at least one image");
      return;
    }

    setState(() => isLoading = true);

    try {
      List<String> imageUrls = await _uploadImages(_images!);

      final docRef = widget.docId != null
          ? FirebaseFirestore.instance.collection('carmodel').doc(widget.docId)
          : FirebaseFirestore.instance.collection('carmodel').doc();

      await docRef.set({
        'brand': _selectedBrand,
        'carClass': _selectedClass,
        'modelName': _modelNameController.text.trim(),
        'modelCode': _modelCodeController.text.trim(),
        'description': _descriptionController.text.trim(),
        'features': _featuresController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'dateOfManufacturing': _manufactureDate,
        'active': _active,
        'sortOrder': _sortOrder ?? 0,
        'modelImages': imageUrls,
      }, SetOptions(merge: true));

      Fluttertoast.showToast(msg: "Saved successfully");
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: "Error saving data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  String? _validateModelCode(String? val) {
    if (val == null || val.isEmpty) return 'Model code is required';
    final regex = RegExp(r'^[a-zA-Z0-9]{1,10}$');
    if (!regex.hasMatch(val)) return 'Only letters and numbers, max 10 chars';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(widget.docId == null ? 'Add Car Model' : 'Edit Car Model',
        style: TextStyle(color: AppTheme.textPrimary),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildDropdown('Brand *', brands, _selectedBrand, (val) => setState(() => _selectedBrand = val)),
                    _buildDropdown('Class *', classes, _selectedClass, (val) => setState(() => _selectedClass = val)),
                    _buildTextField(_modelNameController, 'Model Name *'),
                    _buildTextField(_modelCodeController, 'Model Code *', maxLength: 10, validator: _validateModelCode),
                    _buildTextField(_descriptionController, 'Description *', maxLines: 3),
                    _buildTextField(_featuresController, 'Features *', maxLines: 3),
                    _buildTextField(_priceController, 'Price *', keyboardType: TextInputType.numberWithOptions(decimal: true)),
                    _buildDatePicker(),
                    SwitchListTile(
                      title: Text('Active'),
                      activeColor: AppTheme.activeColor,
                      inactiveThumbColor: AppTheme.inactiveColor,
                      value: _active,
                      onChanged: (val) => setState(() => _active = val),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Sort Order (optional)'),
                      keyboardType: TextInputType.number,
                      initialValue: _sortOrder?.toString(),
                      onChanged: (val) => _sortOrder = int.tryParse(val),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _pickImages,
                      icon: Icon(Icons.image),
                      label: Text('Pick Images (Max 5MB each, jpg/png/jpeg)'),
                    ),
                    if (_images != null && _images!.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images!.length,
                          itemBuilder: (_, i) => Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.primaryColor, width: 1.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(File(_images![i].path)),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () => setState(() => _images!.removeAt(i)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                      onPressed: _saveCarModel,
                      child: Text('Save',
                      style: TextStyle(color:AppTheme.textPrimary ,
                      ),
                    ),
                )],
                ),
              ),
            ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label),
        validator: (val) => val == null ? 'Required field' : null,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, int? maxLength, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        validator: validator ?? (val) => val == null || val.isEmpty ? '$label is required' : null,
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _manufactureDate == null
                  ? 'Select date of manufacturing *'
                  : 'Manufactured: ${DateFormat('yyyy-MM-dd').format(_manufactureDate!)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: _pickManufactureDate,
            child: Text('Pick Date'),
          )
        ],
      ),
    );
  }
}
