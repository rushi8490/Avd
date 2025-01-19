
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logo/views/auth/login_page.dart';
import 'package:logo/views/entrypoint/entrypoint_ui.dart';
import 'core/themes/app_themes.dart';

Future<void> main() async {
  await GetStorage.init(); // Initialize GetStorage
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});
  final storage = GetStorage();
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AVD Assets',
      theme: AppTheme.defaultTheme,
      // onGenerateRoute: RouteGenerator.onGenerate,
      // initialRoute: AppRoutes.login,
      builder: EasyLoading.init(),
      // routes: {
      //   '/entry': (context) => EntryPointUI(),
      // },

      // home: ?EntryPointUI():LoginPage(),
      // home: LoginPage(),
      home:  storage.read("cookie") == "" || storage.read("cookie") == null?const LoginPage():const EntryPointUI (),
      debugShowCheckedModeBanner: false,
    );
  }
}
