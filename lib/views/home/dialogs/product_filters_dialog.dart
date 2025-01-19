import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logo/controller/filter_controller.dart';
import 'package:logo/core/models/category_model.dart';
import 'package:logo/core/models/department.dart';
import 'package:logo/core/models/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';

class ProductFiltersScreen extends StatefulWidget {
  const ProductFiltersScreen({super.key});

  @override
  State<ProductFiltersScreen> createState() => _ProductFiltersScreenState();
}

class _ProductFiltersScreenState extends State<ProductFiltersScreen> {

  final FilterController filterController = FilterController(); // Base URL
  // Department-wise locations and categories
   List<Department>depts = [];
  List<Location>locs = [];
  List<Category>categories = [];
  List<Location>filterLocations = [];

  Future<void> _loadDepartments() async {
    try {
      print('API service call initiated');

      // Fetch department data
      final departments = await filterController.fetchDepartments('dept');
      print('Fetched departments:');

      // Update state with fetched departments
      setState(() {
        depts = departments; // Assuming depts is of type List<Department>
      });
      print('data : ${jsonEncode(depts)}');
    } catch (e) {
      setState(() {
        // Optionally handle state for loading or errors here
      });
      print('Error loading departments: $e');
    }
  }

  Future<void> _loadLocation() async {
    try {
      print('API service call initiated');

      // Fetch department data
      final locations = await filterController.fetchLocation('location');
      print('Fetched departments:');

      // Update state with fetched departments
      setState(() {
        locs = locations; // Assuming depts is of type List<Department>
      });
      print('locations : ${jsonEncode(locs)}');
    } catch (e) {
      setState(() {
        // Optionally handle state for loading or errors here
      });
      print('Error loading departments: $e');
    }
  }

  Future<void> _loadCategory() async {
    try {
      print('API service call initiated');

      // Fetch department data
      final category = await filterController.fetchCategory('category');
      print('Fetched category:');

      // Update state with fetched departments
      setState(() {
        categories = category; // Assuming depts is of type List<Department>
      });
      print('category : ${jsonEncode(locs)}');
    } catch (e) {
      setState(() {
        // Optionally handle state for loading or errors here
      });
      print('Error loading departments: $e');
    }
  }




  // Selected department, locations, and categories
  String? _selectedDepartment;
  final List<String> _selectedLocations = [];
  final List<String> _selectedCategories = [];

  @override
  void initState() {
    _loadDepartments();
     _loadLocation();
     _loadCategory();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // Get the list of locations and categories based on the selected department
    // List<Map<String, String>> _departmentItems = _selectedDepartment != null
    //     ? _departmentData[_selectedDepartment!]!
    //     : [];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Filter Products', style: TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              setState(() {
                _selectedLocations.clear();
                _selectedCategories.clear();
              });
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop({
              'department': _selectedDepartment,
              'locations': _selectedLocations,
              'categories': _selectedCategories,
            });
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Department:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedDepartment,
              hint: const Text('Choose a department'),
              isExpanded: true,
              items: depts.map((Department department) {
                return DropdownMenuItem<String>(
                  value: department.dId.toString(), // Assuming 'name' field is appropriate for display
                  child: Text(department.name),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  setState(() {
                    filterLocations = locs.where((loc) => loc.dId.toString() == newValue.toString()).toList();
                  });
                  _selectedDepartment = newValue;
                  _selectedLocations.clear(); // Reset selections when department changes
                  _selectedCategories.clear(); // Reset categories
                });
              },
            ),
            const SizedBox(height: 20),
            if (_selectedDepartment != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Locations:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: filterLocations.map((item) {
                      String location = item.name!;
                      bool isSelectedLocation = _selectedLocations.contains(location);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelectedLocation) {
                              _selectedLocations.remove(location);
                            } else {
                              _selectedLocations.add(location);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: isSelectedLocation ? AppColors.primary : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            location,
                            style: TextStyle(
                              color: isSelectedLocation ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Categories:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: categories.map((item) {
                      String category = item.name;
                      bool isSelectedCategory = _selectedCategories.contains(category);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelectedCategory) {
                              _selectedCategories.remove(category);
                            } else {
                              _selectedCategories.add(category);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: isSelectedCategory ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelectedCategory ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setStringList("categories", _selectedCategories);
                  await prefs.setStringList("locations", _selectedLocations);
                  await prefs.setString("department", _selectedDepartment.toString());
                  // Return selected values to the previous page
                  Navigator.pop(context, {
                    "categories": _selectedCategories,
                    "locations": _selectedLocations,
                    "department": _selectedDepartment,
                  });

                  // You can use Navigator.pop() to return the selected values if needed
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
