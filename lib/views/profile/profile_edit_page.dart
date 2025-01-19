import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logo/controller/common_controller.dart';
import '../../controller/filter_controller.dart';
import '../../core/components/submit_button.dart';
import '../../core/constants/app_colors.dart';
import '../../core/global/global_variable.dart';
import '../../core/models/category_model.dart';
import '../../core/models/department_model.dart';
import '../../core/models/location_model.dart';
import '../entrypoint/entrypoint_ui.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  List<Category> categoryList = [];
  List<GetLocation> locationList = [];
  List<GetLocation> filteredLocationList = [];
  final storage = GetStorage();
  String? selectedCategory;
  String? categoryName;
  bool isLoading = true;
  String? selectedDepartment;
  List<getDept> departmentList = [];
  List<Map<String, dynamic>> departments = [
    {
      "departmentId": null,
      "locations": [
        {
          "locationId": null,
          "quantity": TextEditingController(), // Ensure TextEditingController is used for quantity
        },
      ],
    },
  ];
  // Controllers
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController dimensionController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController breadthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = []; // List to store selected images

  List<Map<String, dynamic>> locationQuantityList = [
    {"locationId": null, "quantity": TextEditingController()},
  ];
  String? selectedOrganization = 'AVD'; // Default selection
  List<String> organizations = ['AVD', 'HariPrabodham', 'HariSumiran'];
  final CommonController commonController = CommonController();
  final FilterController filterController = FilterController();

  @override
  void initState() {
    super.initState();
    // EasyLoading.show();
    getCategories();
    getDepartmentsData();
    getLocationsData();
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
        filteredLocationList = locationList;
      });
    } catch (e) {
      print(e);
    }
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

  Future<void> addLocationCate({productId, lId, quantity}) async {
    final Uri url = Uri.http('27.116.52.24:8054', '/insertData');

    final Map<String, dynamic> data = {
      'table': 'storage',
      'productId': productId,
      'lId': lId,
      'quantity': quantity,
    };
    var response = await http.post(
      url,
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    try {
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        var responseAssign = await http.post(url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              'table': 'assign',
              "dId": selectedDepartment.toString(),
              "productId": productId.toString(),
              "quantity": quantity
            }));
        if (responseAssign.statusCode == 200) {

          // Convert the streamed response into a proper response object
          var jsonResponse = jsonDecode(responseAssign.body);
          print(jsonResponse);

          var data = jsonResponse['data'];
          //storage.write('pId', data['productId'].toString());
          // Handle success or failure based on API response
          if (jsonResponse['errorStatus'] == false) {
            print('Assign Product data inserted successfully');

            print('Failed to insert product data: ${jsonResponse['message']}');
          }
        } else {
          print('Request failed with status code: ${response.statusCode}');
        }

        print('addLocationCate data inserted successfully ${jsonResponse}');
        Get.off(EntryPointUI(),transition: Transition.fadeIn);

      } else {
        print('addLocationCate Request failed with status code: ${response}');
      }
    } catch (e) {
      print(
          ' addLocationCate Error occurred while submitting product data: $e');
    }
  }
  List<Map<String, dynamic>> departmentLocationQuantityList = [
    {
      "departmentId": null,
      "locations": [
        {"locationId": '1', "quantity": TextEditingController()}
      ]
    }
  ];
  void _addDepartmentField() {
    setState(() {
      departmentLocationQuantityList.add({
        "departmentId": null,
        "locations": [
          {"locationId": '1', "quantity": TextEditingController()}
        ]
      });
    });
  }

  void _addLocationField(int departmentIndex) {
    setState(() {
      departmentLocationQuantityList[departmentIndex]["locations"].add({
        "locationId": null,
        "quantity": TextEditingController()
      });
    });
  }
  void _removeLocationField(int departmentIndex) {
    setState(() {
      if (departmentLocationQuantityList[departmentIndex]["locations"].isNotEmpty) {
        departmentLocationQuantityList[departmentIndex]["locations"].removeLast();
      }
    });
  }
  void _removeDepartmentField(int departmentIndex) {
    setState(() {
      departmentLocationQuantityList.removeAt(departmentIndex);
    });
  }

  Future<void> submitProductData() async {
    try {
      EasyLoading.show();
      final Uri url = Uri.http('27.116.52.24:8054', '/addProductWithStorage');
      var request = http.Request('POST', url);
      request.headers["Content-Type"] = "application/json";

      Map<String, dynamic> productData = {
        "name": productNameController.text,
        "description": descriptionController.text,
        "cid": int.parse(selectedCategory!), // Ensure category ID is an integer
        "dimension":"${widthController.text}*${breadthController.text}*${heightController.text}",
        "org":selectedOrganization,
        "departments": departmentLocationQuantityList.map((department) {
          return {
            "dId": department["departmentId"]!,
            "locations": department["locations"].map((location) {
              return {
                "lId": location["locationId"]!,
                "quantity": location["quantity"]!.text
              };
            }).toList(),
          };
        }).toList(),
      };
      request.body = jsonEncode(productData);

      var response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product Added successfully')),
        );
        var responseBody = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responseBody.body);
        var data = jsonResponse['data'];
        await addImages();
        print('Product added with ID: ${data["productId"]}');
      } else {
        print('Request failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void>addImages() async {
    final Uri url = Uri.http('27.116.52.24:8054', '/addProductWithStorage');
      var request = http.MultipartRequest('POST', url);
      for (var image in selectedImages) {
        request.files.add(await http.MultipartFile.fromPath(
          'images',
           image.path,
        ));
      }
    var response = await request.send();
    if (response.statusCode == 200){
      Get.to(const EntryPointUI(),transition: Transition.fadeIn);
    }
  }


  Future<void> _selectImages() async {
    void _pickImage(ImageSource source) async {
      Navigator.pop(context);
      if (source == ImageSource.camera) {
        final XFile? image = await _picker.pickImage(source: source, imageQuality: 50);
        if (image != null) setState(() => selectedImages.add(image));
      } else {
        final List<XFile>? images = await _picker.pickMultiImage(imageQuality: 50);
        if (images != null && images.isNotEmpty) setState(() => selectedImages.addAll(images));
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          height: 150,
          child: Column(
            children: [
              _buildListTile(Icons.camera_alt_rounded, 'Camera', () => _pickImage(ImageSource.camera)),
              _buildListTile(Icons.image_rounded, 'Gallery', () => _pickImage(ImageSource.gallery)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: AppColors.scaffoldBackground,
            centerTitle: true,
            surfaceTintColor: Colors.transparent,
            title: const Text('Add Product', style: TextStyle(fontSize: 18)),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSelection(),
                const SizedBox(height: 5),
                if (selectedImages.isNotEmpty) _buildSelectedImages(),
                _buildFormFields(),
                // Dropdown for organization selection
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
                const SizedBox(height: 1.0),
                _buildDepartmentsSection(),
                const SizedBox(height: 25.0),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file, color: Colors.white, size: 20),
            label: const Text(
              'Choose Images',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 2,
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ),
            onPressed: _selectImages,
          ),
        ],
      ),
    );
  }
  Widget _buildSelectedImages() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: selectedImages.map((image) => Stack(
          alignment: Alignment.topRight,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(image.path),
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: () => setState(() => selectedImages.remove(image)),
                child: const Icon(Icons.remove_circle, color: Colors.red, size: 24),
              ),
            ),
          ],
        )).toList(),
      ),
    );
  }
  Widget _buildFormFields() {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(productNameController, "Enter Product Name"),
          _buildTextField(descriptionController, "Enter Description"),
          _buildDropdownField(selectedCategory, categoryList, "Select category","cId", (value) {
           setState(() {
             selectedCategory = value;
             // Find the corresponding category name
             categoryName = categoryList.firstWhere((category) => category.cId.toString() == value.toString()).name;

           });
          }),
          if (categoryName?.toLowerCase() == "table") ...[
            const SizedBox(height: 1.0),
            Row(
              children: [
                Expanded(child: _buildTextField(widthController, "Length", isNumeric: true)),
                Expanded(child: _buildTextField(breadthController, "Breadth", isNumeric: true)),
                Expanded(child: _buildTextField(heightController, "Height", isNumeric: true)),
              ],
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildTextField(TextEditingController controller, String hintText, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(hintText: hintText, border: const OutlineInputBorder()),
      ),
    );
  }
  Widget _buildDropdownField(String? value, List items, String hintText, String id, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        items: items.map((item) {
          String itemId = item.toJson()[id].toString();
          String itemName = item.name;
          return DropdownMenuItem(value: itemId, child: Text(itemName));
        }).toList(),
        decoration: InputDecoration(hintText: hintText, border: const OutlineInputBorder()),
        isExpanded: true,
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
  Widget _buildDepartmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Departments, Locations, and Quantities", style: TextStyle(fontSize: 16,)),
        const SizedBox(height: 1.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: departmentLocationQuantityList.length,
          itemBuilder: (context, index) => _buildDepartmentCard(index),
        ),
        const SizedBox(height: 16.0),
        Center(
          child: ElevatedButton.icon(
            onPressed: _addDepartmentField,
            icon: const Icon(Icons.add_circle, color: Colors.white),
            label: const Text("Add Department", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildDepartmentCard(int departmentIndex) {
    var department = departmentLocationQuantityList[departmentIndex];
    return Card(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                        if (newDepartmentId == null || newDepartmentId.isEmpty) {
                          filteredLocationList = locationList; // Show all locations if no department is selected
                        } else {
                          print(newDepartmentId);
                          filteredLocationList = locationList
                              .where((location) => location.dId.toString() == newDepartmentId.toString())
                              .toList();
                          department['locations'] = [
                      {
                        "locationId": filteredLocationList[0].lId.toString(),
                        "quantity": TextEditingController()
                        }];

                          print(filteredLocationList.length);
                        }
                        // Location update logic can also be embedded here.
                      });
                    }
                  ),
                ),
                if (departmentLocationQuantityList.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeDepartmentField(departmentIndex),
                  ),
              ],
            ),
            const SizedBox(height: 4.0),
            _buildLocationsList(departmentIndex),
            _buildAddRemoveLocationButtons(departmentIndex),
          ],
        ),
      ),
    );
  }
  Widget _buildLocationsList(int departmentIndex) {
    var locations = departmentLocationQuantityList[departmentIndex]["locations"];
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: locations.length,
      itemBuilder: (context, locationIndex) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildDropdownField(
                locations[locationIndex]["locationId"].toString(),
                filteredLocationList,
                "Select Location",
                    "lId",
                    (value) => setState(() => locations[locationIndex]["locationId"] = value),
              ),

            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: _buildTextField(locations[locationIndex]["quantity"], "Quantity", isNumeric: true),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildAddRemoveLocationButtons(int departmentIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed: () => _addLocationField(departmentIndex),
          icon: const Icon(Icons.add_circle, color: AppColors.primary),
          label: const Text("Add Location", style: TextStyle(color: AppColors.primary)),
        ),
        TextButton.icon(
          onPressed: () => _removeLocationField(departmentIndex),
          icon: const Icon(Icons.remove_circle, color: AppColors.primary),
          label: const Text("Remove", style: TextStyle(color: AppColors.primary)),
        ),
      ],
    );
  }
  Widget _buildSubmitButton() {
    return Row(
      children: [
        Expanded(
            child: CommonButton(
                text: 'Complete',
                onPressed: () async {
                  await submitProductData();
                  Get.offAll(const EntryPointUI(),transition: Transition.leftToRight);
                }
                )
        ),
      ],
    );
  }
}

class ProductModel {
  String name;
  String description;
  int cid;
  List<Department> departments;
  ProductModel({required this.name, required this.description, required this.cid, required this.departments});
}

class Department {
  int dId;
  List<Locations> locations;
  Department({required this.dId, required this.locations});
}

class Locations {
  int lId;
  int quantity;
  Locations({required this.lId, required this.quantity});
}
