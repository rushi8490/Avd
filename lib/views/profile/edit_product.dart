import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logo/core/models/get_product_byid.dart';

import '../../controller/common_controller.dart';
import '../../core/models/department_model.dart';
import '../../core/models/location_model.dart';
import '../../core/models/products_model.dart';

class EditProductPage extends StatefulWidget {
  final ProductData product;

  const EditProductPage({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final CommonController commonController = CommonController();
  List<String> organizations = ['AVD', 'HariPrabodham', 'HariSumiran'];
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController breadthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  List selectedImages = [];
  String? selectedCategory;
  String? selectedOrganization;
  String? selectedCategoryName;
  List<Category>categoryList=[];
  List departmentLocationQuantityList = [];
  List<getDept> departmentList = [];
  List<GetLocation> locationList = [];

  @override
  Future<void> initState() async {
    super.initState();
    // Fetch dropdown data
   await getCategories();
    getDepartmentsData();
    getLocationsData();
    print(categoryList.length);
    // Populate initial values
    productNameController.text = widget.product.name ?? '';
    descriptionController.text = widget.product.description ?? '';
    selectedCategory = widget.product.cid.toString();
    selectedCategoryName = categoryList.firstWhere((category) => category.cId.toString() == selectedCategory.toString()).name;
    widget.product.storage?.forEach((storage) {
      departmentLocationQuantityList.add({
        "departmentId": "1",
        "locations": [
          {
            "locationId":"1",
            "quantity": TextEditingController(text: storage.quantity.toString()),
          },
        ],
      });
    });
  }
  Future<void> getCategories() async {
    try {
      List<dynamic> categories = await commonController.fetchData('category');
      setState(() {
        categoryList = categories.map((category) => Category.fromJson(category)).toList();
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }
  Future<void> getDepartmentsData() async {
    try {
      List<dynamic> departments = await commonController.fetchData('dept');
      setState(() {
        departmentList = departments.map((department) => getDept.fromJson(department)).toList();
      });
    } catch (e) {
      print(e);
    }
  }
  Future<void> getLocationsData() async {
    try {
      List<dynamic> locations = await commonController.fetchData('location');
      setState(() {
        locationList = locations.map((location) => GetLocation.fromJson(location)).toList();
      });
    } catch (e) {
      print(e);
    }
  }

  void _addDepartmentField() {
    setState(() {
      departmentLocationQuantityList.add({
        "departmentId": null,
        "locations": [
          {"locationId": null, "quantity": TextEditingController()},
        ],
      });
    });
  }

  void _removeDepartmentField(int index) {
    setState(() {
      departmentLocationQuantityList.removeAt(index);
    });
  }

  void _addLocationField(int departmentIndex) {
    setState(() {
      departmentLocationQuantityList[departmentIndex]["locations"].add({
        "locationId": null,
        "quantity": TextEditingController(),
      });
    });
  }

  void _removeLocationField(int departmentIndex, int locationIndex) {
    setState(() {
      departmentLocationQuantityList[departmentIndex]["locations"].removeAt(locationIndex);
    });
  }

  void _saveProduct() {
    // Save product logic here

    print("Product saved");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(productNameController, "Enter Product Name"),
            const SizedBox(height: 16),
            _buildTextField(descriptionController, "Enter Description"),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Choose a category',
              border: OutlineInputBorder(),
            ),
            value: selectedCategory,
            items: categoryList
                .map((category) => DropdownMenuItem<String>(
              value: category.cId.toString(), // Assuming `id` is the unique identifier.
              child: Text(category.name!), // Assuming `name` is the display text.
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
              });
            },
            validator: (value) => value == null ? 'Please select a category' : null,
          ),
            if (selectedCategoryName == "Table") ...[
              const SizedBox(height: 16),
              const SizedBox(height: 1.0),
              Row(
                children: [
                  Expanded(child: _buildTextField(widthController, "Length", isNumeric: true)),
                  Expanded(child: _buildTextField(breadthController, "Breadth", isNumeric: true)),
                  Expanded(child: _buildTextField(heightController, "Height", isNumeric: true)),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: DropdownButtonFormField<String>(
                value: selectedOrganization,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOrganization = newValue;
                  });
                },
                items: organizations.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Select Organization',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (selectedImages.isNotEmpty) _buildSelectedImages(),
            const SizedBox(height: 16),
            _buildDepartmentsSection(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveProduct,
              child: const Text("Save Product"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,{bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(hintText: hintText, border: const OutlineInputBorder()),
    );
  }

  Widget _buildDropdownField(String? value, List<String> items, String hintText, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value, // Ensure this is present and unique in items
      onChanged: (newValue) {
        setState(() {
          value = newValue;
        });
      },
      items: items.map((item) =>
          DropdownMenuItem(value: item, child: Text(item))).toList(),
      decoration: const InputDecoration(
          hintText: 'Select Item', border: OutlineInputBorder()),
    );
  }

  //   Widget _buildImageSelection() {
  //   // return ElevatedButton.icon(
  //   //   onPressed: _selectImages,
  //   //   icon: const Icon(Icons.image),
  //   //   label: const Text("Select Images"),
  //   // );
  // }

  Widget _buildSelectedImages() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: selectedImages.map((image) {
          return Stack(
            alignment: Alignment.topRight,
            children: [
              Image.file(File(image), width: 100, height: 100, fit: BoxFit.cover),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => setState(() => selectedImages.remove(image)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDepartmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Departments and Locations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: departmentLocationQuantityList.length,
          itemBuilder: (context, index) => _buildDepartmentCard(index),
        ),
        TextButton.icon(
          onPressed: _addDepartmentField,
          icon: const Icon(Icons.add),
          label: const Text("Add Department"),
        ),
      ],
    );
  }

  Widget _buildDepartmentCard(int index) {
    var department = departmentLocationQuantityList[index];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDepartmentDropdownField(
                      department["departmentId"],
                      departmentList,
                      "Select Department",
                      "dId",
                          (String? newDepartmentId) {
                        setState(() {
                          department["departmentId"] = newDepartmentId;
                          // Location update logic can also be embedded here.
                        });
                      }
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => _removeDepartmentField(index),
                ),
              ],
            ),
            ..._buildLocations(department["locations"], index),
            TextButton.icon(
              onPressed: () => _addLocationField(index),
              icon: const Icon(Icons.add),
              label: const Text("Add Location"),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDepartmentDropdownField(String? value, List items, String hintText, String id, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: (selectedValue) {
        onChanged(selectedValue);
        // _updateLocationBasedOnDepartment(selectedValue);
      },
      items: items.map((item) {
        String itemId = item.toJson()[id].toString();
        String itemName = item.name;
        return DropdownMenuItem(value: itemId, child: Text(itemName));
      }).toList(),
      decoration: InputDecoration(hintText: hintText, border: const OutlineInputBorder()),
      isExpanded: true,
    );

  }
  Widget _buildLocationDropdownField(String? value, List items, String hintText, String id, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items.map((item) {
        String itemId = item.toJson()[id].toString();
        String itemName = item.name;
        return DropdownMenuItem(value: itemId, child: Text(itemName));
      }).toList(),
      decoration: InputDecoration(hintText: hintText, border: const OutlineInputBorder()),
      isExpanded: true,
    );

  }

  List<Widget> _buildLocations(List locations, int departmentIndex) {
    return List.generate(locations.length, (locationIndex) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildLocationDropdownField(
              locations[locationIndex]["locationId"],
              locationList,
              "Select Location",
              "lId",
                  (value) => setState(() => locations[locationIndex]["locationId"] = value),
            ),

          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTextField(locations[locationIndex]["quantity"], "Quantity"),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () => _removeLocationField(departmentIndex, locationIndex),
          ),

        ]

      );
    });
  }


}
