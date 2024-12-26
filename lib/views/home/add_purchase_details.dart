import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart'; // For formatting the selected date
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/models/purchase_model.dart';
import '../../core/routes/app_routes.dart';

class AddPurchaseDetails extends StatefulWidget {
  final int? productId;
   AddPurchaseDetails({super.key, required this.productId});

  @override
  State<AddPurchaseDetails> createState() => _AddPurchaseDetailsState();
}

class _AddPurchaseDetailsState extends State<AddPurchaseDetails> {
  List<purchaseDetails> pDetails = [];
  final storage = GetStorage();
  String? selectedDepartment;
  String? assignedTo;
  String? status;
  String? imageName;
  String? imagePath;
  DateTime? selectedPurchaseDate;
  String? selectedCategory;

  // Controllers
  final TextEditingController purchaseDateController = TextEditingController();
  final TextEditingController purchaseFromController = TextEditingController();
  final TextEditingController warrantyController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController purchasedByController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> submitProductData() async {
    print('purchased');
    // Define the API URL
    final Uri url = Uri.http(
      '27.116.52.24:8054', // Replace with your actual API domain and port
      '/insertData', // The correct API endpoint for inserting purchase data
    );
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "table": 'purchase',
          "productId": widget.productId,
          "date": purchaseDateController.text,
          "purcaseFrom": purchaseFromController.text,
          "warranty": warrantyController.text,
          "warranty": purchaseDateController.text,
          "prize": priceController.text,
          "purchasedBy": 'Admin',
          "createdBy": purchaseDateController.text,
          "description": descriptionController.text,
        }));
    if(response.statusCode==200){
      Get.snackbar(
        "Purchase Detail Saved..",
        "",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black26,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(
          Icons.account_balance_wallet_outlined,
          color: Colors.white,
          size: 24,
        ),
      );
    }else{
      print('error');
    }
  }

  Future<void> _selectPurchaseDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedPurchaseDate) {
      setState(() {
        selectedPurchaseDate = picked;
        purchaseDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Purchase Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              /* Purchase Date */
              const SizedBox(height: 8),
              TextFormField(
                controller: purchaseDateController,
                readOnly: true,
                onTap: () => _selectPurchaseDate(context),
                decoration: const InputDecoration(
                  hintText: "Purchase Date",
                  hintStyle: TextStyle(color: Colors.grey),
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              /* Purchase From */
              const SizedBox(height: 8),
              TextFormField(
                controller: purchaseFromController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: "Purchase From",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              /* Warranty Duration */
              const SizedBox(height: 8),
              TextFormField(
                controller: warrantyController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: "Warranty Duration",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              /* Price */
              const SizedBox(height: 8),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: "Price",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              /* Purchased By */
              const SizedBox(height: 8),
              TextFormField(
                controller: purchasedByController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: "Purchased By",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              /* Description */
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: "Description",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              /* Submit Button */
              SizedBox(
                height: 60,
                width: 150,
                child: ElevatedButton(
                  onPressed: submitProductData,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
