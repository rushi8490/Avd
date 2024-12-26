import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
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
  final storage = GetStorage();
  String? selectedCategory;
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
  String apiUrl = '';

  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = []; // List to store selected images

  List<Map<String, dynamic>> locationQuantityList = [
    {"locationId": null, "quantity": TextEditingController()},
  ];
  // Array of colors to cycle through
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];
  int _currentColorIndex = 0;

  @override
  void initState() {
    super.initState();
    EasyLoading.show();
    getDepartmentsData();
    final singletonData = GlobalVariable();
    setState(() {
      apiUrl = singletonData.apiUrl;
    });
    getCategoriesData();
    getLocationsData().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }
  void _addDepartment() {
    setState(() {
      departments.add(
          {
           "departmentId": null, // Initially null, will be set via Dropdown
           "locations": [
              {
                "locationId": null, "quantity": TextEditingController()
              }
            ]
           }
           );
    });
  }

  void _addLocation(int departmentIndex) {
    setState(() {
      departments[departmentIndex]["locations"].add({
        "locationId": null,
        "quantity": TextEditingController(),
      });
    });
  }

  void _removeLocation(int departmentIndex, int locationIndex) {
    setState(() {
      departments[departmentIndex]["locations"].removeAt(locationIndex);
    });
  }

  void _removeDepartment(int departmentIndex) {
    setState(() {
      departments.removeAt(departmentIndex);
    });
  }

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
          print(
              'Departments loaded: ${departmentList.length}'); // Debugging count
        });
      } else {
        print('Failed to load departments with status: ${response.statusCode}');
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
        });
      } else {
        print('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    EasyLoading.dismiss();
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
        });
      } else {
        print('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
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

  Future<void> submitProductData() async {
    EasyLoading.show();
    final Uri url = Uri.http('27.116.52.24:8054', '/addProduct');
    var request = http.MultipartRequest('POST', url);
    request.headers["Content-Type"] = "multipart/form-data";
    request.fields['name'] = productNameController.text;
    request.fields['dimensions'] = "${widthController.text}*${breadthController.text}*${heightController.text}";
    request.fields['description'] = descriptionController.text;
    request.fields['dId'] = selectedDepartment.toString();
    request.fields['cid'] = selectedCategory ?? '';

    int totalQuantity = 0;
    for (var item in locationQuantityList) {
      String quantityText = item["quantity"].text;
      if (quantityText.isNotEmpty) {
        int quantity = int.tryParse(quantityText) ?? 0;
        totalQuantity += quantity;
      }
    }
    request.fields['quantity'] = totalQuantity.toString() ?? '';
    List<Map<String, dynamic>> locationQuantities =
        locationQuantityList.map((item) {
      return {
        "locationId": item["locationId"],
        "quantity": item["quantity"].text,
      };
    }).toList();

    // Add selected images to the request
    for (var image in selectedImages) {
      request.files.add(await http.MultipartFile.fromPath(
        'images',
        image.path,
      ));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await http.Response.fromStream(response);
      var jsonResponse = jsonDecode(responseBody.body);
      var data = jsonResponse['data'];

      for (var item in locationQuantityList) {
        String quantityText = item["quantity"].text;
        String locationId = item["locationId"];
        if (quantityText.isNotEmpty) {
          await addLocationCate(
            lId: locationId,
            quantity: quantityText,
            productId: data["productId"].toString(),
          );
        }
      }
      // var responseAssign = await http.post(url,
      //     headers: {"Content-Type": "application/json"},
      //     body: jsonEncode({
      //       'table': 'assign_masters',
      //       "dId": selectedDepartment.toString(),
      //       "productId": selectedDepartment.toString(),
      //     }));
      // if (responseAssign.statusCode == 200) {
      //   // Convert the streamed response into a proper response object
      //   var jsonResponse = jsonDecode(responseAssign.body);
      //   var data = jsonResponse['data'];
      //   //storage.write('pId', data['productId'].toString());
      //   // Handle success or failure based on API response
      //   if (jsonResponse['errorStatus'] == false) {
      //     print('Assign Product data inserted successfully');
      //
      //     print('Failed to insert product data: ${jsonResponse['message']}');
      //   }
      // } else {
      //   print('Request failed with status code: ${response.statusCode}');
      // }
      setState(() {
        isLoading = false;
      });
      // Get.snackbar(
      //   "Room Selection Required",
      //   "Please enter or select a room.",
      //   snackPosition: SnackPosition.TOP,
      //   backgroundColor: Colors.redAccent,
      //   colorText: Colors.white,
      //   duration: const Duration(seconds: 2),
      //   icon: const Icon(
      //     Icons.warning,
      //     color: Colors.white,
      //     size: 24,
      //   ),
      // );
      // _showConfirmationDialog();
    } else {
      print('Request failed with status code: ${response.statusCode}');
    }
    EasyLoading.dismiss();
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

  void _removeLocationQuantityField(int index) {
    setState(() {
      if (locationQuantityList.length > 1) {
        locationQuantityList.removeAt(index);
      }
    });
  }

  Future<void> _selectImages() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 50,
                  );
                  if (image != null) {
                    setState(() {
                      selectedImages.add(image);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.image_rounded),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final List<XFile>? images = await _picker.pickMultiImage(
                    imageQuality: 50,
                  );
                  if (images != null && images.isNotEmpty) {
                    setState(() {
                      selectedImages.addAll(images);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Product added successfully!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EntryPointUI(),
                  ),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
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
            title: const Text(
              'Add Product',
              style: TextStyle(fontSize: 18),
            ),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file, color: Colors.white, size: 20), // Smaller icon for balance
                          label: const Text(
                            'Choose Images',
                            style: TextStyle(
                              fontSize: 14, // Smaller text size for a professional look
                              fontWeight: FontWeight.w600, // Slightly lighter weight
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 2, // Subtle shadow
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6), // Slightly smaller radius for cleaner look
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Adjusted padding for a compact button
                          ),
                          onPressed: _selectImages,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (selectedImages.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: selectedImages.map((image) {
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
                                      child: Image.file(
                                        File(image.path),
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
                                        selectedImages.remove(image);
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
                    ),
                  // Form Fields
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: productNameController,
                          decoration: const InputDecoration(
                            hintText: "Enter Product Name",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            hintText: "Enter Description",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                          items: categoryList.map((category) {
                            return DropdownMenuItem(
                              value: category.cId.toString(),
                              child: Text(category.name),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            hintText: "Select category",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                   controller: widthController,
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
                                  keyboardType: TextInputType.number,
                                   controller: breadthController,
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
                                  keyboardType: TextInputType.number,
                                   controller: heightController,
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
                        DropdownButtonFormField<String>(
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
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Column(
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
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 3),
                                      child: Row(
                                        children: [
                                          // Location Dropdown
                                          Expanded(
                                            flex: 3,
                                            child:
                                                DropdownButtonFormField<String>(
                                                  value: locationQuantityList[index]["locationId"],
                                                  hint: const Text("Select Location"),
                                                  items: locationList.map((location) {
                                                    return DropdownMenuItem(
                                                      value: location.lId.toString(),
                                                      child: Text(location.name),
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) {
                                                  setState(() {
                                                    locationQuantityList[index]["locationId"] = value;
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8.0),
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
                                              controller: locationQuantityList[index]["quantity"],
                                              decoration: InputDecoration(
                                                hintText: "Quantity",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                              ),
                                              keyboardType: TextInputType.number,
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
                            // const SizedBox(height: 8),
                            // ElevatedButton(
                            //   onPressed: _addLocationQuantityField,
                            //   child: const Text('Add Location & Quantity'),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                          onPressed: submitProductData,
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

                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}











