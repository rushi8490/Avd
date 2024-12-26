import 'package:get_storage/get_storage.dart';

final GetStorage storage = GetStorage();
class GlobalVariable {

  static final GlobalVariable _instance = GlobalVariable._internal();

  // Private constructor
  GlobalVariable._internal();

  // Factory constructor to return the same instance
  factory GlobalVariable() {
    return _instance;
  }
  String apiUrl='http://27.116.52.24:8054/';
}