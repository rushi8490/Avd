import 'package:flutter/cupertino.dart';
import '../../views/auth/login_page.dart';
import '../../views/entrypoint/entrypoint_ui.dart';
import '../../views/home/product_details_page.dart';
import '../../views/home/search_page.dart';
import '../models/get_product_byid.dart';
import '../models/products_model.dart';
import 'app_routes.dart';
import 'unknown_page.dart';

class RouteGenerator {
  static Route? onGenerate(RouteSettings settings) {
    final route = settings.name;

    switch (route) {

      case AppRoutes.entryPoint:
        return CupertinoPageRoute(builder: (_) => const EntryPointUI());

      case AppRoutes.search:
        return CupertinoPageRoute(builder: (_) => const SearchPage());

      case AppRoutes.login:
        return CupertinoPageRoute(builder: (_) => const LoginPage());

      case AppRoutes.productDetails:
        Product product =
            settings.arguments as Product; // Retrieve the product argument
        return CupertinoPageRoute(
            builder: (_) => ProductDetailsPage(
                getproduct:
                    ProductData())); // Ensure getProduct matches constructor
      default:
        return errorRoute();
    }
  }

  static Route? errorRoute() =>
      CupertinoPageRoute(builder: (_) => const UnknownPage());
}