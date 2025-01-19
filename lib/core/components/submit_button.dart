import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
class CommonButton extends StatelessWidget {

  final String text;
  final VoidCallback onPressed;
  final double borderRadius;// New parameter for dynamic border radius
  final double textSize; // New parameter for dynamic border radius

  const CommonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.borderRadius = 10,
    this.textSize =18
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.only(left: 5,right: 5),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[
                AppColors.primary,
                AppColors.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius), // Rounded corners for the button
          ),
          child: ElevatedButton(
            onPressed:onPressed,
            style: ElevatedButton.styleFrom(
              disabledForegroundColor: Colors.white,
              disabledBackgroundColor: Colors.white,
              backgroundColor: Colors.transparent, // Adjust button color
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15), // Button padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius), // Rounded corners
              ),
            ),
            child:  Text(
              text,
              style: TextStyle(
                fontSize: textSize,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
