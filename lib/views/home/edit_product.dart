import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:logo/views/home/product_details_page.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/department_model.dart';
import '../../core/models/get_product_byid.dart';
import '../../core/models/location_model.dart';

class EditProduct extends StatefulWidget {
   ProductData getproduct;
   EditProduct({super.key, required this.getproduct});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  List<Category> categoryList = [];
  List<GetLocation> locationList = [];
  final storage = GetStorage();
  String? selectedDepartment;
  String? assignedTo;
  String? status;
  String? imageName;
  String? imagePath;
  DateTime? selectedPurchaseDate;
  String? selectedCategory;
  List<Map<String, dynamic>> locationQuantityList = [
  ];

  final TextEditingController productNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController breadthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController purchaseDateController = TextEditingController();

  List<Map<String, dynamic>> locations = [];
  List<getDept> departmentList = [];

  Future<void> getDepartmentsData() async {
    final Uri url = Uri.http(
      '27.116.52.24:8054',
      '/getData',
    );

    try {
      Map<String, dynamic> body = {
        'table': 'dept',
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print('Response: $jsonResponse'); // Debugging response

        List<dynamic> departments = jsonResponse['data'];
        setState(() {
          departmentList = departments
              .map((department) => getDept.fromJson(department))
              .toList();

          selectedDepartment = departments
              .map((department) => getDept.fromJson(department))
              .firstWhere((dept) => dept.name == widget.getproduct.departmentName)
              .dId.toString();
        });
      } else {
        print('Failed to load departments with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }

  }
  Future<ProductData?> fetchProductDetailsById(int? productId) async {
    if (productId == null) return null;
    try {
      final response = await http.post(
        Uri.parse('http://27.116.52.24:8054/getProducts'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "productId": productId,
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var productData = ProductData.fromJson(jsonResponse['data']);
        print(jsonResponse);
        return productData;
      } else {
        print('Failed to load product: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> getCategoriesData() async {
    final Uri url = Uri.http(
      '27.116.52.24:8054',
      '/getData',
    );

    try {
      Map<String, dynamic> body = {
        'table': 'category',
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List<dynamic> categories = jsonResponse['data'];
        setState(() {
          categoryList = categories
              .map((category) => Category.fromJson(category))
              .toList();
          // Set selectedCategory to match the name of the categoryId
          // selectedCategory = categoryList
          //     .firstWhere(
          //       (category) =>
          //   category.cId == widget.getproduct.cid,
          //   orElse: () => categoryList[0], // Default if not found
          // )
          //     .name;
        });
      } else {
        print('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getLocationsData() async {
    final Uri url = Uri.http(
      '27.116.52.24:8054',
      '/getData',
    );

    try {
      Map<String, dynamic> body = {
        'table': 'location',
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List<dynamic> locations = jsonResponse['data'];
        setState(() {
          locationList = locations
              .map((location) => GetLocation.fromJson(location))
              .toList();
          // Case-insensitive match to get the location ID
          List<String> getLocationIds() {
            List<String> locationIds = [];

            for (var storage in widget.getproduct.storage!) {
              // Find the matching location
              final location = locationList.firstWhere(
                    (loc) => loc.name.toLowerCase() == storage.location?.toLowerCase(),
              );
              // Add to locationQuantityList
              locationQuantityList.add({
                "locationId": location.lId.toString(),
                "quantity": TextEditingController(text: storage.quantity.toString()),
              });
            }
            return locationIds;
          }
          List<String> locationIds = getLocationIds();
        });
      } else {
        print('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _removeLocationQuantityField(int index) {
    setState(() {
      if (locationQuantityList.length > 1) {
        locationQuantityList.removeAt(index);
      }
    });
  }

  Future<void> _addLocationQuantityField() async {
    setState(() {
      locationQuantityList.add({
        "productId": "",
        "locationId": null,
        "quantity": TextEditingController(),
      });
    });
  }

  Future<void> updateData({required String pname,required String desc,required String cate}) async {
    // Define the API URL
    final Uri url = Uri.http(
      '27.116.52.24:8054',
      '/updateData', // Endpoint path
    );
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'table': 'product',
          "name":pname ,
          "description":desc,
          "dimensions":"${widthController.text}*${breadthController.text}*${heightController.text}",
          // "quantity": desc.toString(),
          "cid":selectedCategory,
          "id": widget.getproduct.productId.toString(),
        }));
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var data = jsonResponse['data'];
      print(jsonResponse);

      if (jsonResponse['errorStatus'] == false) {
        print('Product data inserted successfully ${data}');
      }
    } else {
      print('Request failed with status code: ${response.statusCode}');
    }
  }

  @override
  void initState() {

    productNameController.text = widget.getproduct.name.toString();
    companyNameController.text = widget.getproduct.description.toString();
    quantityController.text = widget.getproduct.dimensions.toString();
    String string =  widget.getproduct.dimensions.toString();
    print(string);
    List<String> parts = string.split('*');
    print(parts); // Output: [12, 12, 12]
    widthController.text = parts[0];
    breadthController.text = parts[1];
    heightController.text = parts[2];
    selectedCategory = widget.getproduct.cid.toString();
    getLocationsData();
    getCategoriesData();
    getDepartmentsData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        title: const Text('Edit Product',style: TextStyle(fontSize: 18),),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // /* Image Picker */
              // const Text("Image"),
              // const SizedBox(height: 8),
              // ElevatedButton(
              //   onPressed: () async {
              //     FilePickerResult? result =
              //         await FilePicker.platform.pickFiles(
              //       type: FileType.image,
              //     );
              //     if (result != null) {
              //       setState(() {
              //         imagePath = result.files.single.path;
              //         imageName = result.files.single.name;
              //       });
              //     }
              //   },
              //   child: const Text('Choose Image'),
              // ),
              // if (imageName != null)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 8.0),
              //     child: Text('Selected Image: $imageName'),
              //   ),
              // const SizedBox(height: 16.0),

              // Display images from getproduct.images
              // Display images from getproduct.images
              widget.getproduct.images!.isEmpty
                  ? const Text('No images available')
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.getproduct.images!.map((image) {
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                "http://27.116.52.24:8054$image",
                                // Casting each item to String
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                widget.getproduct.images?.remove(image); // Remove image
                              });
                            },
                            child: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              /* Image Name */
              const SizedBox(height: 8),
              TextFormField(
                controller: productNameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: "Enter Product Name",
                  hintStyle: TextStyle(color: Colors.grey), // Placeholder text
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              const SizedBox(height: 8),
              // TextFormField(
              //   controller: imageNameController,
              //   keyboardType: TextInputType.text,
              //   textInputAction: TextInputAction.next,
              //   decoration: InputDecoration(
              //     hintText: "Quantity",
              //     hintStyle: TextStyle(color: Colors.grey), // Placeholder text
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              // const SizedBox(height: 16.0),
              const SizedBox(height: 8),
              TextFormField(
                controller: companyNameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: "Description",
                  hintStyle: TextStyle(color: Colors.grey), // Placeholder text
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: widthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Length",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                         controller: breadthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Breadth",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                         controller: heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Height",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              /* Categories */
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory.toString().trim(),
                items: categoryList.map<DropdownMenuItem<String>>((Category category) {
                  return DropdownMenuItem<String>(
                    value: category.cId.toString(),
                    child: Text(category.name.toString()),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  print(selectedCategory);
                  setState(() {
                    selectedCategory = newValue;
                    print(selectedCategory);
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Category',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 16.0),
              AbsorbPointer(
                absorbing: true,
                child: DropdownButtonFormField<String>(
                  value: selectedDepartment,
                  onChanged: (value) {
                    setState(() {
                      selectedDepartment = value;
                    });
                  },
                  items: departmentList.map((department) {
                    return DropdownMenuItem(
                      value: department.dId.toString(),
                      child: Text(department.name),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    hintText: "Select Department",
                    border: OutlineInputBorder(),
                    enabled:false
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Location and Quantity",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: locationQuantityList.length,
                      itemBuilder: (context, index) {
                         quantityController.text = locationQuantityList[index]["quantity"]!.toString();
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0),
                              child: Row(
                                children: [
                                  // Location Dropdown
                                  Expanded(
                                    flex: 3,
                                    child:
                                    DropdownButtonFormField<String>(
                                      value:locationQuantityList[index]["locationId"]?.toString(),
                                      hint: const Text("Select Location"),
                                      items:
                                      locationList.map((location) {
                                        return DropdownMenuItem(
                                          value: location.lId.toString(),
                                          child: Text(location.name),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          locationQuantityList[index]
                                          ["locationId"] = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              8.0),
                                        ),
                                      ),
                                      isExpanded: true,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Quantity TextField
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                       controller:locationQuantityList[index]['quantity'],
                                      decoration: InputDecoration(
                                        hintText: "Quantity",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              8.0),
                                        ),
                                      ),
                                      keyboardType:
                                      TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                const SizedBox(width: 12),
                                if (index == locationQuantityList.length - 1)
                                  TextButton.icon(
                                    onPressed: () => _addLocationQuantityField(),
                                    icon: const Icon(Icons.add_circle, color: AppColors.primary),
                                    label: const Text(
                                      "Add Location",
                                      style: TextStyle(color: AppColors.primary),
                                    ),
                                  ),
                                if (index == locationQuantityList.length - 1)
                                  TextButton.icon(
                                    onPressed: () => _removeLocationQuantityField(index),
                                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                                    label: const Text(
                                      "Remove",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                              ],
                            )
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              /* Submit Button */
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8), // Match button shape
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0, // Remove shadow for a clean gradient effect
                        backgroundColor: Colors.transparent, // Transparent for gradient
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Match gradient border),
                      ),
                      onPressed: () async{
                        EasyLoading.show();
                        await updateData(cate: selectedCategory.toString(),desc: companyNameController.text,pname: productNameController.text).whenComplete(() async {
                          EasyLoading.dismiss();
                          ProductData? productData = await fetchProductDetailsById(widget.getproduct.productId);
                          if (productData != null) {
                            Get.off(ProductDetailsPage(getproduct: productData));
                          } else {
                            debugPrint("Product not found.");
                          }

                        },);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 0, horizontal: 24),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // ElevatedButton(
              //   onPressed: () async{
              //     EasyLoading.show();
              //     await updateData(cate: selectedCategory.toString(),desc: companyNameController.text,pname: productNameController.text).whenComplete(() async {
              //       EasyLoading.dismiss();
              //       ProductData? productData = await fetchProductDetailsById(widget.getproduct.productId);
              //       if (productData != null) {
              //         Get.to(ProductDetailsPage(getproduct: productData));
              //       } else {
              //         debugPrint("Product not found.");
              //       }
              //
              //     },);
              //   },
              //   child: const Text('Save'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
