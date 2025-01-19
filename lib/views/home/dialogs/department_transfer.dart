import 'package:flutter/material.dart';

import '../../../controller/common_controller.dart';
import '../../../core/models/department_model.dart';
import '../../../core/models/location_model.dart';

class ProductTransferPage extends StatefulWidget {
  const ProductTransferPage({super.key});

  @override
  ProductTransferPageState createState() => ProductTransferPageState();
}

class ProductTransferPageState extends State<ProductTransferPage> {
  String? _selectedProduct;
  String? _selectedSourceLocation;
  String? _selectedTargetLocation;
  int _transferQuantity = 1;
  List<getDept> departmentList = [];
  List<GetLocation> locationList = [];
  final CommonController commonController = CommonController();

  @override
  void initState() {
    getDepartmentsData();
    getLocationsData();
    super.initState();
  }

  Future<void> getDepartmentsData() async {
    try {
      List<dynamic> departments = await commonController.fetchData('dept');
      setState(() {
        departmentList = departments.map((department) => getDept.fromJson(department)).toList();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  Future<void> getLocationsData() async {
    try {
      List<dynamic> locations = await commonController.fetchData('location');
      setState(() {
        locationList = locations.map((location) => GetLocation.fromJson(location)).toList();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Transfer',style: TextStyle(fontSize: 18),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Selection Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Product',
                  border: OutlineInputBorder(),
                ),
                value: _selectedProduct,
                items: departmentList
                    .map((product) => DropdownMenuItem(
                  value: product.dId.toString(),
                  child: Text(product.name),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProduct = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a product' : null,
              ),

              const SizedBox(height: 16),
              // Source Location Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Source Location',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSourceLocation,
                items: locationList
                    .map((location) => DropdownMenuItem(
                     value: location.lId.toString(),
                     child: Text(location.name),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSourceLocation = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a source location' : null,
              ),

              const SizedBox(height: 16),
              // Target Location Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Target Location',
                  border: OutlineInputBorder(),
                ),
                value: _selectedTargetLocation,
                items: locationList
                    .map((location) => DropdownMenuItem(
                  value: location.lId.toString(),
                  child: Text(location.name),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTargetLocation = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a target location' : null,
              ),

              const SizedBox(height: 16),
              // Transfer Quantity Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Transfer Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: _transferQuantity.toString(),
                onChanged: (value) {
                  setState(() {
                    _transferQuantity = int.tryParse(value) ?? 1;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  if (int.tryParse(value) == null || int.tryParse(value)! <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Process the transfer logic here
                    // Example: Call an API or function to transfer the product
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Transfer Successful'),
                        content: Text(
                            'You have successfully transferred $_transferQuantity units of $_selectedProduct from $_selectedSourceLocation to $_selectedTargetLocation.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text('Transfer Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
