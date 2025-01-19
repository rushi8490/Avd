// controllers/login_controller.dart
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class LoginController {
  final String apiUrl = 'http://27.116.52.24:8054/login';
  final storage = GetStorage();

  Future<bool> login(String mobile, String password) async {
    final Map<String, dynamic> data = {'mobile': mobile, 'password': password};

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final token = jsonResponse['data']['token'];
        final role = jsonResponse['data']['role'];
        await storage.write('cookie', token);
        await storage.write('role',role );
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }
}
