import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import '../../core/models/department_model.dart';
import '../../core/models/location_model.dart';
import '../../core/global/global_variable.dart';
import '../models/get_product_byid.dart';

class DepartmentLocationPage extends StatefulWidget {
  final ProductData product;
   DepartmentLocationPage({super.key,required this.product});

  @override
  State<DepartmentLocationPage> createState() => _DepartmentLocationPageState();
}

class _DepartmentLocationPageState extends State<DepartmentLocationPage> {
  List<getDept> departmentList = [];
  List<GetLocation> locationList = [];
  String? selectedDepartment;
  bool isLoading = true;

  List<Map<String, dynamic>> locationQuantityList = [
    {"locationId": null, "quantity": TextEditingController()},
  ];

  @override
  void initState() {
    super.initState();
    getDepartmentsData();
    getLocationsData().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> addLocationCate({productId, lId, quantity}) async {
    final Uri url = Uri.http('27.116.52.24:8054', '/insertData');

    final Map<String, dynamic> data = {
      'table': 'storage',
      'productId': productId,
      'lId': lId,
      'quantity': quantity,
    };
    print(data);
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

        print('addLocationCate data inserted successfully ${jsonResponse}');
      } else {
        print('addLocationCate Request failed with status code: ${response}');
      }
    } catch (e) {
      print(
          ' addLocationCate Error occurred while submitting product data: $e');
    }
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


          selectedDepartment = departments
              .map((department) => getDept.fromJson(department))
              .firstWhere((dept) => dept.name == widget.product.departmentName)
              .dId.toString();


          print(selectedDepartment);

          print('Departments loaded: ${departmentList.length}'); // Debugging count
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
        print('Failed to load locations with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _addLocationQuantityField() {
    setState(() {
      locationQuantityList.add({
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Department Location')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Department Location')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
              const Text("Location and Quantity"),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: locationQuantityList.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      DropdownButton<String>(
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
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: locationQuantityList[index]["quantity"],
                          decoration: const InputDecoration(
                            hintText: "Quantity",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () => _removeLocationQuantityField(index),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _addLocationQuantityField,
                child: const Text('Add Location & Quantity'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {

                  for (var item in locationQuantityList) {
                    String quantityText = item["quantity"].text;
                    String locationId = item["locationId"];
                    if (quantityText.isNotEmpty) {
                      await addLocationCate(
                        lId: locationId,
                        quantity: quantityText,
                        productId: widget.product.productId.toString(),
                      );
                    }
                  }
                  EasyLoading.showSuccess("Location & Department successfully saved.");
                  Navigator.pop(context);

                },
                child: const Text('Submit Product'),
              ),
              // You can add a button to submit the data or handle it as needed
            ],
          ),
        ),
      ),
    );
  }
}
