import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/constants/constants.dart';
import '../../../core/global/global_variable.dart';
import '../../../core/themes/app_themes.dart';
import '../../../core/utils/validators.dart';
import '../../entrypoint/entrypoint_ui.dart';
import 'login_button.dart';
import 'package:http/http.dart' as http;

class LoginPageForm extends StatefulWidget {
  const LoginPageForm({super.key,});

  @override
  State<LoginPageForm> createState() => _LoginPageFormState();
}

class _LoginPageFormState extends State<LoginPageForm> {
  String apiUrl = 'http://27.116.52.24:8054/login';

  @override
  void initState() {
    final singletonData = GlobalVariable();
    setState(() {
      apiUrl = singletonData.apiUrl;
    });
    super.initState();
  }

  final _key = GlobalKey<FormState>();
  // final String mobile = "6353783314";
  // final String password = "123";

  // Initialize controllers for email and password fields
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final storage = GetStorage();
  bool isPasswordShown = false;
  bool isLoading = false; // To manage the loading state
  onPassShowClicked() {
    isPasswordShown = !isPasswordShown;
    setState(() {});
  }

  onLogin() async {
    print('login');
    setState(() {
      isLoading = true;
    });

    // Prepare the data to send in the API request
    final Map<String, dynamic> data = {
      'mobile': mobileController.text,
      'password': passwordController.text,
    };
    print(mobileController.text);
    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse('${apiUrl}login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        print(response.body);
        var jsonrespose = jsonDecode(response.body);
        print(jsonrespose);
        var data = jsonrespose['data'];

        print(jsonrespose['data']);
        await storage.write('cookie', data['token']);
        await storage.write('role', data['isMaster']);
        setState(() {
          isLoading = false;
        });
        // }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const EntryPointUI()),
          (Route<dynamic> route) => false, // This removes all previous routes.
        );
      } else {
        setState(() {
          print('8888888888888888888888888888888888888888');
          isLoading = false;
        });
        // Handle error
        debugPrint('Login failed: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: AppTheme.defaultTheme.copyWith(
          inputDecorationTheme: AppTheme.secondaryInputDecorationTheme,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Form(
                key: _key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phone Field
                    const Text("Mobile No"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: mobileController,
                      keyboardType: TextInputType.number,
                      validator:
                          Validators.requiredWithFieldName('Mobile No').call,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppDefaults.padding),

                    // Password Field
                    const Text("Password"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: passwordController,
                      validator: Validators.password.call,
                      onFieldSubmitted: (v) => onLogin(),
                      textInputAction: TextInputAction.done,
                      obscureText: !isPasswordShown,
                      decoration: InputDecoration(
                        suffixIcon: Material(
                          color: Colors.transparent,
                          child: IconButton(
                            onPressed: onPassShowClicked,
                            icon: SvgPicture.asset(
                              AppIcons.eye,
                              width: 24,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 40.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: LoginButton(onPressed: onLogin),
                    ),
                    // Login labelLarge
                  ],
                ),
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.5),
                  // Opaque white background
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFFA500),
                    ), // Centered loader
                  ),
                ),
              ),
          ],
        ));
  }
}
