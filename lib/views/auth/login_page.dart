import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import 'components/login_header.dart';
import 'components/login_page_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoginPageHeader(),
                LoginPageForm(),
                SizedBox(height: AppDefaults.padding),
                // SocialLogins(),
                // DontHaveAccountRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
