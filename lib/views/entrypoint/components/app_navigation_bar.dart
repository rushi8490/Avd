import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/constants/constants.dart';
import 'bottom_app_bar_item.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final storage = GetStorage();

  AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onNavTap,
  });

  final int currentIndex;
  final void Function(int) onNavTap;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: AppDefaults.margin,
      color: AppColors.scaffoldBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          BottomAppBarItem(
            name: 'Home',
            iconLocation: AppIcons.home,
            isActive: currentIndex == 0,
            onTap: () => onNavTap(0),
          ),
          BottomAppBarItem(
            name: 'Add product',
            iconLocation: AppIcons.add,
            isActive: currentIndex == 1,
            onTap: () => onNavTap(1),
          ),
        ],
      ),
    );
  }
}
