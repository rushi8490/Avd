import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logo/core/models/get_product_byid.dart';
import '../core/models/products_model.dart';

class HomeController {
  final storage = GetStorage();

  Future<List<ProductData>> fetchProducts(String apiUrl) async {
    EasyLoading.show();
    String? cookie = storage.read('cookie');
    if (cookie == null) throw Exception('No cookie found');

    final response = await http.post(
      Uri.parse('http://27.116.52.24:8054/getProducts'),
      headers: {
        'Content-Type': 'application/json',
        'cookie': cookie,
      },
    );
    EasyLoading.dismiss();

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      print(json.decode(response.body)['data']);
      return data.map((json) => ProductData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
