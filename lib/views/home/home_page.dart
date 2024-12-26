import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/components/product_tile_square.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_defaults.dart';
import '../../core/global/global_variable.dart';
import '../../core/models/get_product_byid.dart';
import '../../core/models/products_model.dart';
import '../../core/models/user_model.dart';
import '../../core/utils/ui_util.dart';
import '../auth/login_page.dart';
import 'dialogs/product_filters_dialog.dart';

enum Menu { User_Name, Logout }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> products = [];
  List<Storage> storageData = [];
  List<Storage> locationData = [];

  // List<GetLocation> locationList = [];
  List<ProductData> productList = []; // List to store the products
  final storage = GetStorage(); // Get GetStorage instance
  int currentPage = 1; // Track the current page for pagination
  final int itemsPerPage = 10;
  ScrollController scrollController = ScrollController();
  bool isLoadingMore = false;
  bool hasMoreItems = true;
  UserModel? user;
  String searchQuery = ''; // Store search query
  bool isSearching = false; // Initially, no searching is happening
  bool isLoading = false; // To manage the loading state
  AnimationStyle? _animationStyle;
  String apiUrl = '';

  @override
  void initState() {
    final singletonData = GlobalVariable();
    setState(() {
      apiUrl = singletonData.apiUrl;
    });
    //fetchItems();
    super.initState();
    storage.remove('locationName');
    storage.remove('categoryProductName');
    storage.remove('departmentName');
    if (storage.read('locationName') != null ||
        storage.read('categoryProductName') != null ||
        storage.read('departmentName') != null) {
      filterData();
    } else {
       fetchItems();
      // filterData();
    }
  }

  Future<void> filterData({String searchQuery = ''}) async {
    final Uri url = Uri.http(
      '27.116.52.24:8054',
      '/filterProducts',
    );


    // Get storage data or set default empty strings
    List<dynamic> selectedLocations = (storage.read('selectedLocations') ?? []);
    String getCategory() => storage.read('categoryProductName') ?? "";
    List<dynamic> selectedDepartments = (storage.read('selectedDepartments') ?? []) ;

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "location":selectedLocations,
          "category":getCategory(),
          "department": selectedDepartments,
          "search": searchQuery, // Add search query to the request
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print(jsonResponse);
        List<dynamic> productJsonList = jsonResponse['data'];
        print(jsonResponse);
        List<ProductData> productLists =
            productJsonList.map((json) => ProductData.fromJson(json)).toList();
        setState(() {
          productList = productLists.where((product) => product.storage!.length != 0).toList();
        });

      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load items: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchItems() async {
    EasyLoading.show();
    setState(() {
      isLoading = true;
    });
    String? cookie = storage.read('cookie');
    if (cookie == null) {
      print('No cookie found');
      return;
    }

    try {
      // Make a GET request to fetch items for the current page
      final response = await http.post(
        Uri.parse('${apiUrl}getProducts'),
        headers: {
          'Content-Type': 'application/json',
          'cookie': cookie,
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List<dynamic> productJsonList = jsonResponse['data'];
        List<ProductData> productLists =
            productJsonList.map((json) => ProductData.fromJson(json)).toList();
        setState(() {
          productList = productLists;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load items: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = true;
      });

      print('Error try error : $e');
    }
    EasyLoading.dismiss();
  }

  Future<void> fetchMoreItems() async {
    setState(() {
      isLoadingMore = true;
    });

    currentPage++; // Increment the page number
    await fetchItems(); // Fetch the next page of items

    setState(() {
      isLoadingMore = false;
    });
  }

  Future<void> searchProduct(String searchProduct) async {
    debugPrint('Searching for: $searchProduct');
    const String apiUrl = 'http://27.116.52.24:8054/getProduct';
    String? cookie = storage.read('cookie');
    if (cookie == null) {
      print('No cookie found');
      return;
    }

    try {
      // Make a GET request to fetch items for the current search query
      final response = await http.get(
        Uri.parse(
            '$apiUrl?search=$searchProduct&productStatus=all&productWarranty=all&Sort=newest'),
        headers: {
          'Content-Type': 'application/json',
          'cookie': cookie,
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List<dynamic> productsJson = jsonResponse['products'];

        setState(() {
          products.clear(); // Clear existing products before adding new ones
          products.addAll(productsJson
              .map((productJson) => Product.fromJson(productJson))
              .toList());
        });

        log("products ${products.map((item) => item.toJson())}");
      } else {
        debugPrint('Failed to load items : ${response.body}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      products.clear();
    });

    if (query.isNotEmpty) {
      filterData(searchQuery: searchQuery);
    } else {
      fetchItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: SizedBox.fromSize(
                    size: const Size.fromRadius(28),
                    child: Image.asset('assets/images/avd_logo.jpg',
                        fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            actions: [
              PopupMenuButton<Menu>(
                icon: const Icon(Icons.more_vert),
                onSelected: (Menu item)async {
                  if (item == Menu.Logout) {
                    // Navigate to the Login Page
                    await storage.remove('data');
                    await storage.remove('cookie');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
                  PopupMenuItem<Menu>(
                    value: Menu.User_Name,
                    child: ListTile(
                      leading: Icon(Icons.account_circle_outlined),
                      title: Text('${user?.name ?? ""}'),
                    ),
                  ),
                  const PopupMenuItem<Menu>(
                    value: Menu.Logout,
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                    ),
                  ),
                ],
              )
            ],
            leading: null,
          ),
        ),
        body: RefreshIndicator(
          onRefresh: ()async{
            await filterData();
          },
          child: CustomScrollView(
            controller: scrollController,
            // Use the scroll controller for pagination
            slivers: [
              SliverToBoxAdapter(
                child: searchHeader(
                  onSearchChanged:
                      onSearchChanged, // Pass the callback function to the search box
                ),
              ),
              // Sliver to display the header with product count
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${productList.length} product${productList.length == 1 ? '' : 's'} found',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary, // Use a contrasting color
                          ),
                        ],
                      ),
                      const SizedBox(height: 4), // Space between text and line
                      Container(
                        height: 2, // Height of the line
                        color:
                            AppColors.primary.withOpacity(0.5), // Divider color
                      ),
                    ],
                  ),
                ),
              ),
              // Sliver to display the product grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of items per row
                    mainAxisSpacing: 16, // Space between rows
                    crossAxisSpacing: 16, // Space between columns
                    childAspectRatio: 0.8, // Aspect ratio of each grid item
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return ProductTileSquare(
                        data: productList[index], // Pass the product data
                      );
                    },
                    childCount: productList.length, // Total number of products
                  ),
                ),
              ),
              // Sliver to show a loading indicator when fetching more items
              if (isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child:
                          CircularProgressIndicator(), // Show loading spinner
                    ),
                  ),
                ),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    scrollController.dispose();
    // searchController.dispose();
    super.dispose();
  }

  Widget searchHeader({required dynamic onSearchChanged}) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Stack(
              children: [
                // Search Box
                Form(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(AppDefaults.padding),
                        child: SvgPicture.asset(
                          AppIcons.search,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(),
                      contentPadding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    textInputAction: TextInputAction.search,
                    autofocus: false,
                    onChanged: (String value) {
                      onSearchChanged(value); // Trigger the callback on search input change
                    },
                    // onFieldSubmitted: (v) {
                    //   Navigator.pushNamed(context, AppRoutes.searchResult);
                    // },
                  ),
                ),
                Positioned(
                  right: 0,
                  height: 56,
                  child: SizedBox(
                    width: 56,
                    child: GestureDetector(
                      onTap: () async {
                        UiUtil.openBottomSheet(
                          context: context,
                          widget: ProductFiltersDialog(),
                        ).whenComplete(() async => await filterData());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),  // Slightly more rounded for a modern look
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.secondary, // Starting color
                              AppColors.primary,   // Ending color
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),  // Subtle shadow for depth
                              offset: const Offset(0, 4),  // Slight vertical shadow
                              blurRadius: 6,         // Soft blur for smoothness
                            ),
                          ],
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0), // Proper padding for the icon
                            child: SvgPicture.asset(
                              AppIcons.filter,
                              height: 24,  // Adjust icon size for clarity and balance
                              width: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
