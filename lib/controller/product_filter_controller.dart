import 'package:get/get.dart';

class ProductFiltersController extends GetxController {
  // Department-wise locations and categories
  final Map<String, List<Map<String, String>>> departmentData = {
    'Sales': [
      {'location': 'New York', 'category': 'Retail'},
      {'location': 'Chicago', 'category': 'Wholesale'},
      {'location': 'Houston', 'category': 'Online'},
    ],
    'Engineering': [
      {'location': 'San Francisco', 'category': 'Software'},
      {'location': 'Seattle', 'category': 'Hardware'},
      {'location': 'Austin', 'category': 'Networking'},
    ],
    'HR': [
      {'location': 'Los Angeles', 'category': 'Recruitment'},
      {'location': 'Phoenix', 'category': 'Training'},
      {'location': 'Miami', 'category': 'Employee Relations'},
    ],
  };

  // Selected department, locations, and categories
  var selectedDepartment = ''.obs;
  var selectedLocations = <String>[].obs;
  var selectedCategories = <String>[].obs;

  // Get the list of locations and categories based on the selected department
  List<Map<String, String>> get departmentItems {
    if (selectedDepartment.isNotEmpty) {
      return departmentData[selectedDepartment.value] ?? [];
    }
    return [];
  }

  // Clear selections
  void clearSelections() {
    selectedLocations.clear();
    selectedCategories.clear();
  }

  // Toggle location
  void toggleLocation(String location) {
    if (selectedLocations.contains(location)) {
      selectedLocations.remove(location);
    } else {
      selectedLocations.add(location);
    }
  }

  // Toggle category
  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
  }
}
