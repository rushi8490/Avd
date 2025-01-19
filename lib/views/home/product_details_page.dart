import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../core/components/department_location.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/models/department_model.dart';
import '../../core/models/get_product_byid.dart';
import '../../core/models/location_model.dart';
import '../entrypoint/entrypoint_ui.dart';
import '../profile/edit_product.dart';
import 'add_purchase_details.dart';
import 'dialogs/department_transfer.dart';
import 'edit_product.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductData getproduct;

  ProductDetailsPage({Key? key, required this.getproduct}) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final storage = GetStorage();
  String apiUrl = 'http://27.116.52.24:8054/';
  String? selectedLocation;
  List<GetLocation> locationList = [];
  List<Category> categoryList = [];
  List<getDept> departmentList = [];
  String? selectedDepartment;
  List<Map<String, dynamic>> locationQuantityList = [
    {"locationId": null, "quantity": TextEditingController(),"storageId":''},
  ];

  @override
  void initState() {
    getLocationsData();
    super.initState();
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
                "storageId":storage.storageId,
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

  Future<void> insertDepartment() async {
    // Define the API URL
    final Uri url = Uri.http(
      '27.116.52.24:8054',
      '/insertData', // Endpoint path
    );
    String? selectedProductId = storage.read('pId').toString();
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'table': 'assign_masters',
          "dId": selectedDepartment.toString(),
          "productId": selectedProductId.toString(),
        }));
    if (response.statusCode == 200) {
      // Convert the streamed response into a proper response object
      var jsonResponse = jsonDecode(response.body);
      var data = jsonResponse['data'];
      //storage.write('pId', data['productId'].toString());
      // Handle success or failure based on API response
      if (jsonResponse['errorStatus'] == false) {
        print('Product data inserted successfully');

        print('Failed to insert product data: ${jsonResponse['message']}');
      }
    } else {
      print('Request failed with status code: ${response.statusCode}');
    }
  }

  Future<void> getStorageData() async {
    // Define the API URL
    final Uri url = Uri.http(
      '27.116.52.24:8054',
      '/getData', // Endpoint path
    );
    try {
      // Define the JSON payload (your request body)
      Map<String, dynamic> body = {
        'table': 'storage',
        "storageId": 'storageId',
        "productId": 100,
        "lId": 'lId',
        "quantity": 'quantity',
      };
      // Make the POST request with the JSON payload
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Set header for JSON content
        },
        body: jsonEncode(body), // Convert the body map to JSON string
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response body
        var jsonResponse = json.decode(response.body);
        print(jsonResponse['data']);
        List<dynamic> locations = jsonResponse['data'];
        setState(() {});
      } else {
        print('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void getLocationName() {
    // for (var location in locationList) {
    //   if (location.lId == widget.getproduct.storage?.lId) {
    //     widget.getproduct.locationName = location.name;
    //   }
    // }
  }

  void getCategoryName() {
    for (var category in categoryList) {
      if (category.cId == widget.getproduct.cid) {
        widget.getproduct.categoryName = category.name;
      }
    }
  }

  // Function to delete product by ID
  Future<void> deleteProductById(String productId) async {
    String? cookie = storage.read('cookie');
    if (cookie == null) {
      print('No cookie found');
      return;
    }

    final response = await http.post(
      Uri.parse('${apiUrl}deleteProductById'),
      headers: {
        'Content-Type': 'application/json',
        'cookie': cookie,
      },
      body: json.encode({'productId': productId}),
    );

    if (response.statusCode == 200) {
      if (context.mounted) {
          Get.offAll(const EntryPointUI(),transition: Transition.fadeIn,duration: const Duration(milliseconds: 200));
          Navigator.of(context).pop(); // Close the dialog
      }
    } else {
      // Show error message in case of failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: ${response.body}')),
      );
    }
  }
  void _showAddQuantityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Quantity'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Location and Quantity",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Column(
                      children: locationQuantityList.map((item) {
                        int index = locationQuantityList.indexOf(item);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<String>(
                                  value: locationQuantityList[index]["locationId"]?.toString(),
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
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: locationQuantityList[index]
                                  ['quantity'],
                                  decoration: InputDecoration(
                                    hintText: "Quantity",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => setState(() {
                                  locationQuantityList.removeAt(index);
                                }),
                                tooltip: "Remove",
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          locationQuantityList.add({
                            "locationId": null,
                            "quantity": TextEditingController(),
                          });
                        });
                      },
                      child: const Text('Add Location & Quantity'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    updateData();
                    // Save logic here
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
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

  Future<void> updateLocationCate({productId, lId, quantity,storageId}) async {
    final Uri url = Uri.http('27.116.52.24:8054', '/updateData');

    final Map<String, dynamic> data = {
      'table': 'storage',
      // 'storageId':storageId,
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
        print('addLocationCate data inserted successfully ${jsonResponse}');
      } else {
        print('addLocationCate Request failed with status code: ${response}');
      }
    } catch (e) {
      print(
          ' addLocationCate Error occurred while submitting product data: $e');
    }
  }
  Future<void> updateData() async {

    for (var item in locationQuantityList) {
      String quantityText = item["quantity"].text;
      String locationId = item["locationId"];
      // int storageId = item["storageId"];
      if (quantityText.isNotEmpty) {
          await addLocationCate(
            lId: locationId,
            quantity: quantityText,
            productId: widget.getproduct.productId.toString(),
          );
      }
    }
    // print('hello1');
    // // Define the API URL
    // final Uri url = Uri.http(
    //   '27.116.52.24:8054',
    //   '/updateData', // Endpoint path
    // );
    // var response = await http.post(url,
    //     headers: {"Content-Type": "application/json"},
    //     body: jsonEncode({
    //       'table': 'product',
    //       "quantity": totalQuantity.toString(),
    //       "id": widget.getproduct.productId.toString(),
    //     }));

    // if (response.statusCode == 200) {
    //   var jsonResponse = jsonDecode(response.body);
    //   var data = jsonResponse['data'];
    //
    //   if (jsonResponse['errorStatus'] == false) {
    //     print('Product data inserted successfully ${data}');
    //
    //     print('Failed to insert product data: ${jsonResponse['message']}');
    //   }
    // } else {
    //   print('Request failed with status code: ${response.statusCode}');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: const BackButton(),
        centerTitle: true,
        title: Text(widget.getproduct.name.toString(),style: TextStyle(fontSize: 18),),
        actions: [
          PopupMenuButton<Menu>(
            icon: const Icon(Icons.more_vert),
            color: Colors.white,
            onSelected: (Menu item) {
              if (item == Menu.Edit) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditProductPage(product: widget.getproduct)),
                );
              } else if (item == Menu.Delete) {
                // Confirm deletion before proceeding
                _showDeleteConfirmationDialog(context);
              } else if (item == Menu.Quantity) {
                // showAddQuantityDialog(
                //   context,
                //   (newQuantity) async {
                //     if (newQuantity != "") {
                //       print(widget.getproduct.quantity.toString());
                //       print(newQuantity.toString());
                //       await updateData(
                //           totalQuantity: (int.parse(newQuantity.toString()) +
                //                   int.parse(
                //                       widget.getproduct.quantity.toString()))
                //               .toString());
                //       Navigator.pop(context);
                //     }
                //   },
                // );
                _showAddQuantityDialog();
              } else if (item == Menu.Item) {
                Get.to(ProductTransferPage());
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => DepartmentLocationPage(
                //             product:widget.getproduct,)),
                // );
              }
              if (item == Menu.APD) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddPurchaseDetails(productId:widget.getproduct.productId)),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
              const PopupMenuItem<Menu>(
                value: Menu.Edit,
                child: ListTile(
                  title: Text('Edit'),
                ),
              ),
              // const PopupMenuItem<Menu>(
              //   value: Menu.Quantity,
              //   child: ListTile(
              //     title: Text('Add Quantity'),
              //   ),
              // ),
              if (true)
                const PopupMenuItem<Menu>(
                  value: Menu.Item,
                  child: ListTile(
                    title: Text('Assign Item'),
                  ),
                ),
              const PopupMenuItem<Menu>(
                value: Menu.Delete,
                child: ListTile(
                  title: Text('Delete'),
                ),
              ),
              const PopupMenuItem<Menu>(
                value: Menu.APD,
                child: ListTile(
                  title: Text('Add purchase details'),
                ),
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display product image
              if (widget.getproduct.images != null &&
                  widget.getproduct.images!.isNotEmpty)
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.95,
                    aspectRatio: 16 / 9,
                    autoPlayInterval: const Duration(seconds: 3),
                    onPageChanged: (index, reason) {
                      // Optional: Add logic when the page changes if needed
                    },
                  ),
                  items: widget.getproduct.images!.map((url) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              "http://27.116.52.24:8054${url}",
                              // Casting each item to String
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                )
              else
                Center(
                  child: Image.network(
                    'https://cdni.iconscout.com/illustration/premium/thumb/no-data-found-illustration-download-in-svg-png-gif-file-formats--missing-error-business-pack-illustrations-8019228.png?f=webp',
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                  ),
                ),
              const SizedBox(height: 16),

              Text(
                widget.getproduct.name.toString(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 16),
              buildProductInfo(context),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildProductInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1,horizontal: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1,horizontal: 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, "Product Information"),
              const SizedBox(height: 10),
              buildInfoRow(context, 'Name:', '${widget.getproduct.name}'),
              buildInfoRow(context, 'Total Quantity:', '${widget.getproduct.quantity}'),
              buildInfoRow(context, 'Dimensions:', widget.getproduct.dimensions ?? 'N/A'),
              buildInfoRow(context, 'Category:', '${widget.getproduct.categoryName}'),
              buildInfoRow(context, 'Description:', '${widget.getproduct.description}'),
              // buildInfoRow(context, 'Department:', '${widget.getproduct.departmentName}'),
              const SizedBox(height: 20),
              _buildSectionHeader(context, "Storage Details"),
              const SizedBox(height: 10),
              // ..._buildStorageList(),
              ..._buildStorageListByDepartment(),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  List<Widget> _buildStorageListByDepartment() {
    if (widget.getproduct.storage == null || widget.getproduct.storage!.isEmpty) {
      return [
        Text(
          "No storage details available",
          style: TextStyle(color: Colors.grey[600]),
        ),
      ];
    }

    Map<String, List<Storage>> departmentWiseStorage = {};

    // Group storage items by department
    for (var storage in widget.getproduct.storage!) {
      String departmentName = storage.department ?? "Unknown"; // Assuming storage has a department field
      if (departmentWiseStorage.containsKey(departmentName)) {
        departmentWiseStorage[departmentName]!.add(storage);
      } else {
        departmentWiseStorage[departmentName] = [storage];
      }
    }

    // Create a list of widgets for each department
    List<Widget> departmentWidgets = [];

    departmentWiseStorage.forEach((departmentName, storages) {
      departmentWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            departmentName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
        ),
      );

      // Add a divider after each department
      departmentWidgets.add(Divider(height: 1, color: Colors.grey[300]));

      departmentWidgets.addAll(
        storages.map((storage) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  storage.location ?? "Unknown",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${storage.quantity}",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
    return departmentWidgets;
  }





  Widget buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex:2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog to confirm deletion
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: const Text('Are you sure you want to delete this product?'),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            TextButton(
              onPressed: () {
                deleteProductById(widget.getproduct.productId.toString()); // Convert productId to String

              },
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}

enum Menu { Edit, Delete, APD, Quantity, Item }
