import 'dart:convert';

import 'package:flutter/material.dart';
import '../../views/home/product_details_page.dart';
import '../constants/constants.dart';
import '../models/get_product_byid.dart';
import '../models/products_model.dart';
import 'package:http/http.dart' as http;
import '../routes/app_routes.dart';
import 'network_image.dart';

class ProductTileSquare extends StatelessWidget {
  const ProductTileSquare({
    super.key,
    required this.data,
  });

  final ProductData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding /5),
      child: Material(
        // borderRadius: AppDefaults.borderRadius,

        color: AppColors.scaffoldBackground,
        child: InkWell(
          // borderRadius: AppDefaults.borderRadius,
          onTap: () async {
            // Fetch product details by ID
            ProductData? productData = await fetchProductDetailsById(data.productId);
            if (productData != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsPage(getproduct: productData),
                ),
              );
            } else {
              debugPrint("Product not found.");
            }
          },
          child: buildProductTileContent(context),
        ),
      ),
    );
  }

  // Widget buildProductTileContent(BuildContext context) {
  //   return Container(
  //     width: 176,
  //     height: 300,
  //     padding: const EdgeInsets.all(AppDefaults.padding),
  //     decoration: BoxDecoration(
  //       // border: Border.all(width: 0.6),
  //       // borderRadius: AppDefaults.borderRadius,
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.all(3),
  //           child: AspectRatio(
  //             aspectRatio: 1.15,
  //             child: NetworkImageWithLoader(
  //               data.images!.isEmpty || data.images == null
  //                   ? "https://cdni.iconscout.com/illustration/premium/thumb/no-data-found-illustration-download-in-svg-png-gif-file-formats--missing-error-business-pack-illustrations-8019228.png?f=webp"
  //                   : "http://27.116.52.24:8054${data.images![0]}",
  //               fit: BoxFit.contain,
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           data.name ?? 'No Name',
  //           style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black),
  //           maxLines: 2,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //         const SizedBox(height: 4),
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const SizedBox(height: 4),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Flexible(
  //                   flex: 3,
  //                   child: Text(
  //                     'Quantity: ${data.quantity.toString()}',
  //                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //                       fontWeight: FontWeight.bold,
  //                       color: AppColors.primary,
  //                     ),
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Function to fetch product details by ID

  Widget buildProductTileContent(BuildContext context) {
    return Container(
      width: 176,
      height: 300,
      padding: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: Colors.white, // White background for the card
        borderRadius: AppDefaults.borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300, // Subtle shadow for depth
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white, // Light outer glow effect
            offset: const Offset(0, -2),
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: AppColors.primary, // Highlight edges
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: NetworkImageWithLoader(
                data.images!.isEmpty || data.images == null
                    ? "https://cdni.iconscout.com/illustration/premium/thumb/no-data-found-illustration-download-in-svg-png-gif-file-formats--missing-error-business-pack-illustrations-8019228.png?f=webp"
                    : "http://27.116.52.24:8054${data.images![0]}",
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Flexible( // Allows content to adjust dynamically
            child: Text(
              data.name ?? 'No Name',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              'Quantity: ${data.quantity.toString()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }





  Future<ProductData?> fetchProductDetailsById(int? productId) async {
    if (productId == null) return null;
    try {
      final response = await http.post(
        Uri.parse('http://27.116.52.24:8054/getProducts'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "productId": productId,
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var productData = ProductData.fromJson(jsonResponse['data']);
        print(jsonResponse);
        return productData;
      } else {
        print('Failed to load product: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}

