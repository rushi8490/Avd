import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../views/home/components/animated_dots.dart';
import '../constants/constants.dart';
import 'network_image.dart';

class ProductImagesSlider extends StatefulWidget {
  const ProductImagesSlider({
    super.key,
    required this.images,
  });

  final List<String> images;

  @override
  State<ProductImagesSlider> createState() => _ProductImagesSliderState();
}

class _ProductImagesSliderState extends State<ProductImagesSlider> {
  late PageController controller;
  int currentIndex = 0;

  List<String> images = [];

  @override
  void initState() {
    super.initState();
    images = widget.images;
    controller = PageController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: AppColors.coloredBackground,
        borderRadius: AppDefaults.borderRadius,
      ),
      height: MediaQuery.of(context).size.height * 0.35,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: controller,
                  onPageChanged: (v) {
                    currentIndex = v;
                    setState(() {});
                  },
                  itemBuilder: (context, index) {
                    // Check if the URL is null or empty and provide a fallback image
                    String imageUrl = images[index];
                    if (imageUrl == null || imageUrl.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(AppDefaults.padding),
                        child: AspectRatio(
                          aspectRatio: 1 / 1,
                          child: Image.asset(
                            'assets/images/fallback_image.png', // Fallback image
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(AppDefaults.padding),
                        child: AspectRatio(
                          aspectRatio: 1 / 1,
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.contain,
                            errorWidget: (context, url, error) => const Icon(Icons
                                .error), // Show error icon if image fails to load
                          ),
                        ),
                      );
                    }
                  },
                  itemCount: images.length,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDefaults.padding),
                child: AnimatedDots(
                  totalItems: images.length,
                  currentIndex: currentIndex,
                ),
              )
            ],
          ),
          // Positioned(
          //   right: 0,
          //   child: Material(
          //     color: Colors.transparent,
          //     borderRadius: AppDefaults.borderRadius,
          //     child: IconButton(
          //       onPressed: () {},
          //       iconSize: 56,
          //       constraints: const BoxConstraints(minHeight: 56, minWidth: 56),
          //       icon: Container(
          //         padding: const EdgeInsets.all(AppDefaults.padding),
          //         decoration: const BoxDecoration(
          //           color: AppColors.scaffoldBackground,
          //           shape: BoxShape.circle,
          //         ),
          //         child: SvgPicture.asset(AppIcons.heart),
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
