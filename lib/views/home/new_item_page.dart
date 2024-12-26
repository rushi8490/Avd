import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/product_tile_square.dart';
import '../../core/constants/constants.dart';

class NewItemsPage extends StatelessWidget {
  const NewItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Item'),
        leading: const AppBackButton(),
      ),
      body: SafeArea(
        child: Column(
        ),
      ),
    );
  }
}
