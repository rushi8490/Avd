import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/constants.dart';
import '../../../core/global/global_variable.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/department_model.dart';
import '../../../core/models/location_model.dart';
import '../../entrypoint/entrypoint_ui.dart';
import '../components/categories_chip.dart';

class ProductFiltersDialog extends StatefulWidget {
  ProductFiltersDialog({super.key});

  @override
  _ProductFiltersDialogState createState() => _ProductFiltersDialogState();
}

class _ProductFiltersDialogState extends State<ProductFiltersDialog> {
  List<getDept> departmentList = [];
  List<GetLocation> locationList = [];
  List<Category> categoryList = [];

  final storage = GetStorage();

  @override
  void initState() {
    super.initState();
    getLocationsData();
    getDepartmentsData();
    getCategoriesData();

  }


  Future<void> getLocationsData() async {
    EasyLoading.show();
    final Uri url = Uri.http(
      '27.116.52.24:8054',
      '/getData', // Endpoint path
    );

    print('Request URL: $url');

    try {
      Map<String, dynamic> body = {
        'table': 'location',
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Set header for JSON content
        },
        body: jsonEncode(body), // Convert the body map to JSON string
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List<dynamic> locations = jsonResponse['data'];
        setState(() {
          locationList = locations
              .map((location) => GetLocation.fromJson(location))
              .toList();
        });
      } else {
        print('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getDepartmentsData() async {
    final Uri url = Uri.http(
      '27.116.52.24:8054',
      '/getData', // Endpoint path
    );

    print('Request URL: $url');

    try {
      Map<String, dynamic> body = {
        'table': 'dept', // Specify the table for departments
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Set header for JSON content
        },
        body: jsonEncode(body), // Convert the body map to JSON string
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List<dynamic> departments = jsonResponse['data'];
        setState(() {
          departmentList = departments
              .map((department) => getDept.fromJson(department))
              .toList();
        });
      } else {
        print('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getCategoriesData() async {
    final Uri url = Uri.http(
      '27.116.52.24:8054',
      '/getData', // Endpoint path
    );

    print('Request URL: $url');

    try {
      Map<String, dynamic> body = {
        'table': 'category', // Specify the table for departments
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Set header for JSON content
        },
        body: jsonEncode(body), // Convert the body map to JSON string
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List<dynamic> categories = jsonResponse['data'];
        setState(() {
          categoryList = categories
              .map((category) => Category.fromJson(category))
              .toList();
        });
      } else {
        print('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: AppDefaults.borderRadius,
              ),
              margin: const EdgeInsets.all(8),
            ),
            const _FilterHeader(),
            _LocationSelector(
              locationList: locationList,
            ),
            _CategoriesSelector(categoryList: categoryList),
            _DepartmentSelector(departmentList: departmentList),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(AppDefaults.padding),
                child: ElevatedButton(
                  onPressed: () {
                    storage.read('categoryProductName');
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filter'),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _LocationSelector extends StatefulWidget {
  final List<GetLocation> locationList;

  _LocationSelector({required this.locationList});

  @override
  State<_LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<_LocationSelector> {
  // Track active state for each location
  final Map<String, bool> activeLocations = {};
  final List<String> selectedLocations = []; // Store selected departments.

  final storage = GetStorage();

  @override
  void initState() {
    super.initState();
    for (var department in widget.locationList) {
      activeLocations.putIfAbsent(department.name, () => false);
    }

    // Initialize selected departments from storage, if available.
    final storedLocations = storage.read<List>('selectedLocations') ?? [];
    selectedLocations.addAll(storedLocations.map((e) => e.toString()));

    for (var department in selectedLocations) {
      activeLocations[department] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Locations',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 16,
              runSpacing: 16,
              children: widget.locationList.map((location) {
                bool isActive = activeLocations[location.name] ?? false;
                return CategoriesChip(
                  isActive: isActive,
                  label: isActive ? location.name : location.name,
                  onPressed: () async {
                    print(location.name);
                    await storage.write('locationName', location.name);
                    setState(() {
                      if(isActive){
                        storage.remove('locationName');
                      }
                      activeLocations[location.name] = !isActive;
                      if (isActive) {
                        // Remove the department if it is already active.
                        selectedLocations.remove(location.name);
                      } else {
                        // Add the department if it is inactive and not already in the list.
                        if (!selectedLocations.contains(location.name)) {
                          selectedLocations.add(location.name);
                        }
                      }
                      print(selectedLocations.length);
                      // Store the updated department list in persistent storage.
                      storage.write('selectedLocations', selectedLocations);
                    });
                    // Check if activeLocations update properly
                    print(
                        "Location ${location.name} active state: ${activeLocations[location.name]}");
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesSelector extends StatefulWidget {
  final List<Category> categoryList;


  _CategoriesSelector({required this.categoryList});

  @override
  State<_CategoriesSelector> createState() => _CategoriesSelectorState();
}

class _CategoriesSelectorState extends State<_CategoriesSelector> {
  final Map<String, bool> activeCategories = {};

  @override
  void initState() {
    super.initState();
    for (var category in widget.categoryList) {
      activeCategories[category.name] = false;
    }
    activeCategories[storage.read('categoryProductName') ?? ""] = true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Categories',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 16,
                runSpacing: 16,
                children: widget.categoryList.map((category) {
                  bool isActive = activeCategories[category.name] ?? false;
                  return CategoriesChip(
                    isActive: isActive,
                    label:isActive ? category.name : category.name,
                    onPressed: () async {
                      await storage.write('categoryProductName', category.name);
                      setState(() {
                        activeCategories[category.name] = !isActive;
                        if(isActive){
                          storage.remove('categoryProductName');
                        }
                      });
                      // Check if activeLocations update properly
                      print(
                          "Location ${category.name} active state: ${activeCategories[category.name]}");
                    },
                  );
                }).toList()),
          ),
        ],
      ),
    );
  }
}

class _DepartmentSelector extends StatefulWidget {
  final List<getDept> departmentList;

  _DepartmentSelector({required this.departmentList});

  @override
  State<_DepartmentSelector> createState() => _DepartmentSelectorState();
}

class _DepartmentSelectorState extends State<_DepartmentSelector> {
  final Map<String, bool> activedepartments = {};
  final List<String> selectedDepartments = []; // Store selected departments.

  final storage = GetStorage();

  @override
  void initState() {
    super.initState();
    for (var department in widget.departmentList) {
      activedepartments.putIfAbsent(department.name, () => false);
    }

    // Initialize selected departments from storage, if available.
    final storedDepartments = storage.read<List>('selectedDepartments') ?? [];
    selectedDepartments.addAll(storedDepartments.map((e) => e.toString()));

    for (var department in selectedDepartments) {
      activedepartments[department] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Department',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 16,
              runSpacing: 16,
              children: widget.departmentList.map((department) {
                bool isActive = activedepartments[department.name] ?? false;
                return CategoriesChip(
                  isActive: isActive,
                  label: isActive ? department.name : department.name,
                  onPressed: () {
                    storage.write('departmentName', department.name);
                    setState(() {
                      // Toggle department activation.
                      activedepartments[department.name] = !isActive;

                      if (isActive) {
                        // Remove the department if it is already active.
                        selectedDepartments.remove(department.name);
                      } else {
                        // Add the department if it is inactive and not already in the list.
                        if (!selectedDepartments.contains(department.name)) {
                          selectedDepartments.add(department.name);
                        }
                      }
                      // Store the updated department list in persistent storage.
                      storage.write('selectedDepartments', selectedDepartments);
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterHeader extends StatelessWidget {
  const _FilterHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 56,
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 40,
            width: 40,
            child: ElevatedButton(
              onPressed: () {
                print(storage.read('categoryName'));
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: AppColors.scaffoldWithBoxBackground,
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EntryPointUI()),
                  );
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.black,
                ), // Wrap the icon in an Icon widget
              ),
            ),
          ),
        ),
        Text(
          'Filter',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        ),
        SizedBox(
          width: 80,
          child: TextButton(
            onPressed: () {
              resetFilters();
              Get.off(const EntryPointUI());
              // navigator?.pop(context);
            },
            child: Text(
              'Reset',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black,
                  ),
            ),
          ),
        )
      ],
    );
  }

  void resetFilters() {
    storage.remove('selectedLocations');
    storage.remove('categoryProductName');
    storage.remove('selectedDepartments');

  }
}
