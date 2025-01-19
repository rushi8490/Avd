import 'package:http/http.dart' as http;
import 'package:logo/core/models/category_model.dart';
import 'package:logo/core/models/location.dart';
import 'dart:convert';
import '../core/models/department.dart';

class FilterController {
  FilterController();

// Fetch departments
  Future<List<Department>> fetchDepartments(String tableName) async {
    print('Table name: $tableName');

    Map<String, dynamic> body = {
      'table': tableName,
    };
    print('Calling API...');

    final Uri url = Uri.http('27.116.52.24:8054', '/getData');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');

      // Decode JSON response
      final List<dynamic> jsonData = json.decode(response.body)['data'];
      print('Parsed data: $jsonData');

      // Convert JSON data to List<Department>
      return jsonData.map((item) => Department.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load departments');
    }
  }

// Fetch Locations
  Future<List<Location>> fetchLocation(String tableName) async {
    print('Table name: $tableName');

    Map<String, dynamic> body = {
      'table': tableName,
    };
    print('Calling API...');

    final Uri url = Uri.http('27.116.52.24:8054', '/getData');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');

      // Decode JSON response
      final List<dynamic> jsonData = json.decode(response.body)['data'];
      print('Location Data data: $jsonData');

      // Convert JSON data to List<Department>
      return jsonData.map((item) => Location.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load departments');
    }
  }

// Fetch Category
  Future<List<Category>> fetchCategory(String tableName) async {
    print('Table name: $tableName');

    Map<String, dynamic> body = {
      'table': tableName,
    };
    print('Calling API...');

    final Uri url = Uri.http('27.116.52.24:8054', '/getData');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');

      // Decode JSON response
      final List<dynamic> jsonData = json.decode(response.body)['data'];
      print('Location Data data: $jsonData');

      // Convert JSON data to List<Department>
      return jsonData.map((item) => Category.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load departments');
    }
  }
}
